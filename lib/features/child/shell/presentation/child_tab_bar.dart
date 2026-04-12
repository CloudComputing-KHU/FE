import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 자녀 셸 하단 탭: 홈 · 건강 · 중앙 FAB(사진) · 소통 · 마이.
class ChildHtmlTabBar extends StatelessWidget {
  const ChildHtmlTabBar({
    super.key,
    required this.bodyIndex,
    required this.onHome,
    required this.onHealth,
    required this.onChat,
    required this.onMy,
    required this.onFab,
  });

  /// 0 홈, 1 건강, 2 소통, 3 마이, 4 사진(FAB)
  final int bodyIndex;
  final VoidCallback onHome;
  final VoidCallback onHealth;
  final VoidCallback onChat;
  final VoidCallback onMy;
  final VoidCallback onFab;

  @override
  Widget build(BuildContext context) {
    final fabOn = bodyIndex == 4;

    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.zero,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF2DCB0)),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _NavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home_rounded,
                      label: '홈',
                      active: bodyIndex == 0,
                      onTap: onHome,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.auto_graph_outlined,
                      activeIcon: Icons.auto_graph_rounded,
                      label: '건강',
                      active: bodyIndex == 1,
                      onTap: onHealth,
                    ),
                  ),
                  const SizedBox(width: 56),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      activeIcon: Icons.chat_bubble_rounded,
                      label: '소통',
                      active: bodyIndex == 2,
                      onTap: onChat,
                    ),
                  ),
                  Expanded(
                    child: _NavItem(
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: '마이',
                      active: bodyIndex == 3,
                      onTap: onMy,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -22,
              child: GestureDetector(
                onTap: onFab,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
                        color: ChildDashboardColors.orange.withValues(alpha: fabOn ? 0.55 : 0.45),
                        blurRadius: fabOn ? 22 : 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? ChildDashboardColors.orange : ChildDashboardColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
