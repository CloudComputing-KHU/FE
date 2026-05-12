import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 자녀 하단 탭 인덱스: 0 홈, 1 건강, 2 소통, 3 마이, 4 사진(FAB).
/// 전체 화면 라우트(예: 알림)에서 복귀 후 특정 탭으로 맞출 때 사용합니다.
final childShellTabProvider = StateProvider<int>((ref) => 0);
