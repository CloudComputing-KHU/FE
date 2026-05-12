import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 예약 전송 바텀시트용 퀵 선택 카드(즉시 / 오늘 저녁 / 내일 아침).
class ChildScheduleQuickPickCard extends StatelessWidget {
  const ChildScheduleQuickPickCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 14),
            decoration: BoxDecoration(
              color: selected
                  ? ChildDashboardColors.orange.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? ChildDashboardColors.orange
                    : ChildDashboardColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: ChildDashboardColors.orange,
                  size: 28,
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.25,
                    color: ChildDashboardColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    color: ChildDashboardColors.textSub,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
