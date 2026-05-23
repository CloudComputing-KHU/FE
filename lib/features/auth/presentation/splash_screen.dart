/// 앱 첫 화면. 잠시 표시한 뒤 역할 선택(또는 추후 로그인 분기)으로 이동합니다.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/auth/token_storage.dart';
import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/shared/widgets/itda_chrome.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    scheduleMicrotask(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      await TokenStorage.ensureLoaded();
      final hasValidToken = await TokenStorage.hasValidIdToken();
      if (!mounted) return;
      if (!hasValidToken) {
        await TokenStorage.clear();
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      final role = await TokenStorage.readCurrentRole();
      if (!mounted) return;
      if (role == 'child') {
        context.go(AppRoutes.child);
      } else if (role == 'parent') {
        context.go(AppRoutes.parent);
      } else {
        await TokenStorage.clear();
        if (mounted) context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ItdaBrandMark(size: 64),
                const SizedBox(width: 10),
                Text(
                  'itda',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 34,
                    color: AppColors.orangeDark,
                    letterSpacing: -0.4,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '잇다',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
