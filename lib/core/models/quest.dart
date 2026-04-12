/// 일일·건강 퀘스트 질문 등에 쓰는 최소 DTO.
class Quest {
  const Quest({
    required this.id,
    required this.question,
  });

  final String id;
  final String question;
}
