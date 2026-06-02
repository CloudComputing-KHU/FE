import 'dart:async';

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
  Timer? _pollTimer;
  bool _fetching = false;

  @override
  Future<List<NotificationItem>> build() {
    ref.onDispose(() => _pollTimer?.cancel());
    _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      refresh(showLoading: false);
    });
    return ref.read(notificationServiceProvider).getNotifications();
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (_fetching) return;
    _fetching = true;
    if (showLoading) state = const AsyncLoading();
    final previous = state.valueOrNull;
    final result = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).getNotifications(),
    );
    state = result.when(
      data: AsyncData.new,
      error: (error, stackTrace) => previous != null
          ? AsyncData(previous)
          : AsyncError(error, stackTrace),
      loading: () =>
          previous != null ? AsyncData(previous) : const AsyncLoading(),
    );
    _fetching = false;
  }

  Future<void> markRead(String notificationId) async {
    final previous = state;
    state = state.whenData(
      (items) => [
        for (final item in items)
          if (item.id == notificationId) item.copyWith(isRead: true) else item,
      ],
    );

    final result = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).markRead(notificationId),
    );
    if (result.hasError) {
      state = previous;
      return;
    }
    ref.invalidate(unreadNotificationsProvider);
  }

  Future<void> markAllRead() async {
    final previous = state;
    state = state.whenData(
      (items) => [for (final item in items) item.copyWith(isRead: true)],
    );

    final result = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).markAllRead(),
    );
    if (result.hasError) {
      state = previous;
      return;
    }
    ref.invalidate(unreadNotificationsProvider);
  }
}

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsNotifier,
      List<NotificationItem>
    >(NotificationsNotifier.new);

/// 읽지 않은 알림 목록을 BE에서 불러옵니다.
class UnreadNotificationsNotifier
    extends AutoDisposeAsyncNotifier<List<NotificationItem>> {
  Timer? _pollTimer;
  bool _fetching = false;

  @override
  Future<List<NotificationItem>> build() {
    ref.onDispose(() => _pollTimer?.cancel());
    _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      refresh(showLoading: false);
    });
    return ref.read(notificationServiceProvider).getUnreadNotifications();
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (_fetching) return;
    _fetching = true;
    if (showLoading) state = const AsyncLoading();
    final previous = state.valueOrNull;
    final result = await AsyncValue.guard(
      () => ref.read(notificationServiceProvider).getUnreadNotifications(),
    );
    state = result.when(
      data: AsyncData.new,
      error: (error, stackTrace) => previous != null
          ? AsyncData(previous)
          : AsyncError(error, stackTrace),
      loading: () =>
          previous != null ? AsyncData(previous) : const AsyncLoading(),
    );
    _fetching = false;
  }
}

final unreadNotificationsProvider =
    AsyncNotifierProvider.autoDispose<
      UnreadNotificationsNotifier,
      List<NotificationItem>
    >(UnreadNotificationsNotifier.new);
