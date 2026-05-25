import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        defaultPresentAlert: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
        defaultPresentSound: true,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      await initialize();
    } catch (_) {
      return false;
    }

    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    if (Platform.isMacOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    if (Platform.isAndroid) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          true;
    }

    return true;
  }

  Future<bool> showPhotoReactionDemoAfterDelay({
    Duration delay = const Duration(seconds: 3),
  }) async {
    final granted = await requestPermission();
    if (!granted) return false;

    await Future<void>.delayed(delay);
    try {
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: '부모님이 사진에 반응을 남겼어요',
        body: '방금 보낸 사진에 따뜻한 메시지가 도착했어요.',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'itda_demo_notifications',
            '잇다 테스트 알림',
            channelDescription: '데모용 로컬 알림',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBanner: true,
            presentList: true,
            presentSound: true,
          ),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
