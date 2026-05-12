/// 자녀 모드 루트. 하단 탭·IndexedStack으로 홈·건강·소통·마이·사진(FAB)을 전환합니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/features/child/chat/presentation/child_chat_screen.dart';
import 'package:itda/features/child/dashboard/presentation/child_home_screen.dart';
import 'package:itda/features/child/health_monitoring/presentation/health_monitoring_screen.dart';
import 'package:itda/features/child/my/presentation/child_my_screen.dart';
import 'package:itda/features/child/photo_upload/presentation/photo_upload_screen.dart';
import 'package:itda/features/child/shell/providers/child_shell_tab_provider.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';

class ChildShell extends ConsumerWidget {
  const ChildShell({super.key});

  void _goRoleGate(BuildContext context) {
    context.go(AppRoutes.roleSelect);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(childShellTabProvider);

    return Scaffold(
      extendBody: true,
      appBar: null,
      body: IndexedStack(
        index: index,
        children: [
          const ChildHomeScreen(),
          HealthMonitoringScreen(),
          ChildChatScreen(),
          ChildMyScreen(onRoleSwitch: () => _goRoleGate(context)),
          const PhotoUploadScreen(),
        ],
      ),
      bottomNavigationBar: ChildHtmlTabBar(
        bodyIndex: index,
        onHome: () => ref.read(childShellTabProvider.notifier).state = 0,
        onHealth: () => ref.read(childShellTabProvider.notifier).state = 1,
        onChat: () => ref.read(childShellTabProvider.notifier).state = 2,
        onMy: () => ref.read(childShellTabProvider.notifier).state = 3,
        onFab: () => ref.read(childShellTabProvider.notifier).state = 4,
      ),
    );
  }
}
