import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 햄버거 메뉴 드로어. 라우트 연결 전 플레이스홀더입니다.
class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.orangeLight),
            child: const Text('메뉴', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const ListTile(title: Text('연락처')),
          const ListTile(title: Text('지난 사진')),
        ],
      ),
    );
  }
}
