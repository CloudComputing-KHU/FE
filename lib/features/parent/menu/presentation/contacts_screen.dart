import 'package:flutter/material.dart';

import 'package:itda/core/theme/app_colors.dart';

/// 연락처 목록. 아직 라우터에 연결되지 않은 플레이스홀더입니다.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePale,
      appBar: AppBar(title: const Text('연락처')),
      body: const Center(child: Text('연락처 — 준비 중')),
    );
  }
}
