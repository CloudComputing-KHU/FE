import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 로그인 화면. ID 공급자(Cognito 등) 연동 시 폼·콜백을 확장합니다.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      appBar: AppBar(title: const Text('로그인')),
      body: const Center(child: Text('로그인 화면 — 준비 중')),
    );
  }
}
