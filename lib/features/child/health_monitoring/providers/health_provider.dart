import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 건강 리포트 화면 새로고침 트리거(카운터). Pull-to-refresh 등과 연결할 때 사용합니다.
final healthRefreshProvider = StateProvider<int>((ref) => 0);
