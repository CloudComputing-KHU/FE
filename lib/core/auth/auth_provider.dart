import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 로그인 세션 여부. 추후 사용자 엔티티와 함께 확장할 수 있습니다.
final authSessionProvider = StateProvider<bool?>((ref) => null);
