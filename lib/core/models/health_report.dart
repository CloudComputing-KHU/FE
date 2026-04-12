/// 건강 리포트 요약 DTO. API 스키마에 맞춰 필드를 늘리면 됩니다.
class HealthReport {
  const HealthReport({
    required this.id,
    required this.summary,
  });

  final String id;
  final String summary;
}
