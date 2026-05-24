import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itda/core/models/family.dart';
import 'package:itda/services/family_service.dart';

final familyServiceProvider = Provider<FamilyService>((ref) {
  return FamilyService();
});

final familyMeProvider = FutureProvider.autoDispose<FamilyMe>((ref) {
  return ref.read(familyServiceProvider).getMyFamily();
});
