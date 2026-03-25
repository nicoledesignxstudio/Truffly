import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/home/data/repositories/home_repository.dart';

class _FakeHomeRepository extends HomeRepository {
  _FakeHomeRepository(this._builder)
    : super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  final SeasonalHighlightResponse Function(String localeCode) _builder;
  final List<String> requestedLocales = <String>[];

  @override
  Future<SeasonalHighlightResponse> fetchSeasonalHighlight({
    required String localeCode,
  }) async {
    requestedLocales.add(localeCode);
    return _builder(localeCode);
  }
}

class _FlakyHomeRepository extends HomeRepository {
  _FlakyHomeRepository()
    : super(SupabaseClient('https://example.supabase.co', 'anon-key'));

  int callCount = 0;

  @override
  Future<SeasonalHighlightResponse> fetchSeasonalHighlight({
    required String localeCode,
  }) async {
    callCount++;
    if (callCount == 1) {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
    }

    return SeasonalHighlightResponse.fromJson({
      'mode': 'countdown',
      'cards': [],
      'countdown': {
        'truffle_type': 'TUBER_AESTIVUM',
        'title': 'Recovered',
        'subtitle': 'Recovered subtitle',
        'image_key': 'seasonal/tuber_aestivum',
        'target_date': '2026-05-01',
        'days_remaining': 5,
      },
    });
  }
}

void main() {
  test('provider resolves active payload from repository parsing', () async {
    final repository = _FakeHomeRepository((_) {
      return SeasonalHighlightResponse.fromJson({
        'mode': 'active',
        'cards': [
          {
            'truffle_type': 'TUBER_BORCHII',
            'priority': 3,
            'title': 'È arrivato il Bianchetto',
            'subtitle': 'Test subtitle',
            'image_key': 'seasonal/tuber_borchii',
            'start_date': '2026-01-15',
            'end_date': '2026-04-30',
          },
        ],
        'countdown': null,
      });
    });

    final container = ProviderContainer(
      overrides: [
        appLocaleCodeProvider.overrideWithValue('it'),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(seasonalHighlightProvider.future);
    expect(state.mode, SeasonalHighlightMode.active);
    expect(state.cards.length, 1);
    expect(state.countdown, isNull);
  });

  test('provider resolves countdown payload from repository parsing', () async {
    final repository = _FakeHomeRepository((_) {
      return SeasonalHighlightResponse.fromJson({
        'mode': 'countdown',
        'cards': [],
        'countdown': {
          'truffle_type': 'TUBER_AESTIVUM',
          'title': 'Arriva lo Scorzone',
          'subtitle': 'Test subtitle',
          'image_key': 'seasonal/tuber_aestivum',
          'target_date': '2026-05-01',
          'days_remaining': 43,
        },
      });
    });

    final container = ProviderContainer(
      overrides: [
        appLocaleCodeProvider.overrideWithValue('en'),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(seasonalHighlightProvider.future);
    expect(state.mode, SeasonalHighlightMode.countdown);
    expect(state.cards, isEmpty);
    expect(state.countdown?.daysRemaining, 43);
  });

  test('provider surfaces repository failure', () async {
    final repository = _FakeHomeRepository((_) {
      throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
    });

    final container = ProviderContainer(
      overrides: [
        appLocaleCodeProvider.overrideWithValue('it'),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(seasonalHighlightProvider.future),
      throwsA(isA<SeasonalHighlightException>()),
    );
  });

  test('provider retry recovers after initial failure', () async {
    final repository = _FlakyHomeRepository();
    final container = ProviderContainer(
      overrides: [
        appLocaleCodeProvider.overrideWithValue('it'),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(seasonalHighlightProvider.future),
      throwsA(isA<SeasonalHighlightException>()),
    );

    await container.read(seasonalHighlightProvider.notifier).retry();
    final recovered = container.read(seasonalHighlightProvider).requireValue;
    expect(recovered.mode, SeasonalHighlightMode.countdown);
    expect(repository.callCount, 2);
  });

  test('provider uses locale from appLocaleCodeProvider', () async {
    final repository = _FakeHomeRepository((_) {
      return SeasonalHighlightResponse.fromJson({
        'mode': 'active',
        'cards': [],
        'countdown': null,
      });
    });

    final container = ProviderContainer(
      overrides: [
        appLocaleCodeProvider.overrideWithValue('en'),
        homeRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(seasonalHighlightProvider.future);
    expect(repository.requestedLocales.single, 'en');
  });

  test(
    'provider locale boundary: unknown locale is passed to repository',
    () async {
      final repository = _FakeHomeRepository((_) {
        return SeasonalHighlightResponse.fromJson({
          'mode': 'active',
          'cards': [],
          'countdown': null,
        });
      });

      final container = ProviderContainer(
        overrides: [
          appLocaleCodeProvider.overrideWithValue('fr'),
          homeRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(seasonalHighlightProvider.future);
      expect(repository.requestedLocales.single, 'fr');
    },
  );

  test('repository locale normalization maps unknown/empty to it', () {
    expect(HomeRepository.normalizeLocaleCode('en'), 'en');
    expect(HomeRepository.normalizeLocaleCode('it'), 'it');
    expect(HomeRepository.normalizeLocaleCode('fr'), 'it');
    expect(HomeRepository.normalizeLocaleCode(''), 'it');
  });
}
