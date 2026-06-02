import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/models/photo_reaction.dart';
import 'package:itda/services/photo_reaction_service.dart';

export 'package:itda/core/models/photo_reaction.dart';

final photoReactionServiceProvider = Provider<PhotoReactionService>(
  (_) => PhotoReactionService(ApiClient.create()),
);

class PhotoReactionsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<PhotoReaction>, String> {
  Timer? _pollTimer;
  bool _fetching = false;

  @override
  Future<List<PhotoReaction>> build(String photoId) {
    ref.onDispose(() => _pollTimer?.cancel());
    _pollTimer ??= Timer.periodic(const Duration(seconds: 5), (_) {
      refresh(showLoading: false);
    });
    return _fetchReactions(photoId);
  }

  Future<void> refresh({bool showLoading = true}) async {
    if (_fetching) return;
    _fetching = true;
    if (showLoading) state = const AsyncLoading();
    final previous = state.valueOrNull;
    final result = await AsyncValue.guard(() => _fetchReactions(arg));
    state = result.when(
      data: AsyncData.new,
      error: (error, stackTrace) => previous != null
          ? AsyncData(previous)
          : AsyncError(error, stackTrace),
      loading: () =>
          previous != null ? AsyncData(previous) : const AsyncLoading(),
    );
    _fetching = false;
  }

  Future<List<PhotoReaction>> _fetchReactions(String photoId) {
    return ref.read(photoReactionServiceProvider).getReactions(photoId);
  }
}

final photoReactionsProvider = AsyncNotifierProvider.autoDispose
    .family<PhotoReactionsNotifier, List<PhotoReaction>, String>(
      PhotoReactionsNotifier.new,
    );
