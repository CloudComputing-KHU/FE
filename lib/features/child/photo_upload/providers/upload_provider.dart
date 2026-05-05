import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/models/photo.dart';
import 'package:itda/features/child/health_monitoring/providers/health_provider.dart'
    show childRepositoryProvider;

/// 사진 전송 중 여부. 업로드 시작/종료 시 갱신합니다.
final uploadBusyProvider = StateProvider<bool>((ref) => false);

// ── 자녀 식별 ────────────────────────────────────────────────────────────────
// TODO: 인증 연동 후 실제 user_id로 교체.
const _kChildUserId = 'child_001';
const _kParentUserId = 'parent_001';

// ── 사진 업로드 결과 ───────────────────────────────────────────────────────

/// 화면에서 SnackBar 표시용으로 쓸 단순 결과.
class PhotoUploadOutcome {
  PhotoUploadOutcome({required this.ok, required this.message});

  final bool ok;
  final String message;
}

/// 자녀 → 부모 사진 업로드. 화면이 직접 호출합니다.
/// 성공 시 보낸 이력 캐시도 새로고침합니다.
Future<PhotoUploadOutcome> uploadChildPhoto({
  required WidgetRef ref,
  required String filePath,
  String? caption,
  DateTime? scheduledAt,
}) async {
  ref.read(uploadBusyProvider.notifier).state = true;
  try {
    await ref.read(childRepositoryProvider).sendPhoto(
          childUserId: _kChildUserId,
          parentUserId: _kParentUserId,
          filePath: filePath,
          caption: caption,
          scheduledAt: scheduledAt,
        );
    // 보낸 이력 캐시 무효화 → 다음 조회 시 새로 fetch
    ref.invalidate(sentPhotosProvider);
    return PhotoUploadOutcome(
      ok: true,
      message: scheduledAt == null ? '사진을 보냈어요!' : '예약 전송이 등록됐어요!',
    );
  } catch (e) {
    return PhotoUploadOutcome(ok: false, message: '전송 실패: $e');
  } finally {
    ref.read(uploadBusyProvider.notifier).state = false;
  }
}

// ── 자녀가 보낸 사진 이력 ────────────────────────────────────────────────

/// 자녀가 부모에게 보낸 사진 목록 (최신순).
/// 화면에서 미사용이라도 미리 정의해두면 추후 "보낸 사진 모아보기" 화면에서 그대로 사용 가능.
class SentPhotosNotifier extends AutoDisposeAsyncNotifier<List<Photo>> {
  @override
  Future<List<Photo>> build() {
    return ref.read(childRepositoryProvider).fetchSentPhotos(_kChildUserId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(childRepositoryProvider).fetchSentPhotos(_kChildUserId),
    );
  }
}

final sentPhotosProvider =
    AsyncNotifierProvider.autoDispose<SentPhotosNotifier, List<Photo>>(
  SentPhotosNotifier.new,
);