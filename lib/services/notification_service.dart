import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/notification_item.dart';

/// 잇다 백엔드의 알림 API 클라이언트 (dio 기반).
///
/// - `POST /devices/register` — FCM 디바이스 토큰 등록
/// - `GET /notifications` — 알림 목록 조회
/// - `GET /notifications/unread` — 읽지 않은 알림 목록 조회
/// - `PATCH /notifications/{notification_id}/read` — 단건 읽음 처리
/// - `PATCH /notifications/read-all` — 전체 읽음 처리
class NotificationService {
  NotificationService(this._dio);

  static const _useMockNotifications = bool.fromEnvironment(
    'MOCK_NOTIFICATIONS',
  );

  final Dio _dio;

  /// FCM 디바이스 토큰을 백엔드에 등록합니다.
  /// 인증 헤더(id_token)로 사용자를 식별하므로 토큰만 보냅니다.
  Future<void> registerDevice(String fcmToken) async {
    await _dio.post(
      ApiEndpoints.devicesRegister,
      data: {'fcm_token': fcmToken},
    );
  }

  /// 로그인 사용자의 알림 목록을 최신순으로 조회합니다.
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _dio.get(ApiEndpoints.notifications);
    return _withMockNotifications(_parseNotificationList(response.data));
  }

  /// 로그인 사용자의 읽지 않은 알림만 최신순으로 조회합니다.
  Future<List<NotificationItem>> getUnreadNotifications() async {
    final response = await _dio.get(ApiEndpoints.unreadNotifications);
    return _withMockNotifications(_parseNotificationList(response.data));
  }

  /// 알림 하나를 읽음 처리합니다.
  Future<void> markRead(String notificationId) async {
    await _dio.patch(ApiEndpoints.notificationRead(notificationId));
  }

  /// 모든 알림을 읽음 처리합니다.
  Future<void> markAllRead() async {
    await _dio.patch(ApiEndpoints.notificationsReadAll);
  }

  List<NotificationItem> _parseNotificationList(dynamic data) {
    final list = data as List<dynamic>;
    final items = list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<NotificationItem> _withMockNotifications(List<NotificationItem> items) {
    if (!_useMockNotifications || items.isNotEmpty) return items;
    return [
      NotificationItem(
        id: 'mock_photo_reaction_${DateTime.now().millisecondsSinceEpoch}',
        title: '부모님이 사진에 반응을 남겼어요',
        body: '방금 보낸 사진에 따뜻한 메시지가 도착했어요.',
        data: const {'type': 'photo_reaction', 'mock': true},
        isRead: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
