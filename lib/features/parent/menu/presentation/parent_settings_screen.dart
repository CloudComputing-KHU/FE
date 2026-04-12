import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';

/// 부모 모드 — 설정 (역할 바꾸기 등)
class ParentSettingsScreen extends StatelessWidget {
  const ParentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      appBar: AppBar(
        backgroundColor: ItdaColors.orangePale,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28, color: ItdaColors.text),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '설정',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: ItdaColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ItdaColors.orange.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.swap_horiz_rounded, color: ItdaColors.orangeDark, size: 26),
                title: const Text(
                  '역할 바꾸기',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: ItdaColors.text),
                ),
                subtitle: const Text(
                  '자녀용 · 부모용 전환',
                  style: TextStyle(fontSize: 13, color: ItdaColors.textSub),
                ),
                trailing: const Icon(Icons.chevron_right_rounded, color: ItdaColors.textMuted),
                onTap: () => context.go(AppRoutes.roleSelect),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
