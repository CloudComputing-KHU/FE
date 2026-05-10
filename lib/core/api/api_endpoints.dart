/// REST API 베이스 URL·경로 상수 (환경별로 분리 가능)
abstract final class ApiEndpoints {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );

  // ==================== Questions ====================
  /// `GET /questions/{type}` — 오늘의 질문 조회
  static String questions(String type) => '/questions/$type';

  // ==================== Answers ====================
  /// `GET /answers/{type}?user_id=...` 또는 `POST /answers/{type}`
  static String answers(String type) => '/answers/$type';

  /// `POST /answers/{type}/voice` — 음성 답변 업로드 (multipart)
  static String voiceAnswer(String type) => '/answers/$type/voice';

  // ==================== Photos ====================
  /// `POST /photos` — 사진 전송 (multipart)
  static const String photos = '/photos';

  /// `GET /photos/history?user_id=...` — 사진 전송 내역 조회
  static const String photosHistory = '/photos/history';

  // ==================== Dementia ====================
  /// `POST /dementia/analyze` — 음성 답변에 대한 치매 분석 요청
  static const String dementiaAnalyze = '/dementia/analyze';

  /// `GET /dementia/{analysis_id}` — 분석 결과 단건 조회
  static String dementiaAnalysisById(String analysisId) =>
      '/dementia/$analysisId';

  /// `GET /dementia?user_id=...` — 사용자별 분석 이력 조회
  static const String dementia = '/dementia';
}