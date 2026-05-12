import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 주황색 풀폭 주요 액션 버튼 (로그인·가입 등).
class ItdaPrimaryButton extends StatelessWidget {
  const ItdaPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
