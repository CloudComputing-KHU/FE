import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/models/notification_item.dart';
import 'package:itda/services/notification_service.dart';

/// 알림 service 인스턴스.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(ApiClient.create()),
);

/// 알림 목록을 BE에서 불러옵니다. 로딩/에러/데이터 상태를 함께 관리합니다.
class NotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationItem>> {
  @override
  Future<List<NotificationItem>> build() {
    return ref.read(notificationServiceProvider).getNotifications();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).getNotifications(),
    );
  }
}

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);
