import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/menu/presentation/family_connection_screen.dart';

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
          icon: const Icon(
            Icons.chevron_left_rounded,
            size: 28,
            color: ItdaColors.text,
          ),
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
          _SettingsTile(
            icon: Icons.family_restroom_rounded,
            title: '가족 연결 관리',
            subtitle: '초대 코드 입력 · 자녀 연결',
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const FamilyConnectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _SettingsTile(
            icon: Icons.swap_horiz_rounded,
            title: '역할 바꾸기',
            subtitle: '자녀용 · 부모용 전환',
            onTap: () => context.go(AppRoutes.roleSelect),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: Icon(icon, color: ItdaColors.orangeDark, size: 26),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: ItdaColors.text,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: ItdaColors.textSub),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: ItdaColors.textMuted,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
