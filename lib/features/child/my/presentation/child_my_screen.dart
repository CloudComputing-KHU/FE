import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/auth/auth_provider.dart';
import 'package:itda/core/data/mock_itda_data.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';
import 'package:itda/features/child/widgets/child_widgets.dart';

/// 마이 탭 — 자녀 셸 팔레트·탭 헤더(가운데 제목)와 맞춤
class ChildMyScreen extends ConsumerWidget {
  const ChildMyScreen({super.key, this.onRoleSwitch});

  final VoidCallback? onRoleSwitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPad = ChildHtmlTabBar.scrollBottomPadding(context);
    final profile = ref.watch(currentUserProfileProvider).valueOrNull;
    final displayName = profile?.displayName ?? MockItdaData.childDisplayName;
    final email = profile?.email ?? '이메일 정보 없음';
    final roleText =
        '${profile?.accountLabel ?? '자녀 계정'} · ${profile?.roleLabel ?? '자녀용 앱'}';

    return ColoredBox(
      color: ChildDashboardColors.orangePale,
      child: CustomScrollView(
        slivers: [
          const ChildTabSliverHeader(title: '프로필'),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ChildDashboardColors.orange,
                        ChildDashboardColors.orangeMid,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ChildDashboardColors.orange.withValues(
                          alpha: 0.22,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: const Text('👤', style: TextStyle(fontSize: 34)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$displayName님',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              roleText,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const ChildSectionHeader(title: '설정'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: Column(
                    children: [
                      _MyTile(
                        icon: Icons.notifications_outlined,
                        title: '알림 설정',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _MyTile(
                        icon: Icons.lock_outline_rounded,
                        title: '개인정보 · 보안',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _MyTile(
                        icon: Icons.help_outline_rounded,
                        title: '고객센터',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const ChildSectionHeader(title: '가족'),
                const SizedBox(height: 10),
                ChildItdaPanel(
                  child: Column(
                    children: [
                      _MyTile(
                        icon: Icons.family_restroom_rounded,
                        title: '${MockItdaData.parentDisplayName}님 연결 관리',
                        subtitle: '돌봄 대상 · 알림 수신',
                        onTap: () {},
                      ),
                      if (onRoleSwitch != null) ...[
                        const Divider(height: 1),
                        _MyTile(
                          icon: Icons.swap_horiz_rounded,
                          title: '역할 전환',
                          subtitle: '부모용 · 자녀용 선택',
                          onTap: onRoleSwitch!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '잇다 자녀용 v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: ChildDashboardColors.textMuted,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyTile extends StatelessWidget {
  const _MyTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ChildDashboardColors.orangeLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: ChildDashboardColors.orangeDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: ChildDashboardColors.text,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ChildDashboardColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: ChildDashboardColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
