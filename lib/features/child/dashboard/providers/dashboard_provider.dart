import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/child/health_monitoring/providers/health_provider.dart'
    show parentAnswersProvider, parentDementiaHistoryProvider;

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
final todayQuestsProvider =
    Provider.autoDispose<AsyncValue<List<TodayQuestStatus>>>((ref) {
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
          final d = a.createdAt.toLocal();
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        }).firstOrNull;

        results.add(
          TodayQuestStatus(
            type: type,
            label: label,
            responded: todayAnswer != null,
            answerPreview: todayAnswer?.answer,
          ),
        );
      }
      return AsyncData(results);
    });

// ── 대시보드 요약 — 응답 완료 카운트 ─────────────────────────────────────────

/// "응답 완료 X/3" 타일에 쓸 값.
/// 로딩/에러 상황에선 0/3으로 폴백 (UI는 mock처럼 보이지만 실 데이터로 점진 갱신).
final answeredCountTodayProvider = Provider.autoDispose<int>((ref) {
  final async = ref.watch(todayQuestsProvider);
  return async.maybeWhen(
    data: (list) => list.where((q) => q.responded).length,
    orElse: () => 0,
  );
});

/// 부모가 health/meal/mood 3개 질문을 모두 답한 날짜를 기준으로 계산한 연속 기록.
/// 오늘 3개가 모두 완료되지 않았으면 0일부터 시작합니다.
final questStreakProvider = Provider.autoDispose<int>((ref) {
  const types = ['health', 'meal', 'mood'];
  final completedDatesByType = <String, Set<DateTime>>{};

  for (final type in types) {
    final asyncAnswers = ref.watch(parentAnswersProvider(type));
    final answers = asyncAnswers.valueOrNull;
    if (answers == null) return 0;
    completedDatesByType[type] = {
      for (final answer in answers) _dateOnly(answer.createdAt.toLocal()),
    };
  }

  var cursor = _dateOnly(DateTime.now());
  var streak = 0;
  while (types.every((type) => completedDatesByType[type]!.contains(cursor))) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

// ── 대시보드 요약 — 위험 알림 카운트 ─────────────────────────────────────────

/// `parentDementiaHistoryProvider`에서 risk_level이 medium/high인 항목 수.
final riskAlertCountProvider = Provider.autoDispose<int>((ref) {
  final async = ref.watch(parentDementiaHistoryProvider);
  return async.maybeWhen(
    data: (items) => items
        .where(
          (i) =>
              i.riskLevel == RiskLevel.medium || i.riskLevel == RiskLevel.high,
        )
        .length,
    orElse: () => 0,
  );
});

// ── 대시보드 위험 알림 카드 — 최근 medium/high 항목들 ────────────────────────

/// 위험 알림 카드 섹션에 표시할 최신 medium/high 분석 결과들 (최대 [limit]개).
final recentRiskAlertsProvider =
    Provider.autoDispose<AsyncValue<List<DementiaAnalysisItem>>>((ref) {
      final async = ref.watch(parentDementiaHistoryProvider);
      return async.whenData((items) {
        final risky = items
            .where(
              (i) =>
                  i.riskLevel == RiskLevel.medium ||
                  i.riskLevel == RiskLevel.high,
            )
            .take(2)
            .toList();
        return risky;
      });
    });
