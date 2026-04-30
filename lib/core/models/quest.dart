/// 일일·건강 퀘스트 질문 등에 쓰는 DTO.
///
/// 백엔드 응답 (`GET /questions/{type}`) 매핑:
/// - `question_id` → [id]
/// - `text`        → [question]
/// - `type`        → [type]
/// - `options`     → [options]
/// - `allow_voice` → [allowVoice]
class Quest {
  const Quest({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.allowVoice,
  });

  /// 질문 식별자 (BE의 `question_id`)
  final String id;

  /// 질문 본문 (BE의 `text`)
  final String question;

  /// 퀘스트 유형: `health`, `meal`, `mood`
  final String type;

  /// 선택지 목록 (예: ["네, 먹었어요", "아직 안 먹었어요", ...])
  final List<String> options;

  /// 음성 답변 허용 여부
  final bool allowVoice;

  /// JSON → Quest 변환 (BE 응답 파싱용)
  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['question_id'] as String,
      question: json['text'] as String,
      type: json['type'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
      allowVoice: json['allow_voice'] as bool,
    );
  }
}