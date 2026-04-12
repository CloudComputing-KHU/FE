import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 음성 녹음 UI용 플래그. 화면에서 `ref.watch`로 구독합니다.
final voiceRecordingProvider = StateProvider<bool>((ref) => false);
