/// 자녀·부모 역할을 고르고 각 모드 라우트로 이동합니다.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/shared/widgets/itda_chrome.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ItdaColors.orangePale,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ItdaBrandMark(size: 48),
                  const SizedBox(width: 8),
                  const Text(
                    'itda',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      color: ItdaColors.orangeDark,
                      letterSpacing: -0.35,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '잇다',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: ItdaColors.text,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '가족의 하루를 잇다',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ItdaColors.textSub,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Column(
                  children: [
                    _RoleCard(
                      icon: Icons.family_restroom_rounded,
                      title: '자녀용',
                      subtitle: '건강 요약 · 사진 보내기 · 리포트',
                      accent: ItdaColors.orange,
                      onTap: () => context.go(AppRoutes.child),
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      icon: Icons.elderly_rounded,
                      title: '부모용',
                      subtitle: '큰 글씨 · 사진 확인 · 음성 답장',
                      accent: ItdaColors.orangeDark,
                      onTap: () => context.go(AppRoutes.parent),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => context.go(AppRoutes.login),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 13,
                        ),
                        label: const Text('로그인으로'),
                        style: TextButton.styleFrom(
                          foregroundColor: ItdaColors.textSub,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '각 모드 상단에서 역할을 바꿀 수 있어요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: ItdaColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ItdaColors.orange.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 40, color: accent),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: ItdaColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: ItdaColors.textSub,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: accent, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
