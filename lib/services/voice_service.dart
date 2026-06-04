import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecording {
  const VoiceRecording({
    this.filePath,
    this.fileBytes,
    required this.fileName,
    required this.contentType,
  });

  final String? filePath;
  final Uint8List? fileBytes;
  final String fileName;
  final String contentType;
}

/// 원터치 녹음 및 파일 경로 반환 (S3 업로드·AI 트리거는 백엔드 연동 시 호출)
class VoiceService {
  VoiceService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  String? _path;
  String _fileName = 'voice.m4a';
  String _contentType = 'audio/mp4';

  Future<bool> ensureMicPermission() async {
    if (kIsWeb) {
      return _recorder.hasPermission();
    }
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;
    status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      await ensureMicPermission();
    }
    if (kIsWeb) {
      final format = await _resolveWebFormat();
      _fileName =
          'itda_voice_${DateTime.now().millisecondsSinceEpoch}.${format.extension}';
      _contentType = format.contentType;
      _path = _fileName;
      await _recorder.start(
        RecordConfig(encoder: format.encoder),
        path: _path!,
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    _fileName = 'itda_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _contentType = 'audio/mp4';
    _path = '${dir.path}/$_fileName';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: _path!,
    );
  }

  Future<String?> stopRecording() async {
    if (kIsWeb) {
      return (await stopRecordingClip())?.filePath;
    }
    final path = await _recorder.stop();
    return path ?? _path;
  }

  Future<VoiceRecording?> stopRecordingClip() async {
    final location = await _recorder.stop();
    if (kIsWeb) {
      if (location == null) return null;
      final response = await http.get(Uri.parse(location));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      return VoiceRecording(
        filePath: location,
        fileBytes: response.bodyBytes,
        fileName: _fileName,
        contentType: _contentType,
      );
    }
    final path = location ?? _path;
    if (path == null) return null;
    return VoiceRecording(
      filePath: path,
      fileName: _fileName,
      contentType: _contentType,
    );
  }

  Future<bool> recordingActive() => _recorder.isRecording();

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  Future<_VoiceFormat> _resolveWebFormat() async {
    if (await _recorder.isEncoderSupported(AudioEncoder.aacLc)) {
      return const _VoiceFormat(
        encoder: AudioEncoder.aacLc,
        extension: 'm4a',
        contentType: 'audio/mp4',
      );
    }
    if (await _recorder.isEncoderSupported(AudioEncoder.opus)) {
      return const _VoiceFormat(
        encoder: AudioEncoder.opus,
        extension: 'webm',
        contentType: 'audio/webm',
      );
    }
    if (await _recorder.isEncoderSupported(AudioEncoder.wav)) {
      return const _VoiceFormat(
        encoder: AudioEncoder.wav,
        extension: 'wav',
        contentType: 'audio/wav',
      );
    }
    throw StateError('지원되는 웹 녹음 형식을 찾지 못했습니다.');
  }
}

class _VoiceFormat {
  const _VoiceFormat({
    required this.encoder,
    required this.extension,
    required this.contentType,
  });

  final AudioEncoder encoder;
  final String extension;
  final String contentType;
}
