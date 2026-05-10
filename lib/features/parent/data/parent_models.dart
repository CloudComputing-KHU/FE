/// parent 기능에서 사용하는 API 응답 모델들.
/// 백엔드 스키마(app/schemas/)와 1:1 대응합니다.

class ParentQuestion {
  const ParentQuestion({
    required this.questionId,
    required this.type,
    required this.text,
    required this.options,
    required this.allowVoice,
  });

  final String questionId;
  final String type;
  final String text;
  final List<String> options;
  final bool allowVoice;

  factory ParentQuestion.fromJson(Map<String, dynamic> json) {
    return ParentQuestion(
      questionId: json['question_id'] as String,
      type: json['type'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      allowVoice: json['allow_voice'] as bool? ?? false,
    );
  }
}

class ParentVoiceUploadResult {
  const ParentVoiceUploadResult({
    required this.message,
    required this.answerId,
    required this.voiceStatus,
  });

  final String message;
  final String answerId;
  final String voiceStatus;

  factory ParentVoiceUploadResult.fromJson(Map<String, dynamic> json) {
    return ParentVoiceUploadResult(
      message: json['message'] as String,
      answerId: json['answer_id'] as String,
      voiceStatus: json['voice_status'] as String,
    );
  }
}

class ParentReceivedPhoto {
  const ParentReceivedPhoto({
    required this.photoId,
    required this.senderUserId,
    required this.receiverUserId,
    required this.imageUrl,
    this.presignedUrl,
    this.caption,
    this.scheduledAt,
    required this.status,
    required this.createdAt,
  });

  final String photoId;
  final String senderUserId;
  final String receiverUserId;

  /// S3 경로 (표시용으로는 [presignedUrl] 우선 사용)
  final String imageUrl;

  /// 서명된 임시 URL. 있으면 이미지 로드에 사용합니다.
  final String? presignedUrl;
  final String? caption;
  final DateTime? scheduledAt;
  final String status;
  final DateTime createdAt;

  /// 실제 이미지를 로드할 URL. presigned_url이 있으면 우선 사용합니다.
  String get displayUrl => presignedUrl ?? imageUrl;

  factory ParentReceivedPhoto.fromJson(Map<String, dynamic> json) {
    return ParentReceivedPhoto(
      photoId: json['photo_id'] as String,
      senderUserId: json['sender_user_id'] as String,
      receiverUserId: json['receiver_user_id'] as String,
      imageUrl: json['image_url'] as String,
      presignedUrl: json['presigned_url'] as String?,
      caption: json['caption'] as String?,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : null,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
