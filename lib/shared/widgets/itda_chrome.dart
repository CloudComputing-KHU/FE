import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

enum ItdaHeaderStyle { child, parent }

/// 브랜드 마크. 두 겹 원형 스트로크(기본 36×36 논리 픽셀).
class ItdaBrandMark extends StatelessWidget {
  const ItdaBrandMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ItdaBrandMarkPainter()),
    );
  }
}

class _ItdaBrandMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sw = 7 * sx;
    final pOrange = Paint()
      ..color = ItdaColors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    final pMid = Paint()
      ..color = ItdaColors.orangeMid
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(38 * sx, 50 * sx), 18 * sx, pOrange);
    canvas.drawCircle(Offset(62 * sx, 50 * sx), 18 * sx, pMid);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 자녀: 알림·설정·역할 / 부모: 큰 로고·역할만
///
/// [centerTitle]이 있으면(자녀 탭) 로고 대신 가운데 제목만 표시합니다.
class ItdaShellHeader extends StatelessWidget {
  const ItdaShellHeader({
    super.key,
    this.onRoleSwitch,
    this.style = ItdaHeaderStyle.child,
    this.centerTitle,
    this.showChildActions = true,
  });

  final VoidCallback? onRoleSwitch;
  final ItdaHeaderStyle style;

  /// 자녀 앱에서 탭별 가운데 제목(예: 소통, 건강 리포트).
  final String? centerTitle;

  /// `false`면 알림·설정·역할 전환 버튼을 숨깁니다(가운데 제목 헤더용).
  final bool showChildActions;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final isParent = style == ItdaHeaderStyle.parent;
    final markSize = isParent ? 42.0 : 36.0;
    final brandSize = isParent ? 24.0 : 22.0;
    final iconBox = isParent ? 44.0 : 40.0;
    final iconSz = isParent ? 22.0 : 20.0;
    final headerPad = EdgeInsets.fromLTRB(22, top + 14, 22, 8);

    final trailing = <Widget>[
      if (!isParent) ...[
        _HeaderIconBtn(
          size: iconBox,
          iconSize: iconSz,
          icon: Icons.notifications_outlined,
          showDot: true,
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _HeaderIconBtn(
          size: iconBox,
          iconSize: iconSz,
          icon: Icons.settings_outlined,
          onTap: () {},
        ),
      ],
      if (onRoleSwitch != null) ...[
        const SizedBox(width: 8),
        _HeaderIconBtn(
          size: iconBox,
          iconSize: iconSz,
          icon: Icons.swap_horiz_rounded,
          onTap: onRoleSwitch,
        ),
      ],
    ];

    final trimmedCenter = centerTitle?.trim();
    final useCenterTitle = !isParent && trimmedCenter != null && trimmedCenter.isNotEmpty;

    if (useCenterTitle) {
      if (!showChildActions) {
        return Padding(
          padding: headerPad,
          child: Center(
            child: Text(
              trimmedCenter,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: ItdaColors.orangeDark,
              ),
            ),
          ),
        );
      }
      return Padding(
        padding: headerPad,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: trailing,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 112),
              child: Text(
                trimmedCenter,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: ItdaColors.orangeDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: headerPad,
      child: Row(
        children: [
          ItdaBrandMark(size: markSize),
          const SizedBox(width: 8),
          Text(
            'itda',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: brandSize,
              color: ItdaColors.orangeDark,
              height: 1.1,
              letterSpacing: -0.3,
            ),
          ),
          if (isParent) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ItdaColors.orangeLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '부모용',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ItdaColors.orangeDark,
                ),
              ),
            ),
          ],
          const Spacer(),
          ...trailing,
        ],
      ),
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  const _HeaderIconBtn({
    required this.size,
    required this.iconSize,
    required this.icon,
    this.showDot = false,
    this.onTap,
  });

  final double size;
  final double iconSize;
  final IconData icon;
  final bool showDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ItdaColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, size: iconSize, color: ItdaColors.textSub)),
              if (showDot)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: ItdaColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItdaSectionHeader extends StatelessWidget {
  const ItdaSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailing,
    this.titleSize = 15,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailing;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: titleSize,
              color: ItdaColors.text,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            GestureDetector(
              onTap: onTrailing,
              child: Text(
                trailing!,
                style: TextStyle(
                  fontSize: titleSize > 16 ? 13 : 11,
                  fontWeight: FontWeight.w700,
                  color: ItdaColors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ItdaPanel extends StatelessWidget {
  const ItdaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ItdaColors.orange.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

typedef ChildShellHeader = ItdaShellHeader;
typedef ChildSectionHeader = ItdaSectionHeader;
typedef ChildItdaPanel = ItdaPanel;
