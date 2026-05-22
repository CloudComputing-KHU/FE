import 'dart:convert';

/// 토큰 저장소. 운영에서는 secure storage 등으로 교체하고, 현재는 메모리 스텁입니다.
class TokenStorage {
  TokenStorage._();

  static String? _access;
  static String? _refresh;
  static String? _id;
  static int? _expiresIn;

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
  }

  static String? _readClaim(Map<String, dynamic> claims, List<String> keys) {
    for (final key in keys) {
      final value = claims[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}
