import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/home/data/repositories/home_repository.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_dots.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_section.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeSeasonalHighlightNotifier extends SeasonalHighlightNotifier {
  _FakeSeasonalHighlightNotifier(this._value);

  final SeasonalHighlightResponse _value;

  @override
  Future<SeasonalHighlightResponse> build() async {
    return _value;
  }
}

class _LoadingSeasonalHighlightNotifier extends SeasonalHighlightNotifier {
  final Completer<SeasonalHighlightResponse> _completer =
      Completer<SeasonalHighlightResponse>();

  @override
  Future<SeasonalHighlightResponse> build() {
    return _completer.future;
  }
}

class _ErrorSeasonalHighlightNotifier extends SeasonalHighlightNotifier {
  int retryCount = 0;

  @override
  Future<SeasonalHighlightResponse> build() {
    throw const SeasonalHighlightException(SeasonalHighlightFailure.network);
  }

  @override
  Future<void> retry() async {
    retryCount++;
  }
}

Widget _buildTestApp(List<Override> overrides) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: SeasonalHighlightSection(),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('active mode shows pager and dots', (tester) async {
    final value = SeasonalHighlightResponse.fromJson({
      'mode': 'active',
      'cards': [
        {
          'truffle_type': 'TUBER_BORCHII',
          'priority': 3,
          'title': 'Card 1',
          'subtitle': 'Subtitle 1',
          'image_key': 'seasonal/tuber_borchii',
          'start_date': '2026-01-15',
          'end_date': '2026-04-30',
        },
        {
          'truffle_type': 'TUBER_BRUMALE',
          'priority': 4,
          'title': 'Card 2',
          'subtitle': 'Subtitle 2',
          'image_key': 'seasonal/tuber_brumale',
          'start_date': '2026-01-01',
          'end_date': '2026-04-15',
        },
      ],
      'countdown': null,
    });

    await tester.pumpWidget(
      _buildTestApp([
        seasonalHighlightProvider.overrideWith(
          () => _FakeSeasonalHighlightNotifier(value),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);
    expect(find.byType(SeasonalHighlightDots), findsOneWidget);
  });

  testWidgets('countdown mode shows single card without dots', (tester) async {
    final value = SeasonalHighlightResponse.fromJson({
      'mode': 'countdown',
      'cards': [],
      'countdown': {
        'truffle_type': 'TUBER_AESTIVUM',
        'title': 'Arriva lo Scorzone',
        'subtitle': 'Subtitle',
        'image_key': 'seasonal/tuber_aestivum',
        'target_date': '2026-05-01',
        'days_remaining': 12,
      },
    });

    await tester.pumpWidget(
      _buildTestApp([
        seasonalHighlightProvider.overrideWith(
          () => _FakeSeasonalHighlightNotifier(value),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PageView), findsNothing);
    expect(find.byType(SeasonalHighlightDots), findsNothing);
    expect(find.textContaining('12'), findsOneWidget);
  });

  testWidgets('loading state shows compact loading UI', (tester) async {
    await tester.pumpWidget(
      _buildTestApp([
        seasonalHighlightProvider.overrideWith(
          _LoadingSeasonalHighlightNotifier.new,
        ),
      ]),
    );
    await tester.pump();

    expect(find.text('Caricamento stagionalità...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error state shows compact error and retry action', (
    tester,
  ) async {
    final notifier = _ErrorSeasonalHighlightNotifier();
    await tester.pumpWidget(
      _buildTestApp([seasonalHighlightProvider.overrideWith(() => notifier)]),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Impossibile caricare le informazioni stagionali.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);
    await tester.tap(find.text('Riprova'));
    await tester.pump();
    expect(notifier.retryCount, 1);
  });

  testWidgets('empty state shows compact fallback card', (tester) async {
    final value = SeasonalHighlightResponse.fromJson({
      'mode': 'countdown',
      'cards': [],
      'countdown': null,
    });

    await tester.pumpWidget(
      _buildTestApp([
        seasonalHighlightProvider.overrideWith(
          () => _FakeSeasonalHighlightNotifier(value),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nessuna stagione disponibile al momento.'),
      findsOneWidget,
    );
  });
}
