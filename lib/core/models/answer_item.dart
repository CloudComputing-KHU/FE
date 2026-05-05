/// 답변 항목 DTO. 텍스트 답변과 음성 답변 모두 표현합니다.
///
/// 백엔드 응답 (`GET /answers/{type}?user_id=...`) 매핑.
/// 텍스트 답변일 때는 [answer]만 채워지고 voice_* 필드는 null,
/// 음성 답변일 때는 voice_* 필드들이 채워지고 [answer]는 null인 식으로 옵니다.
class AnswerItem {
  const AnswerItem({
    required this.answerId,
    required this.userId,
    required this.questionId,
    required this.type,
    required this.answerType,
    required this.createdAt,
    this.answer,
    this.voiceStatus,
    this.voiceFileKey,
    this.voiceUrl,
    this.originalFilename,
    this.storedFilename,
    this.contentType,
    this.fileSize,
  });

  final String answerId;
  final String userId;
  final String questionId;

  /// 퀘스트 유형: `health`, `meal`, `mood`
  final String type;

  /// 답변 형태: `text` 또는 `voice`
  final String answerType;

  final DateTime createdAt;

  // 텍스트 답변 시
  final String? answer;

  // 음성 답변 시
  final String? voiceStatus;
  final String? voiceFileKey;

  /// S3 presigned URL — 7일간 유효. 자녀 화면에서 부모 음성 답변을
  /// 바로 재생할 때 사용.
  final String? voiceUrl;

  final String? originalFilename;
  final String? storedFilename;
  final String? contentType;
  final int? fileSize;

  /// 음성 답변 여부 편의 게터
  bool get isVoice => answerType == 'voice';

  factory AnswerItem.fromJson(Map<String, dynamic> json) {
    return AnswerItem(
      answerId: json['answer_id'] as String,
      userId: json['user_id'] as String,
      questionId: json['question_id'] as String,
      type: json['type'] as String,
      answerType: json['answer_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      answer: json['answer'] as String?,
      voiceStatus: json['voice_status'] as String?,
      voiceFileKey: json['voice_file_key'] as String?,
      voiceUrl: json['voice_url'] as String?,
      originalFilename: json['original_filename'] as String?,
      storedFilename: json['stored_filename'] as String?,
      contentType: json['content_type'] as String?,
      fileSize: json['file_size'] as int?,
    );
  }
}