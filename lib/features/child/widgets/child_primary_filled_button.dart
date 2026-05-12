import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_colors.dart';

/// 자녀 화면용 주황 [FilledButton]. 너비는 부모 제약에 맞춥니다.
class ChildPrimaryFilledButton extends StatelessWidget {
  const ChildPrimaryFilledButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expandWidth = true,
    this.isLoading = false,
    this.loadingLabel,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(vertical: 14),
    this.boxShadow,
    this.labelFontWeight = FontWeight.w700,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expandWidth;
  final bool isLoading;
  final String? loadingLabel;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final FontWeight labelFontWeight;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = isLoading ? (loadingLabel ?? label) : label;

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: ChildDashboardColors.orange,
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: isLoading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  effectiveLabel,
                  style: TextStyle(
                    fontWeight: labelFontWeight,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          : Text(
              label,
              style: TextStyle(
                fontWeight: labelFontWeight,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
    );

    Widget wrapped = !expandWidth ? button : SizedBox(width: double.infinity, child: button);

    final shadows = boxShadow;
    if (shadows != null && shadows.isNotEmpty) {
      wrapped = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: shadows,
        ),
        child: wrapped,
      );
    }

    return wrapped;
  }
}
