import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 사진 전송 중 여부. 업로드 시작/종료 시 갱신합니다.
final uploadBusyProvider = StateProvider<bool>((ref) => false);
