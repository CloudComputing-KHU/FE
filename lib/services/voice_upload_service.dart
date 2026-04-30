import 'package:dio/dio.dart';

import 'package:itda/core/api/api_endpoints.dart';
import 'package:itda/services/voice_upload_response.dart';

/// 음성 답변 업로드 API 클라이언트.
///
/// 녹음 자체는 [VoiceService]가 책임지고, 이 서비스는
/// 녹음 결과 파일을 백엔드에 업로드하는 역할만 합니다.
class VoiceUploadService {
  VoiceUploadService(this._dio);

  final Dio _dio;

  /// 녹음 파일을 백엔드에 업로드.
  ///
  /// [filePath]는 `VoiceService.stopRecording()`이 반환하는 로컬 경로.
  /// 지원 확장자는 `.mp3`, `.wav`, `.m4a` (10MB 이하).
  Future<VoiceUploadResponse> uploadVoice({
    required String type,
    required String userId,
    required String questionId,
    required String filePath,
  }) async {
    final formData = FormData.fromMap({
      'user_id': userId,
      'question_id': questionId,
      'file': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post(
      ApiEndpoints.voiceAnswer(type),
      data: formData,
    );

    return VoiceUploadResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}