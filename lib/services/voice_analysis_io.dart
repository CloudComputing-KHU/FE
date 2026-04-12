import 'dart:io';

import 'package:itda/services/voice_upload_result.dart';

/// 모바일·데스크톱: 로컬 파일을 읽어 데모 응답을 돌려줍니다.
Future<VoiceUploadResult> triggerVoiceAnalysisUploadFromPath(String path) async {
  await Future<void>.delayed(const Duration(milliseconds: 400));
  final file = File(path);
  if (!await file.exists()) {
    return VoiceUploadResult(ok: false, message: '녹음 파일이 없습니다.');
  }
  return VoiceUploadResult(
    ok: true,
    message: '업로드·분석 요청이 접수되었습니다. (데모 응답)',
    bytes: await file.length(),
  );
}
