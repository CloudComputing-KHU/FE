import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/models/answer_item.dart';
import 'package:itda/core/models/dementia_analysis.dart';
import 'package:itda/features/child/data/child_repository.dart';

// ── 공용 Repository 인스턴스 ────────────────────────────────────────────────

final childRepositoryProvider = Provider<ChildRepository>(
  (_) => ChildRepository(),
);

// ── 건강 리포트 화면 — 부모 답변 목록 ────────────────────────────────────────

/// `type`별로 부모의 답변 목록을 캐시합니다.
/// `health`, `meal`, `mood` 어느 것이든 같은 패턴으로 사용합니다.
class ParentAnswersNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<AnswerItem>, String> {
  @override
  Future<List<AnswerItem>> build(String type) async {
    return ref.read(childRepositoryProvider).fetchParentAnswers(type: type);
  }

  /// 서버에서 다시 불러옵니다.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(childRepositoryProvider).fetchParentAnswers(type: arg),
    );
  }
}

final parentAnswersProvider = AsyncNotifierProvider.autoDispose
    .family<ParentAnswersNotifier, List<AnswerItem>, String>(
      ParentAnswersNotifier.new,
    );

/// 건강 리포트 화면 새로고침 트리거(카운터). Pull-to-refresh 등과 연결할 때 사용합니다.
final healthRefreshProvider = StateProvider<int>((ref) => 0);

// ── 치매 위험 분석 ───────────────────────────────────────────────────────────

/// 부모의 치매 분석 이력 (최신순).
/// "AI 음성 분석 · 위험 알림" 섹션에서 가장 최근 결과를 표시할 때 사용.
class ParentDementiaHistoryNotifier
    extends AutoDisposeAsyncNotifier<List<DementiaAnalysisItem>> {
  @override
  Future<List<DementiaAnalysisItem>> build() async {
    return ref.read(childRepositoryProvider).fetchParentDementiaHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(childRepositoryProvider).fetchParentDementiaHistory(),
    );
  }
}

final parentDementiaHistoryProvider =
    AsyncNotifierProvider.autoDispose<
      ParentDementiaHistoryNotifier,
      List<DementiaAnalysisItem>
    >(ParentDementiaHistoryNotifier.new);

/// 분석 결과 단건 상세. 화면에서 특정 analysis를 펼쳐볼 때 사용 가능.
final dementiaAnalysisDetailProvider = FutureProvider.autoDispose
    .family<DementiaAnalysisResult, String>((ref, analysisId) {
      return ref
          .read(childRepositoryProvider)
          .fetchDementiaAnalysis(analysisId);
    });
