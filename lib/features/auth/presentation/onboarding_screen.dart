import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 온보딩 화면. 콘텐츠·분기는 추후 연동 예정입니다.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      appBar: AppBar(title: const Text('시작하기')),
      body: const Center(child: Text('온보딩 화면 — 준비 중')),
    );
  }
}
