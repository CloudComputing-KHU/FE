import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/features/parent/data/parent_repository.dart';
import 'package:itda/features/child/health_monitoring/providers/health_provider.dart'
    show
        dementiaAnalysisDetailProvider,
        parentAnswersProvider,
        parentDementiaHistoryProvider;

// ── 공용 Repository 인스턴스 ───────────────────────────────────────────────

final parentRepositoryProvider = Provider<ParentRepository>(
  (_) => ParentRepository(),
);

// ── 받은 사진 목록 ─────────────────────────────────────────────────────────

class ReceivedPhotosNotifier
    extends AutoDisposeAsyncNotifier<List<ParentReceivedPhoto>> {
  @override
  Future<List<ParentReceivedPhoto>> build() async {
    return _fetchIncomingPhotos();
  }

  /// 이미 확인한 사진을 현재 새 사진 목록에서 제거합니다.
  ///
  /// 서버도 `GET /photos/received` 호출 시 `sent` 사진을 `seen`으로 바꾸므로,
  /// 이 메서드는 현재 화면 상태를 즉시 맞추기 위한 낙관적 업데이트입니다.
  void removeByIds(Set<String> ids) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncData(current.where((p) => !ids.contains(p.photoId)).toList());
  }

  /// 서버에서 다시 불러옵니다.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchIncomingPhotos);
  }

  Future<List<ParentReceivedPhoto>> _fetchIncomingPhotos() async {
    final repository = ref.read(parentRepositoryProvider);
    return repository.fetchReceivedPhotos();
  }
}

final receivedPhotosProvider =
    AsyncNotifierProvider.autoDispose<
      ReceivedPhotosNotifier,
      List<ParentReceivedPhoto>
    >(ReceivedPhotosNotifier.new);

// ── 지난 사진 이력 ─────────────────────────────────────────────────────────

class PastPhotosNotifier
    extends AutoDisposeAsyncNotifier<List<ParentReceivedPhoto>> {
  @override
  Future<List<ParentReceivedPhoto>> build() async {
    return ref.read(parentRepositoryProvider).fetchPhotoHistory();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(parentRepositoryProvider).fetchPhotoHistory(),
    );
  }
}

final pastPhotosProvider =
    AsyncNotifierProvider.autoDispose<
      PastPhotosNotifier,
      List<ParentReceivedPhoto>
    >(PastPhotosNotifier.new);

// ── 오늘의 질문 ────────────────────────────────────────────────────────────

/// 질문 타입별 캐시. 같은 타입은 화면 이동 후에도 재요청하지 않습니다.
final questionProvider = FutureProvider.autoDispose
    .family<ParentQuestion, String>((ref, type) {
      return ref.read(parentRepositoryProvider).fetchQuestion(type);
    });

final todayQuestionStatusProvider =
    FutureProvider.autoDispose<ParentQuestionStatus>((ref) async {
      final status = await ref
          .read(parentRepositoryProvider)
          .fetchTodayQuestionStatus();
      ref.read(healthQuestStepProvider.notifier).state = status.completedStep;
      return status;
    });

// ── 건강 퀘스트 완료 단계 ──────────────────────────────────────────────────

/// 0 = 아무것도 안 함, 1 = health 완료, 2 = meal 완료, 3 = mood 완료(전체 완료)
final healthQuestStepProvider = StateProvider<int>((ref) => 0);

// ── 답변 제출 ──────────────────────────────────────────────────────────────

/// 선택형 답변을 제출하고 step을 올립니다.
/// 반환값: 성공 여부
Future<bool> submitParentAnswer({
  required WidgetRef ref,
  required String type,
  required String questionId,
  required String answer,
}) async {
  try {
    await ref
        .read(parentRepositoryProvider)
        .submitAnswer(type: type, questionId: questionId, answer: answer);
    ref.read(healthQuestStepProvider.notifier).update((s) => s + 1);
    ref.invalidate(todayQuestionStatusProvider);
    ref.invalidate(parentAnswersProvider(type));
    return true;
  } catch (_) {
    return false;
  }
}

/// 음성 답변을 업로드하고 step을 올립니다.
Future<bool> submitParentVoice({
  required WidgetRef ref,
  required String type,
  required String questionId,
  required String filePath,
}) async {
  try {
    final result = await ref
        .read(parentRepositoryProvider)
        .uploadVoice(type: type, questionId: questionId, filePath: filePath);
    try {
      final analysis = await ref
          .read(parentRepositoryProvider)
          .requestDementiaAnalysis(result.answerId);
      ref.invalidate(parentDementiaHistoryProvider);
      ref.invalidate(dementiaAnalysisDetailProvider(analysis.analysisId));
    } catch (_) {
      // 음성 답변 저장은 성공했으므로 분석 트리거 실패가 답변 제출 실패로 보이지 않게 둡니다.
    }
    ref.read(healthQuestStepProvider.notifier).update((s) => s + 1);
    ref.invalidate(todayQuestionStatusProvider);
    ref.invalidate(parentAnswersProvider(type));
    return true;
  } catch (_) {
    return false;
  }
}

/// stepIndex → API type 문자열
String questTypeForStep(int step) {
  switch (step.clamp(0, 2)) {
    case 1:
      return 'meal';
    case 2:
      return 'mood';
    case 0:
    default:
      return 'health';
  }
}
