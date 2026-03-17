import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_filters_sheet.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('apply returns local draft filters', (tester) async {
    TruffleListingFilters? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<TruffleListingFilters>(
                      context: context,
                      builder: (context) => const TruffleFiltersSheet(
                        initialFilters: TruffleListingFilters(),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prima scelta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applica filtri'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.qualities, contains(TruffleQuality.first));
  });

  testWidgets('reset clears draft before apply', (tester) async {
    TruffleListingFilters? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showModalBottomSheet<TruffleListingFilters>(
                      context: context,
                      builder: (context) => const TruffleFiltersSheet(
                        initialFilters: TruffleListingFilters(
                          qualities: {TruffleQuality.first},
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Applica filtri'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.qualities, isEmpty);
  });
}
