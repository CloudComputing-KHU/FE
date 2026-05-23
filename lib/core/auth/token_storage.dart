import 'dart:convert';

class AuthUserProfile {
  const AuthUserProfile({this.name, this.email, this.role});

  final String? name;
  final String? email;
  final String? role;

  String get displayName {
    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) return trimmedName;

    final trimmedEmail = email?.trim();
    if (trimmedEmail != null && trimmedEmail.isNotEmpty) {
      return trimmedEmail.split('@').first;
    }
    return '사용자';
  }

  String get roleLabel {
    switch (role) {
      case 'child':
        return '자녀용 앱';
      case 'parent':
        return '부모용 앱';
      default:
        return '잇다 앱';
    }
  }

  String get accountLabel {
    switch (role) {
      case 'child':
        return '자녀 계정';
      case 'parent':
        return '부모 계정';
      default:
        return '잇다 계정';
    }
  }

  AuthUserProfile copyWith({String? name, String? email, String? role}) {
    return AuthUserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

/// 토큰 저장소. 운영에서는 secure storage 등으로 교체하고, 현재는 메모리 스텁입니다.
class TokenStorage {
  TokenStorage._();

  static String? _access;
  static String? _refresh;
  static String? _id;
  static int? _expiresIn;
  static AuthUserProfile _fallbackProfile = const AuthUserProfile();

  static Future<void> writeAccessToken(String? token) async {
    _access = token;
  }

  static Future<String?> readAccessToken() async => _access;

  static Future<void> writeIdToken(String? token) async {
    _id = token;
  }

  static Future<String?> readIdToken() async => _id;

  static Future<void> writeRefreshToken(String? token) async {
    _refresh = token;
  }

  static Future<String?> readRefreshToken() async => _refresh;

  static Future<void> writeTokens({
    required String? accessToken,
    String? refreshToken,
    String? idToken,
    int? expiresIn,
  }) async {
    _access = accessToken;
    if (refreshToken != null) _refresh = refreshToken;
    if (idToken != null) _id = idToken;
    if (expiresIn != null) _expiresIn = expiresIn;
  }

  static Future<int?> readExpiresIn() async => _expiresIn;

  static Future<void> writeUserProfile({
    String? name,
    String? email,
    String? role,
  }) async {
    _fallbackProfile = _fallbackProfile.copyWith(
      name: _emptyToNull(name),
      email: _emptyToNull(email),
      role: _normalizeRole(role),
    );
  }

  static Future<AuthUserProfile> readCurrentUserProfile() async {
    final claims = await readIdTokenClaims();
    final tokenProfile = AuthUserProfile(
      name: _readClaim(claims, const [
        'name',
        'custom:name',
        'given_name',
        'nickname',
      ]),
      email: _readClaim(claims, const ['email']),
      role: _normalizeRole(
        _readClaim(claims, const ['custom:role', 'role', 'app_role']),
      ),
    );

    return AuthUserProfile(
      name: tokenProfile.name ?? _fallbackProfile.name,
      email: tokenProfile.email ?? _fallbackProfile.email,
      role: tokenProfile.role ?? _fallbackProfile.role,
    );
  }

  static Future<String?> readCurrentUserId() async {
    final claims = await readIdTokenClaims();
    return _readClaim(claims, const [
      'custom:user_id',
      'user_id',
      'email',
      'sub',
      'cognito:username',
    ]);
  }

  static Future<Map<String, dynamic>> readIdTokenClaims() async {
    final token = _id;
    if (token == null || token.isEmpty) return const <String, dynamic>{};

    final parts = token.split('.');
    if (parts.length < 2) return const <String, dynamic>{};

    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload);
      if (json is Map<String, dynamic>) return json;
    } catch (_) {
      return const <String, dynamic>{};
    }
    return const <String, dynamic>{};
  }

  static Future<void> clear() async {
    _access = null;
    _refresh = null;
    _id = null;
    _expiresIn = null;
    _fallbackProfile = const AuthUserProfile();
  }

  static String? _readClaim(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }

  static String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static String? _normalizeRole(String? value) {
    final role = _emptyToNull(value)?.toLowerCase();
    if (role == null) return null;
    if (role == 'child' || role == 'children') return 'child';
    if (role == 'parent' || role == 'guardian') return 'parent';
    return role;
  }
}
