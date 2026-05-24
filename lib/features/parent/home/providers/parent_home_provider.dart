import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:itda/features/parent/data/parent_models.dart';
import 'package:itda/features/parent/data/parent_repository.dart';

// ── 공용 Repository 인스턴스 ───────────────────────────────────────────────

final parentRepositoryProvider = Provider<ParentRepository>(
  (_) => ParentRepository(),
);

// ── 받은 사진 목록 ─────────────────────────────────────────────────────────

final _openedReceivedPhotoIds = <String>{};
var _openedReceivedPhotoIdsLoaded = false;

class ReceivedPhotosNotifier
    extends AutoDisposeAsyncNotifier<List<ParentReceivedPhoto>> {
  @override
  Future<List<ParentReceivedPhoto>> build() async {
    return _fetchIncomingPhotos();
  }

  /// 사진 확인 후 목록에서 제거합니다 (낙관적 업데이트).
  void removeByIds(Set<String> ids) {
    _openedReceivedPhotoIds.addAll(ids);
    unawaited(_persistOpenedReceivedPhotoIds());
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
    await _loadOpenedReceivedPhotoIds();
    final repository = ref.read(parentRepositoryProvider);
    final photos = await repository.fetchReceivedPhotos();

    return photos
        .where((photo) => !_openedReceivedPhotoIds.contains(photo.photoId))
        .toList();
  }
}

Future<File> _openedReceivedPhotoIdsFile() async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/itda_opened_received_photo_ids.json');
}

Future<void> _loadOpenedReceivedPhotoIds() async {
  if (_openedReceivedPhotoIdsLoaded) return;
  _openedReceivedPhotoIdsLoaded = true;
  try {
    final file = await _openedReceivedPhotoIdsFile();
    if (!await file.exists()) return;
    final raw = await file.readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is List) {
      _openedReceivedPhotoIds
        ..clear()
        ..addAll(decoded.whereType<String>());
    }
  } catch (_) {
    // 로컬 캐시 실패는 새 사진 조회 실패로 이어지지 않게 둡니다.
  }
}

Future<void> _persistOpenedReceivedPhotoIds() async {
  try {
    final file = await _openedReceivedPhotoIdsFile();
    final ids = _openedReceivedPhotoIds.toList()..sort();
    await file.writeAsString(jsonEncode(ids), flush: true);
  } catch (_) {
    // 저장 실패 시에도 현재 세션에서는 메모리 Set으로 숨김 처리를 유지합니다.
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
