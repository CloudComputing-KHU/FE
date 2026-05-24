import 'package:flutter/foundation.dart';

/// REST API 베이스 URL·경로 상수 (환경별로 분리 가능)
abstract final class ApiEndpoints {
  /// 실행 시 --dart-define=API_BASE_URL=https://... 로 주입하면 우선 적용됩니다.
  /// 주입하지 않으면 플랫폼에 따라 자동 선택됩니다.
  ///   - Android 에뮬레이터 : http://10.0.2.2:8000
  ///   - 그 외 (웹·iOS·데스크톱) : http://localhost:8000
  static const _injected = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_injected.isNotEmpty) return _injected;
    // Android 에뮬레이터에서 호스트 PC의 localhost는 10.0.2.2 로 접근합니다.
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }

  // ==================== Auth ====================
  /// `POST /auth/signup` — 회원가입
  static const String authSignup = '/auth/signup';

  /// `POST /auth/confirm` — 회원가입 인증 확인
  static const String authConfirm = '/auth/confirm';

  /// `POST /auth/login` — 로그인
  static const String authLogin = '/auth/login';

  /// `POST /auth/refresh` — 토큰 갱신
  static const String authRefresh = '/auth/refresh';

  // ==================== Family ====================
  /// `POST /family/invites` — 가족 초대 코드 생성
  static const String familyInvites = '/family/invites';

  /// `POST /family/connect` — 가족 초대 코드로 연결
  static const String familyConnect = '/family/connect';

  /// `GET /family/me` — 내 가족 연결 상태 조회
  static const String familyMe = '/family/me';

  // ==================== Questions ====================
  /// `GET /questions/{type}` — 오늘의 질문 조회 (type: health | meal | mood)
  static String questions(String type) => '/questions/$type';

  // ==================== Answers ====================
  /// `POST /answers/{type}` 또는 `GET /answers/{type}`
  static String answers(String type) => '/answers/$type';

  /// `POST /answers/{type}/voice` — 음성 답변 업로드 (multipart)
  static String voiceAnswer(String type) => '/answers/$type/voice';

  // ==================== Photos ====================
  /// `POST /photos` — 사진 전송 (multipart)
  static const String photos = '/photos';

  /// `GET /photos/received` — 부모가 받은 사진 목록
  static const String receivedPhotos = '/photos/received';

  /// `GET /photos/history` — 사진 전송 내역 조회
  static const String photosHistory = '/photos/history';

  /// `GET /photos/{photo_id}/reactions` — 사진 반응 조회
  static String photoReactions(String photoId) => '/photos/$photoId/reactions';

  /// `POST /photos/{photo_id}/reactions/quick` — 빠른 반응 저장
  static String photoQuickReaction(String photoId) =>
      '/photos/$photoId/reactions/quick';

  /// `POST /photos/{photo_id}/reactions/voice` — 음성 반응 저장
  static String photoVoiceReaction(String photoId) =>
      '/photos/$photoId/reactions/voice';

  // ==================== Dementia ====================
  /// `POST /dementia/analyze` — 음성 답변에 대한 치매 분석 요청
  static const String dementiaAnalyze = '/dementia/analyze';

  /// `GET /dementia/{analysis_id}` — 분석 결과 단건 조회
  static String dementiaAnalysisById(String analysisId) =>
      '/dementia/$analysisId';

  /// `GET /dementia` — 사용자별 분석 이력 조회
  static const String dementia = '/dementia';

  // ==================== Notifications ====================
  /// `POST /devices/register` — FCM 디바이스 토큰 등록
  static const String devicesRegister = '/devices/register';

  /// `GET /notifications` — 알림 목록 조회
  static const String notifications = '/notifications';
}
