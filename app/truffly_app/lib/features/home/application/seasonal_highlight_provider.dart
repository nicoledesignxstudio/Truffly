import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/home/data/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(supabaseClientProvider));
});

final seasonalHighlightProvider =
    AsyncNotifierProvider<SeasonalHighlightNotifier, SeasonalHighlightResponse>(
  SeasonalHighlightNotifier.new,
);

class SeasonalHighlightNotifier extends AsyncNotifier<SeasonalHighlightResponse> {
  @override
  Future<SeasonalHighlightResponse> build() async {
    return _fetch();
  }

  Future<void> retry() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<SeasonalHighlightResponse> _fetch() {
    return ref.read(homeRepositoryProvider).fetchSeasonalHighlight(
          localeCode: ref.read(appLocaleCodeProvider),
        );
  }
}
