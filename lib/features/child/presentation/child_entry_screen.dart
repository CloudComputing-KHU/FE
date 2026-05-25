import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/features/child/my/presentation/parent_connection_screen.dart';
import 'package:itda/features/child/shell/presentation/child_colors.dart';
import 'package:itda/features/child/shell/presentation/child_shell.dart';
import 'package:itda/features/shared/providers/family_provider.dart';

class ChildEntryScreen extends ConsumerWidget {
  const ChildEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyMeProvider);

    return familyState.when(
      loading: () => const Scaffold(
        backgroundColor: ChildDashboardColors.orangePale,
        body: Center(
          child: CircularProgressIndicator(color: ChildDashboardColors.orange),
        ),
      ),
      error: (_, _) => Scaffold(
        backgroundColor: ChildDashboardColors.orangePale,
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
                      color: ChildDashboardColors.text,
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
          return const ChildShell();
        }
        return const ParentConnectionScreen(
          showBackButton: false,
          showLogoutButton: true,
        );
      },
    );
  }
}
