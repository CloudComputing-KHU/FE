import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/features/child/notifications/providers/notification_provider.dart';
import 'package:itda/services/notification_service.dart';

/// 앱 전역에서 FCM 초기화를 트리거할 때 사용하는 Provider.
///
/// `notificationServiceProvider`에 의존하므로 BE 등록에 같은 dio 인스턴스를
/// 공유합니다. 로그인 성공 직후/저장 토큰으로 자동 복귀했을 때 호출하세요.
final fcmServiceProvider = Provider<FcmService>(
  (ref) => FcmService(ref.read(notificationServiceProvider)),
);

/// FCM(푸시 알림) 초기화 및 토큰 등록을 담당합니다.
///
/// - 알림 권한 요청
/// - FCM 토큰 획득 → 백엔드 등록 (NotificationService.registerDevice)
/// - 토큰 갱신 시 재등록
class FcmService {
  FcmService(this._notificationService);

  final NotificationService _notificationService;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  /// 앱 시작(로그인 후)에 호출. 권한 요청 → 토큰 획득 → BE 등록.
  /// 로그아웃 후 재로그인 등으로 두 번 불려도 onTokenRefresh 구독이
  /// 중복되지 않도록 1회만 실제 실행됩니다.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1) 알림 권한 요청 (안드로이드 13+ / iOS)
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM 권한 상태: ${settings.authorizationStatus}');

      // 2) FCM 토큰 획득
      final token = await _messaging.getToken();
      debugPrint('FCM 토큰: $token');

      // 3) 백엔드에 등록
      if (token != null) {
        await _registerToken(token);
      }

      // 4) 토큰이 갱신되면 다시 등록
      _messaging.onTokenRefresh.listen(_registerToken);
    } catch (e) {
      _initialized = false;
      debugPrint('FCM 초기화 실패: $e');
    }
  }

  Future<void> _registerToken(String token) async {
    try {
      await _notificationService.registerDevice(token);
      debugPrint('FCM 토큰 BE 등록 완료');
    } catch (e) {
      debugPrint('FCM 토큰 BE 등록 실패: $e');
    }
  }
}
