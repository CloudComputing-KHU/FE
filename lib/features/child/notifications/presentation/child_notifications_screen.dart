/// 자녀 모드 알림 목록. 추후 BE 알림 API와 연동합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 자녀 알림 유형(추후 BE 푸시·폴링과 매핑).
enum ChildNotificationKind {
  /// 부모가 건강/식사/기분 등 퀘스트에 답했을 때
  parentQuestAnswer,
  /// 오늘 아직 사진을 보내지 않았을 때 독려
  photoReminderToday,
}

class ChildNotificationsScreen extends StatelessWidget {
  const ChildNotificationsScreen({super.key});

  /// 사진 독려 카드 — 아이콘 배경(연노랑).
  static const _photoIconBg = Color(0xFFFEF9D7);

  /// 데모 목록. BE 연동 시 [ChildNotificationKind]별로 서버 데이터를 채웁니다.
  static final _items = <_NotificationItem>[
    _NotificationItem(
      kind: ChildNotificationKind.parentQuestAnswer,
      badgeLabel: '퀘스트 완료',
      title: '${MockItdaData.parentDisplayName}가 오늘 퀘스트에 답했어요',
      subtitle: '기분 퀘스트 · "좋아요"',
      timeLabel: '1시간 전',
    ),
    const _NotificationItem(
      kind: ChildNotificationKind.photoReminderToday,
      badgeLabel: '사진 보내기',
      title: '오늘 아직 사진을 안 보내셨어요',
      subtitle: '부모님께 오늘 하루를 사진으로 전해드려요',
      timeLabel: '오전 10:00',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 14),
        itemBuilder: (context, i) => _NotificationCard(item: _items[i]),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final isPhoto = item.kind == ChildNotificationKind.photoReminderToday;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LeadingIcon(kind: item.kind),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Badge(
                          label: item.badgeLabel,
                          background: isPhoto
                              ? ChildNotificationsScreen._photoIconBg
                              : ChildDashboardColors.orangeLight,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            height: 1.35,
                            color: ChildDashboardColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: ChildDashboardColors.textSub,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ChildDashboardColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isPhoto) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ChildDashboardColors.text,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD9D0C4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      '사진 보내기',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.kind});

  final ChildNotificationKind kind;

  @override
  Widget build(BuildContext context) {
    final isPhoto = kind == ChildNotificationKind.photoReminderToday;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isPhoto
            ? ChildNotificationsScreen._photoIconBg
            : ChildDashboardColors.orangeLight,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: isPhoto
          ? SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(
                ChildDashboardColors.orangeDark,
                BlendMode.srcIn,
              ),
            )
          : const Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 28,
              color: ChildDashboardColors.orangeDark,
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: ChildDashboardColors.orangeDark,
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.kind,
    required this.badgeLabel,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
  });

  final ChildNotificationKind kind;
  final String badgeLabel;
  final String title;
  final String subtitle;
  final String timeLabel;
}
