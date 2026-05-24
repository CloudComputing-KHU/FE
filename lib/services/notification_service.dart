import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/core/models/notification_item.dart';

/// 잇다 백엔드의 알림 API 클라이언트 (dio 기반).
///
/// - `POST /devices/register` — FCM 디바이스 토큰 등록
/// - `GET /notifications` — 알림 목록 조회
class NotificationService {
  NotificationService(this._dio);

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
    final list = response.data as List<dynamic>;
    return list
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
