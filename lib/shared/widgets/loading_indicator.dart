import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 브랜드 색 [CircularProgressIndicator]를 가운데 둔 로딩 표시.
class ItdaLoadingIndicator extends StatelessWidget {
  const ItdaLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.orange),
    );
  }
}
