import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/api/api_client.dart';
import 'package:itda/core/models/photo_reaction.dart';
import 'package:itda/services/photo_reaction_service.dart';

export 'package:itda/core/models/photo_reaction.dart';

final photoReactionServiceProvider = Provider<PhotoReactionService>(
  (_) => PhotoReactionService(ApiClient.create()),
);

final photoReactionsProvider = FutureProvider.autoDispose
    .family<List<PhotoReaction>, String>(
      (ref, photoId) =>
          ref.read(photoReactionServiceProvider).getReactions(photoId),
    );
