/// [GoRouter]와 [goRouterProvider] 정의. 스플래시·온보딩·로그인·역할 선택·자녀/부모 셸을 연결합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/core/theme/app_theme.dart';
import 'package:itda/features/auth/presentation/login_screen.dart';
import 'package:itda/features/auth/presentation/sign_up_screen.dart';
import 'package:itda/features/auth/presentation/onboarding_screen.dart';
import 'package:itda/features/auth/presentation/role_select_screen.dart';
import 'package:itda/features/auth/presentation/splash_screen.dart';
import 'package:itda/features/child/notifications/presentation/child_notifications_screen.dart';
import 'package:itda/features/child/shell/presentation/child_shell.dart';
import 'package:itda/features/parent/home/presentation/parent_home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.roleSelect,
        builder: (context, state) => const RoleSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.child,
        builder: (context, state) =>
            Theme(data: AppTheme.childTheme(), child: const ChildShell()),
      ),
      GoRoute(
        path: AppRoutes.childNotifications,
        builder: (context, state) => Theme(
          data: AppTheme.childTheme(),
          child: const ChildNotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.parent,
        builder: (context, state) => Theme(
          data: AppTheme.parentTheme(),
          child: const ParentHomeScreen(),
        ),
      ),
    ],
  );
});
