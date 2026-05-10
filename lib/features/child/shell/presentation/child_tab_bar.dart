import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 자녀 셸 하단 탭: 홈 · 건강(리포트) · 중앙 FAB(카메라) · 소통 · 프로필(마이).
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

  static const _inactiveIcon = Color(0xFF8D8C8D);
  static const double _iconSize = 26;

  @override
  Widget build(BuildContext context) {
    final fabOn = bodyIndex == 4;
    const fabSize = 54.0;
    // Scaffold의 bottomNavigationBar는 자식 밖으로 그려진 위젯을 잘라낼 수 있어,
    // FAB를 음수 top으로 밀지 않고 이 Stack 높이 안에 모두 넣습니다.
    const stackHeight = fabSize / 2 + 52;

    Widget fabButton() {
      return GestureDetector(
        onTap: onFab,
        child: Container(
          width: fabSize,
          height: fabSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ChildDashboardColors.orange,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: fabOn ? 0.18 : 0.14),
                blurRadius: fabOn ? 12 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/camera.svg',
              width: 26,
              height: 26,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
        ),
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // 상단(FAB 튀어나옴): 크림톤 · 하단 홈 인디케이터 구간: 흰색.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            bottom: false,
            minimum: EdgeInsets.zero,
            child: SizedBox(
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: fabSize / 2 - 6,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 13,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: _NavItem(
                              asset: 'assets/icons/home.svg',
                              active: bodyIndex == 0,
                              inactiveColor: _inactiveIcon,
                              activeColor: ChildDashboardColors.orange,
                              iconSize: _iconSize,
                              onTap: onHome,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              asset: 'assets/icons/report.svg',
                              active: bodyIndex == 1,
                              inactiveColor: _inactiveIcon,
                              activeColor: ChildDashboardColors.orange,
                              iconSize: _iconSize,
                              onTap: onHealth,
                            ),
                          ),
                          const SizedBox(width: 56),
                          Expanded(
                            child: _NavItem(
                              asset: 'assets/icons/chat.svg',
                              active: bodyIndex == 2,
                              inactiveColor: _inactiveIcon,
                              activeColor: ChildDashboardColors.orange,
                              iconSize: _iconSize,
                              onTap: onChat,
                            ),
                          ),
                          Expanded(
                            child: _NavItem(
                              asset: 'assets/icons/profile.svg',
                              active: bodyIndex == 3,
                              inactiveColor: _inactiveIcon,
                              activeColor: ChildDashboardColors.orange,
                              iconSize: _iconSize,
                              onTap: onMy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: fabButton(),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (bottomInset > 0)
          ColoredBox(
            color: Colors.white,
            child: SizedBox(height: bottomInset, width: double.infinity),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.asset,
    required this.active,
    required this.inactiveColor,
    required this.activeColor,
    required this.iconSize,
    required this.onTap,
  });

  final String asset;
  final bool active;
  final Color inactiveColor;
  final Color activeColor;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: SvgPicture.asset(
            asset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
