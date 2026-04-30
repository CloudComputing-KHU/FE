/// 음성 답변 업로드 응답 DTO.
///
/// 백엔드 엔드포인트: `POST /answers/{type}/voice`
/// 파일 수신 직후 [voiceStatus]는 `uploaded`로 시작하며,
/// 백그라운드 STT 분석이 끝나면 `analyzed`로 갱신됩니다.
class VoiceUploadResponse {
  const VoiceUploadResponse({
    required this.message,
    required this.answerId,
    required this.voiceStatus,
    required this.voiceFileKey,
    required this.originalFilename,
    required this.storedFilename,
    required this.fileSize,
    required this.createdAt,
    this.contentType,
  });

  /// 서버 안내 메시지
  final String message;

  /// 저장된 답변의 식별자 (이후 voice_status 폴링·조회에 사용)
  final String answerId;

  /// `uploaded` | `analyzed`
  final String voiceStatus;

  /// S3 객체 키 (예: `s3://bucket/voices/parent_001/xxx.m4a`)
  final String voiceFileKey;

  final String originalFilename;
  final String storedFilename;

  /// `audio/mpeg`, `audio/wav`, `audio/m4a` 등
  final String? contentType;

  /// 바이트 단위
  final int fileSize;

  final DateTime createdAt;

  factory VoiceUploadResponse.fromJson(Map<String, dynamic> json) {
    return VoiceUploadResponse(
      message: json['message'] as String,
      answerId: json['answer_id'] as String,
      voiceStatus: json['voice_status'] as String,
      voiceFileKey: json['voice_file_key'] as String,
      originalFilename: json['original_filename'] as String,
      storedFilename: json['stored_filename'] as String,
      contentType: json['content_type'] as String?,
      fileSize: json['file_size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}