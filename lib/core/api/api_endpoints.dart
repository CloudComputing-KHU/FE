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

  // ── Questions ──────────────────────────────────────────
  /// GET /questions/{type}  (type: health | meal | mood)
  static String question(String type) => '/questions/$type';

  // ── Answers ────────────────────────────────────────────
  /// POST /answers/{type}
  static String submitAnswer(String type) => '/answers/$type';

  /// POST /answers/{type}/voice
  static String submitVoice(String type) => '/answers/$type/voice';

  /// GET /answers/{type}?user_id=...
  static String answers(String type) => '/answers/$type';

  // ── Photos ─────────────────────────────────────────────
  /// GET /photos/received?user_id=...  (부모가 받은 사진)
  static const receivedPhotos = '/photos/received';

  /// GET /photos/history?user_id=...  (자녀가 보낸 사진 이력)
  static const photoHistory = '/photos/history';
}
