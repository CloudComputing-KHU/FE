/// 녹음 파일 경로를 넘겨 데모 업로드·분석을 요청합니다. VM/네이티브는 IO, 웹은 스텁입니다.
library;

import 'package:itda/services/voice_analysis_io.dart'
    if (dart.library.html) 'package:itda/services/voice_analysis_stub.dart' as impl;
import 'package:itda/services/voice_upload_result.dart';

Future<VoiceUploadResult> triggerVoiceAnalysisUploadFromPath(String path) =>
    impl.triggerVoiceAnalysisUploadFromPath(path);
