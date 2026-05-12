import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 회원가입. 폼·역할 선택·BE 연동은 추후 확장합니다.
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('회원가입'),
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '회원가입 폼은 준비 중이에요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSub,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
