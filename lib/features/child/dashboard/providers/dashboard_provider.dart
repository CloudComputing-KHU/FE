import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 자녀 대시보드 탭 인덱스 등 내부 상태. 필요 시 화면과 연결합니다.
final dashboardTabProvider = StateProvider<int>((ref) => 0);
