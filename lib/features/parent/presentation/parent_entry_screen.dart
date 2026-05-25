import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/theme/app_colors.dart';
import 'package:itda/features/parent/home/presentation/parent_home_screen.dart';
import 'package:itda/features/parent/menu/presentation/family_connection_screen.dart';
import 'package:itda/features/shared/providers/family_provider.dart';

/// 부모 계정 진입 게이트.
///
/// 가족 연결 전에는 초대 코드 입력 화면을 먼저 보여주고,
/// 연결이 완료된 뒤에는 부모 홈 화면으로 진입합니다.
class ParentEntryScreen extends ConsumerWidget {
  const ParentEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyMeProvider);

    return familyState.when(
      loading: () => const Scaffold(
        backgroundColor: ItdaColors.orangePale,
        body: Center(
          child: CircularProgressIndicator(color: ItdaColors.orange),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: ItdaColors.orangePale,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '가족 연결 상태를 불러오지 못했어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => ref.invalidate(familyMeProvider),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      data: (family) {
        if (family.isConnected) {
          return const ParentHomeScreen();
        }
        return FamilyConnectionScreen(
          showBackButton: false,
          showLogoutButton: true,
          onConnected: () => ref.invalidate(familyMeProvider),
        );
      },
    );
  }
}
