/// 잇다 앱 루트. 기본 테마는 자녀용이며, 라우트에서 부모 모드일 때 [Theme]으로 덮어씁니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/router/app_router.dart';
import 'package:itda/core/theme/app_theme.dart';

class ItdaApp extends ConsumerWidget {
  const ItdaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: '잇다',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.childTheme(),
      routerConfig: router,
    );
  }
}
