import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 홈 상단 3열 요약 카드 (퀘스트 / 위험 알림 / 연속 기록).
class ChildHomeStatCard extends StatelessWidget {
  const ChildHomeStatCard({
    super.key,
    required this.icon,
    required this.valueText,
    required this.label,
  });

  final IconData icon;
  final String valueText;
  final String label;

  /// 시안에 가까운 시에나 톤 숫자·아이콘 색.
  static const _valueColor = Color(0xFFA0522D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ChildDashboardColors.orange.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: _valueColor,
          ),
          const SizedBox(height: 6),
          Text(
            valueText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.1,
              color: _valueColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ChildDashboardColors.textMuted,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
