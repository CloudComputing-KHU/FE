import 'package:flutter/material.dart';

import 'package:itda/features/child/shell/presentation/child_shell_chrome.dart';

/// 가운데 제목만 있는 자녀 탭 상단 헤더를 [SliverToBoxAdapter]로 감쌉니다.
class ChildTabSliverHeader extends StatelessWidget {
  const ChildTabSliverHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: ChildShellHeader(
        centerTitle: title,
        showChildActions: false,
      ),
    );
  }
}
