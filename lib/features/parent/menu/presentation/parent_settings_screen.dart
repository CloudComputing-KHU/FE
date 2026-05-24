import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/menu/presentation/family_connection_screen.dart';

/// 부모 모드 — 설정 (역할 바꾸기 등)
class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃할까요?'),
        content: const Text('현재 계정에서 로그아웃하고 로그인 화면으로 이동합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    await ref.read(authServiceProvider).signOut();
    ref.invalidate(currentUserProfileProvider);
    if (context.mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            icon: Icons.logout_rounded,
            title: '로그아웃',
            subtitle: '현재 계정에서 나가기',
            color: const Color(0xFFE4473E),
            onTap: () => _logout(context, ref),
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
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? ItdaColors.orangeDark;
    final titleColor = color ?? ItdaColors.text;

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
          leading: Icon(icon, color: effectiveColor, size: 26),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: titleColor,
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
