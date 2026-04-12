import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 목록·결과가 없을 때 쓰는 빈 화면 블록.
class ItdaEmptyState extends StatelessWidget {
  const ItdaEmptyState({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSub)),
            ],
          ],
        ),
      ),
    );
  }
}
