/// 자녀 모드 알림 목록. BE 알림 API(`GET /notifications`)와 연동합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/models/notification_item.dart';
import 'package:itda/features/child/notifications/providers/notification_provider.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';

class ChildNotificationsScreen extends ConsumerWidget {
  const ChildNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref
        .watch(unreadNotificationsProvider)
        .maybeWhen(data: (items) => items.length, orElse: () => 0);
    Future<void> refreshNotifications() async {
      await ref.read(notificationsProvider.notifier).refresh();
      await ref.read(unreadNotificationsProvider.notifier).refresh();
    }

    return Scaffold(
      backgroundColor: ChildDashboardColors.orangePale,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ChildDashboardColors.orangePale,
        foregroundColor: ChildDashboardColors.text,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: ChildDashboardColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            IconButton(
              tooltip: '모두 읽음',
              icon: const Icon(Icons.done_all_rounded),
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllRead(),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: ChildDashboardColors.orange,
        onRefresh: refreshNotifications,
        child: notificationsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: ChildDashboardColors.orange,
            ),
          ),
          error: (e, _) => _ErrorView(onRetry: refreshNotifications),
          data: (items) {
            if (items.isEmpty) {
              return const _EmptyView();
            }
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _NotificationSectionCard(
                  items: items,
                  onTapItem: (item) {
                    if (item.isRead) return;
                    ref.read(notificationsProvider.notifier).markRead(item.id);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 알림들을 흰 카드 + 내부 구분선으로 묶음.
class _NotificationSectionCard extends StatelessWidget {
  const _NotificationSectionCard({
    required this.items,
    required this.onTapItem,
  });

  final List<NotificationItem> items;
  final ValueChanged<NotificationItem> onTapItem;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: ChildDashboardColors.border.withValues(alpha: 0.5),
                ),
              _NotificationTile(
                item: items[i],
                onTap: () => onTapItem(items[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleColor = item.isRead
        ? ChildDashboardColors.textSub
        : ChildDashboardColors.text;
    final bodyColor = item.isRead
        ? ChildDashboardColors.textMuted
        : ChildDashboardColors.textSub;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LeadingIcon(isRead: item.isRead),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.35,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(item.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: ChildDashboardColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: bodyColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 생성 시각을 "방금 전 / N분 전 / N시간 전 / N일 전"으로 표시.
  static String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time.toLocal());
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.isRead});

  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isRead
            ? ChildDashboardColors.border.withValues(alpha: 0.4)
            : ChildDashboardColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.notifications_rounded,
        size: 24,
        color: isRead
            ? ChildDashboardColors.textMuted
            : ChildDashboardColors.orangeDark,
      ),
    );
  }
}

/// 알림이 없을 때.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 28),
      children: const [
        Icon(
          Icons.notifications_none_rounded,
          size: 56,
          color: ChildDashboardColors.textMuted,
        ),
        SizedBox(height: 16),
        Text(
          '아직 도착한 알림이 없어요',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ChildDashboardColors.textSub,
          ),
        ),
      ],
    );
  }
}

/// 불러오기 실패 시.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '알림을 불러오지 못했어요.',
            style: TextStyle(fontSize: 14, color: ChildDashboardColors.textSub),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
