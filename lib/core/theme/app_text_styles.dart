import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 자녀·부모 화면 공통 텍스트 스타일 모음. 타이포를 맞출 때 여기서 재사용합니다.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle childHeadline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.2,
  );

  static const TextStyle parentHeadlineLarge = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.text,
  );

  static const TextStyle parentBodyLarge = TextStyle(
    fontSize: 21,
    height: 1.35,
    color: AppColors.text,
  );
}
