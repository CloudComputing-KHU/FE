/// REST API 베이스 URL·경로 상수 (환경별로 분리 가능)
abstract final class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
