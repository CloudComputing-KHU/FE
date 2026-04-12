/// 액세스 토큰 저장소. 운영에서는 secure storage 등으로 교체하고, 현재는 메모리 스텁입니다.
class TokenStorage {
  TokenStorage._();

  static String? _access;

  static Future<void> writeAccessToken(String? token) async {
    _access = token;
  }

  static Future<String?> readAccessToken() async => _access;
}
