import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

/// 자녀 홈 탭 — 로고·알림 등 전체 [ChildShellHeader].
class ChildHomeSliverHeader extends StatelessWidget {
  const ChildHomeSliverHeader({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ChildShellHeader(onNotificationTap: onNotificationTap),
    );
  }
}
