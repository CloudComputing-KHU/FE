/// 자녀 모드 루트. 하단 탭·IndexedStack으로 홈·건강·소통·마이·사진(FAB)을 전환합니다.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:itda/core/router/routes.dart';
import 'package:itda/features/child/chat/presentation/child_chat_screen.dart';
import 'package:itda/features/child/dashboard/presentation/child_home_screen.dart';
import 'package:itda/features/child/health_monitoring/presentation/health_monitoring_screen.dart';
import 'package:itda/features/child/my/presentation/child_my_screen.dart';
import 'package:itda/features/child/photo_upload/presentation/photo_upload_screen.dart';
import 'package:itda/features/child/shell/presentation/child_tab_bar.dart';

class ChildShell extends StatefulWidget {
  const ChildShell({super.key});

  @override
  State<ChildShell> createState() => _ChildShellState();
}

class _ChildShellState extends State<ChildShell> {
  /// 0 홈, 1 건강, 2 소통, 3 마이, 4 사진(FAB)
  int _index = 0;

  void _goRoleGate() {
    context.go(AppRoutes.roleSelect);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: null,
      body: IndexedStack(
        index: _index,
        children: [
          ChildHomeScreen(
            onOpenHealthTab: () => setState(() => _index = 1),
            onRoleSwitch: _goRoleGate,
          ),
          HealthMonitoringScreen(),
          ChildChatScreen(),
          ChildMyScreen(onRoleSwitch: _goRoleGate),
          PhotoUploadScreen(onRoleSwitch: _goRoleGate),
        ],
      ),
      bottomNavigationBar: ChildHtmlTabBar(
        bodyIndex: _index,
        onHome: () => setState(() => _index = 0),
        onHealth: () => setState(() => _index = 1),
        onChat: () => setState(() => _index = 2),
        onMy: () => setState(() => _index = 3),
        onFab: () => setState(() => _index = 4),
      ),
    );
  }
}
