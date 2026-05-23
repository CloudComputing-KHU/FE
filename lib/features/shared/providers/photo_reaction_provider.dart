import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoReaction {
  const PhotoReaction({
    required this.photoId,
    required this.label,
    required this.createdAt,
    this.isVoice = false,
    this.durationLabel = '0:24',
  });

  final String photoId;
  final String label;
  final DateTime createdAt;
  final bool isVoice;
  final String durationLabel;
}

class PhotoReactionNotifier
    extends StateNotifier<Map<String, List<PhotoReaction>>> {
  PhotoReactionNotifier() : super(const {});

  void addReaction({
    required Iterable<String> photoIds,
    required String label,
    bool isVoice = false,
    String durationLabel = '0:24',
  }) {
    final now = DateTime.now();
    final next = <String, List<PhotoReaction>>{
      for (final entry in state.entries) entry.key: List.of(entry.value),
    };

    for (final photoId in photoIds) {
      next.putIfAbsent(photoId, () => []);
      next[photoId]!.add(
        PhotoReaction(
          photoId: photoId,
          label: label,
          createdAt: now,
          isVoice: isVoice,
          durationLabel: durationLabel,
        ),
      );
    }

    state = next;
  }
}

final photoReactionProvider =
    StateNotifierProvider<
      PhotoReactionNotifier,
      Map<String, List<PhotoReaction>>
    >((ref) => PhotoReactionNotifier());
