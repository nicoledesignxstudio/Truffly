import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/guides/data/truffle_guides_service.dart';
import 'package:truffly_app/features/guides/domain/truffle_guide.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

final truffleGuidesServiceProvider = Provider<TruffleGuidesService>((ref) {
  return TruffleGuidesService(ref.read(supabaseClientProvider));
});

final truffleGuidesListProvider = FutureProvider<List<TruffleGuide>>((ref) {
  return ref.read(truffleGuidesServiceProvider).fetchPublishedGuides();
});

final truffleGuideDetailProvider =
    FutureProvider.family<TruffleGuide, TruffleType>((ref, truffleType) {
      return ref
          .read(truffleGuidesServiceProvider)
          .fetchPublishedGuideByType(truffleType);
    });