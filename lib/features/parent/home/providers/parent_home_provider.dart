import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/auth/token_storage.dart';
import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/features/parent/data/parent_repository.dart';

// ── 공용 Repository 인스턴스 ───────────────────────────────────────────────

final parentRepositoryProvider = Provider<ParentRepository>(
  (_) => ParentRepository(),
);

// ── 현재 로그인한 부모 user_id ──────────────────────────────────────────────

Future<String> _currentParentUserId() async {
  return await TokenStorage.readCurrentUserId() ?? 'parent_001';
}

// ── 받은 사진 목록 ─────────────────────────────────────────────────────────

final _openedReceivedPhotoIds = <String>{};

class ReceivedPhotosNotifier
    extends AutoDisposeAsyncNotifier<List<ParentReceivedPhoto>> {
  @override
  Future<List<ParentReceivedPhoto>> build() async {
    return _fetchIncomingPhotos();
  }

  /// 사진 확인 후 목록에서 제거합니다 (낙관적 업데이트).
  void removeByIds(Set<String> ids) {
    _openedReceivedPhotoIds.addAll(ids);
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
    final userId = await _currentParentUserId();
    final repository = ref.read(parentRepositoryProvider);

    Object? receivedError;
    var photos = <ParentReceivedPhoto>[];
    try {
      photos = await repository.fetchReceivedPhotos(userId);
    } catch (error) {
      receivedError = error;
    }

    if (photos.isEmpty) {
      try {
        final history = await repository.fetchPhotoHistory(userId);
        photos = history.where(_isRecentIncomingPhoto).toList();
      } catch (_) {
        if (receivedError != null) rethrow;
      }
    }

    return photos
        .where((photo) => !_openedReceivedPhotoIds.contains(photo.photoId))
        .toList();
  }
}

final receivedPhotosProvider =
    AsyncNotifierProvider.autoDispose<
      ReceivedPhotosNotifier,
      List<ParentReceivedPhoto>
    >(ReceivedPhotosNotifier.new);

bool _isRecentIncomingPhoto(ParentReceivedPhoto photo) {
  final createdAt = photo.createdAt.toLocal();
  final now = DateTime.now();
  final isSameDay =
      createdAt.year == now.year &&
      createdAt.month == now.month &&
      createdAt.day == now.day;
  if (isSameDay) return true;

  final elapsed = now.difference(createdAt);
  return !elapsed.isNegative && elapsed.inHours < 24;
}

// ── 지난 사진 이력 ─────────────────────────────────────────────────────────

class PastPhotosNotifier
    extends AutoDisposeAsyncNotifier<List<ParentReceivedPhoto>> {
  @override
  Future<List<ParentReceivedPhoto>> build() async {
    final userId = await _currentParentUserId();
    return ref.read(parentRepositoryProvider).fetchPhotoHistory(userId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final userId = await _currentParentUserId();
    state = await AsyncValue.guard(
      () => ref.read(parentRepositoryProvider).fetchPhotoHistory(userId),
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
    final userId = await _currentParentUserId();
    await ref
        .read(parentRepositoryProvider)
        .submitAnswer(
          type: type,
          userId: userId,
          questionId: questionId,
          answer: answer,
        );
    ref.read(healthQuestStepProvider.notifier).update((s) => s + 1);
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
    final userId = await _currentParentUserId();
    final result = await ref
        .read(parentRepositoryProvider)
        .uploadVoice(
          type: type,
          userId: userId,
          questionId: questionId,
          filePath: filePath,
        );
    try {
      await ref
          .read(parentRepositoryProvider)
          .requestDementiaAnalysis(result.answerId);
    } catch (_) {
      // 음성 답변 저장은 성공했으므로 분석 트리거 실패가 답변 제출 실패로 보이지 않게 둡니다.
    }
    ref.read(healthQuestStepProvider.notifier).update((s) => s + 1);
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
