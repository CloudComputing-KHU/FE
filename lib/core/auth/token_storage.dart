import 'dart:convert';

import 'package:itda/core/auth/token_persistence.dart';

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

/// 토큰 저장소. 모바일/데스크톱에서는 로컬 파일에 보존하고, 웹에서는 메모리로 동작합니다.
class TokenStorage {
  TokenStorage._();

  static String? _access;
  static String? _refresh;
  static String? _id;
  static int? _expiresIn;
  static AuthUserProfile _fallbackProfile = const AuthUserProfile();
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    final persisted = await readPersistedTokens();
    _access = _readPersistedString(persisted, 'access_token');
    _refresh = _readPersistedString(persisted, 'refresh_token');
    _id = _readPersistedString(persisted, 'id_token');
    final expiresIn = persisted['expires_in'];
    if (expiresIn is int) _expiresIn = expiresIn;
    _fallbackProfile = AuthUserProfile(
      name: _readPersistedString(persisted, 'name'),
      email: _readPersistedString(persisted, 'email'),
      role: _normalizeRole(_readPersistedString(persisted, 'role')),
    );
    _loaded = true;
  }

  static Future<void> writeAccessToken(String? token) async {
    _access = token;
    await _persist();
  }

  static Future<String?> readAccessToken() async {
    await ensureLoaded();
    return _access;
  }

  static Future<void> writeIdToken(String? token) async {
    _id = token;
    await _persist();
  }

  static Future<String?> readIdToken() async {
    await ensureLoaded();
    return _id;
  }

  static Future<void> writeRefreshToken(String? token) async {
    _refresh = token;
    await _persist();
  }

  static Future<String?> readRefreshToken() async {
    await ensureLoaded();
    return _refresh;
  }

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
    await _persist();
  }

  static Future<int?> readExpiresIn() async {
    await ensureLoaded();
    return _expiresIn;
  }

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
    await _persist();
  }

  static Future<AuthUserProfile> readCurrentUserProfile() async {
    await ensureLoaded();
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
    await ensureLoaded();
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
    await ensureLoaded();
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

  static Future<String?> readCurrentRole() async {
    await ensureLoaded();
    final claims = await readIdTokenClaims();
    return _normalizeRole(
      _readClaim(claims, const ['custom:role', 'role', 'app_role']),
    );
  }

  static Future<bool> hasValidIdToken() async {
    await ensureLoaded();
    final claims = await readIdTokenClaims();
    if (claims.isEmpty) return false;

    final exp = claims['exp'];
    if (exp is! num) return true;
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      exp.toInt() * 1000,
      isUtc: true,
    );
    return DateTime.now().toUtc().isBefore(expiresAt);
  }

  static Future<void> clear() async {
    _access = null;
    _refresh = null;
    _id = null;
    _expiresIn = null;
    _fallbackProfile = const AuthUserProfile();
    _loaded = true;
    await clearPersistedTokens();
  }

  static Future<void> _persist() async {
    if (!_loaded) _loaded = true;
    await writePersistedTokens({
      'access_token': _access,
      'refresh_token': _refresh,
      'id_token': _id,
      'expires_in': _expiresIn,
      'name': _fallbackProfile.name,
      'email': _fallbackProfile.email,
      'role': _fallbackProfile.role,
    });
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

  static String? _readPersistedString(
    Map<String, Object?> persisted,
    String key,
  ) {
    final value = persisted[key];
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static String? _normalizeRole(String? value) {
    final role = _emptyToNull(value)?.toLowerCase();
    if (role == null) return null;
    if (role == 'child' || role == 'children') return 'child';
    if (role == 'parent' || role == 'guardian') return 'parent';
    return role;
  }
}
