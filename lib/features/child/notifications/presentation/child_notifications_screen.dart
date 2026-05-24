/// 자녀 모드 알림 목록. 추후 BE 알림 API와 연동합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/providers/child_shell_tab_provider.dart';
import 'package:itda/features/child/widgets/child_primary_filled_button.dart';
import 'package:itda/features/shared/providers/family_provider.dart';

/// 자녀 알림 유형(추후 BE 푸시·폴링과 매핑).
enum ChildNotificationKind {
  /// 부모가 건강/식사/기분 등 퀘스트에 답했을 때
  parentQuestAnswer,

  /// 오늘 아직 사진을 보내지 않았을 때 독려
  photoReminderToday,
}

class ChildNotificationsScreen extends ConsumerWidget {
  const ChildNotificationsScreen({super.key});

  static final List<_NotificationItem> _photoItems = [
    const _NotificationItem(
      kind: ChildNotificationKind.photoReminderToday,
      headline: '사진 보내기',
      description: '오늘 아직 사진을 안 보내셨어요',
      timeLabel: '오전 10:00',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final family = ref.watch(familyMeProvider).valueOrNull;
    final parentName = _nonEmptyName(family?.activeLink?.parentName) ?? '부모님';
    final questItems = [
      _NotificationItem(
        kind: ChildNotificationKind.parentQuestAnswer,
        headline: '퀘스트 완료',
        description: '$parentName가 오늘 퀘스트에 답했어요',
        timeLabel: '1시간 전',
      ),
    ];

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _NotificationSectionCard(items: questItems),
          const SizedBox(height: 14),
          _NotificationSectionCard(items: _photoItems),
        ],
      ),
    );
  }
}

String? _nonEmptyName(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

/// 한 섹션 안의 알림들을 흰 카드 + 내부 구분선으로 묶음.
class _NotificationSectionCard extends StatelessWidget {
  const _NotificationSectionCard({required this.items});

  final List<_NotificationItem> items;

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
              _NotificationTile(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhoto = item.kind == ChildNotificationKind.photoReminderToday;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingIcon(kind: item.kind),
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
                            item.headline,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.35,
                              color: ChildDashboardColors.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.timeLabel,
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
                      item.description,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: ChildDashboardColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isPhoto) ...[
            const SizedBox(height: 12),
            ChildPrimaryFilledButton(
              label: '사진 보내기',
              onPressed: () {
                ref.read(childShellTabProvider.notifier).state = 4;
                context.pop();
              },
            ),
          ],
        ],
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ChildDashboardColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: isPhoto
          ? SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                ChildDashboardColors.orangeDark,
                BlendMode.srcIn,
              ),
            )
          : const Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 24,
              color: ChildDashboardColors.orangeDark,
            ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.kind,
    required this.headline,
    required this.description,
    required this.timeLabel,
  });

  final ChildNotificationKind kind;

  /// 한 줄 제목(퀘스트 완료 / 사진 보내기) — 시간과 같은 줄.
  final String headline;

  /// 예전 큰 제목에 쓰이던 본문 설명.
  final String description;
  final String timeLabel;
}
