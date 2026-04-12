import 'package:flutter/material.dart';

/// 흰 둥근 사각형 + 그림자. [label]이 있으면 아이콘+문구 칩, 없으면 [size] 정사각 버튼.
class RoundWhiteIconButton extends StatelessWidget {
  const RoundWhiteIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.size = 52,
    this.borderRadius = 16,
    this.iconSize = 28,
    this.labelFontSize = 15,
  });

  final VoidCallback onPressed;
  final IconData icon;
  /// 예: `뒤로가기`
  final String? label;
  final double size;
  final double borderRadius;
  final double iconSize;
  final double labelFontSize;

  static const _iconColor = Color(0xFF2D1F0A);
  static const _shadowSoft = BoxShadow(
    color: Color(0x1AEF9F27),
    blurRadius: 14,
    offset: Offset(0, 3),
  );

  @override
  Widget build(BuildContext context) {
    final labeled = label != null && label!.isNotEmpty;

    final child = labeled
        ? Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 14, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize, color: _iconColor),
                const SizedBox(width: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w800,
                    color: _iconColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          )
        : Icon(icon, size: iconSize, color: _iconColor);

    final material = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: Container(
        width: labeled ? null : size,
        height: size,
        constraints: labeled
            ? BoxConstraints(minHeight: size, maxHeight: size)
            : null,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: const [_shadowSoft],
        ),
        alignment: labeled ? Alignment.center : null,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: labeled
              ? SizedBox(height: size, child: Center(child: child))
              : Center(child: child),
        ),
      ),
    );

    return labeled ? IntrinsicWidth(child: material) : material;
  }
}
