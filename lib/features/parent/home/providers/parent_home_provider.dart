import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 부모 홈 목록 갱신 등에 쓸 버전 카운터. API 연동 시 무효화 트리거로 사용할 수 있습니다.
final parentHomeVersionProvider = StateProvider<int>((ref) => 0);
