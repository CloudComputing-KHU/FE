import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/features/child/health_monitoring/providers/health_provider.dart'
    show parentAnswersProvider;

/// 자녀 대시보드 탭 인덱스 등 내부 상태. 필요 시 화면과 연결합니다.
final dashboardTabProvider = StateProvider<int>((ref) => 0);

// ── 오늘의 퀘스트 응답 상태 ──────────────────────────────────────────────────

/// 오늘의 퀘스트 한 줄 (대시보드 카드용).
class TodayQuestStatus {
  const TodayQuestStatus({
    required this.type,
    required this.label,
    required this.responded,
    this.answerPreview,
  });

  /// API type: 'health' | 'meal' | 'mood'
  final String type;

  /// 화면 표시용 한국어 라벨
  final String label;

  /// 오늘 부모가 응답했는지 여부
  final bool responded;

  /// 응답 텍스트 미리보기 (없으면 null)
  final String? answerPreview;
}

/// `parentAnswersProvider(type)`을 3개 type 다 watch해서
/// 오늘자 응답 여부로 합성합니다.
/// - 모든 fetch가 완료되어야 data 상태로 진입.
/// - 하나라도 로딩 중이면 loading.
/// - 하나라도 에러면 error.
final todayQuestsProvider = Provider.autoDispose<AsyncValue<List<TodayQuestStatus>>>((ref) {
  const types = [
    ('health', '건강 퀘스트'),
    ('meal', '식사 퀘스트'),
    ('mood', '기분 퀘스트'),
  ];

  final results = <TodayQuestStatus>[];
  for (final (type, label) in types) {
    final asyncAnswers = ref.watch(parentAnswersProvider(type));
    if (asyncAnswers.isLoading) {
      return const AsyncLoading();
    }
    if (asyncAnswers.hasError) {
      return AsyncError(
        asyncAnswers.error!,
        asyncAnswers.stackTrace ?? StackTrace.current,
      );
    }
    final list = asyncAnswers.value ?? const [];
    final today = DateTime.now();
    final todayAnswer = list.where((a) {
      final d = a.createdAt;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).firstOrNull;

    results.add(TodayQuestStatus(
      type: type,
      label: label,
      responded: todayAnswer != null,
      answerPreview: todayAnswer?.answer,
    ));
  }
  return AsyncData(results);
});