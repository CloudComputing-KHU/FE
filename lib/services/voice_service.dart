import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// 원터치 녹음 및 파일 경로 반환 (S3 업로드·AI 트리거는 백엔드 연동 시 호출)
class VoiceService {
  VoiceService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _path;

  Future<bool> ensureMicPermission() async {
    if (kIsWeb) return false;
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (kIsWeb) return;
    if (!await _recorder.hasPermission()) {
      await ensureMicPermission();
    }
    final dir = await getTemporaryDirectory();
    _path = '${dir.path}/itda_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _path!);
  }

  Future<String?> stopRecording() async {
    if (kIsWeb) return null;
    final path = await _recorder.stop();
    return path ?? _path;
  }

  Future<bool> recordingActive() => _recorder.isRecording();

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
