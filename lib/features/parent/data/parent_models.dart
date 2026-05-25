/// parent 기능에서 사용하는 API 응답 모델들.
/// 백엔드 스키마(app/schemas/)와 1:1 대응합니다.
library;

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

class ParentQuestionStatus {
  const ParentQuestionStatus({
    required this.userId,
    required this.healthAnswered,
    required this.mealAnswered,
    required this.moodAnswered,
    required this.completedCount,
    required this.nextType,
    required this.allAnswered,
  });

  final String userId;
  final bool healthAnswered;
  final bool mealAnswered;
  final bool moodAnswered;
  final int completedCount;
  final String nextType;
  final bool allAnswered;

  int get completedStep => allAnswered ? 3 : completedCount.clamp(0, 3);

  int get nextStep {
    if (allAnswered) return 3;
    switch (nextType) {
      case 'meal':
        return 1;
      case 'mood':
        return 2;
      case 'health':
      default:
        return 0;
    }
  }

  factory ParentQuestionStatus.fromJson(Map<String, dynamic> json) {
    return ParentQuestionStatus(
      userId: json['user_id'] as String? ?? '',
      healthAnswered: json['health_answered'] as bool? ?? false,
      mealAnswered: json['meal_answered'] as bool? ?? false,
      moodAnswered: json['mood_answered'] as bool? ?? false,
      completedCount: json['completed_count'] as int? ?? 0,
      nextType: json['next_type'] as String? ?? 'health',
      allAnswered: json['all_answered'] as bool? ?? false,
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
