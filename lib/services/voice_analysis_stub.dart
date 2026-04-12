import 'package:itda/services/voice_upload_result.dart';

/// 웹 등 로컬 파일 업로드 데모를 생략할 때 쓰는 구현.
Future<VoiceUploadResult> triggerVoiceAnalysisUploadFromPath(String path) async {
  return VoiceUploadResult(
    ok: false,
    message: '이 플랫폼에서는 로컬 파일 업로드 데모를 건너뜁니다.',
  );
}
