import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';
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

Widget _buildApp(List<Override> overrides) {
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
      home: const HomeScreen(),
    ),
  );
}

CurrentUserProfile _profile({required String role}) {
  return CurrentUserProfile(
    userId: 'u1',
    email: 'user@test.com',
    onboardingCompleted: true,
    firstName: 'Mario',
    lastName: 'Rossi',
    role: role,
    sellerStatus: role == 'seller' ? 'approved' : 'not_requested',
    countryCode: 'IT',
    region: 'TOSCANA',
    bio: role == 'seller' ? 'Bio seller' : null,
    profileImageUrl: null,
  );
}

void main() {
  final seasonalValue = SeasonalHighlightResponse.fromJson({
    'mode': 'active',
    'cards': [
      {
        'truffle_type': 'TUBER_BORCHII',
        'priority': 3,
        'title': 'Card 1',
        'subtitle': 'Subtitle',
        'image_key': 'seasonal/tuber_borchii',
        'start_date': '2026-01-15',
        'end_date': '2026-04-30',
      },
    ],
    'countdown': null,
  });

  testWidgets('buyer sees seasonal section', (tester) async {
    await tester.pumpWidget(
      _buildApp([
        currentUserAccountProfileProvider.overrideWith(
          (ref) async => _profile(role: 'buyer'),
        ),
        seasonalHighlightProvider.overrideWith(
          () => _FakeSeasonalHighlightNotifier(seasonalValue),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SeasonalHighlightSection), findsOneWidget);
  });

  testWidgets('seller does not see buyer seasonal section', (tester) async {
    await tester.pumpWidget(
      _buildApp([
        currentUserAccountProfileProvider.overrideWith(
          (ref) async => _profile(role: 'seller'),
        ),
        seasonalHighlightProvider.overrideWith(
          () => _FakeSeasonalHighlightNotifier(seasonalValue),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SeasonalHighlightSection), findsNothing);
  });

  testWidgets('shows safe loading fallback while profile is loading', (
    tester,
  ) async {
    final completer = Completer<CurrentUserProfile>();
    await tester.pumpWidget(
      _buildApp([
        currentUserAccountProfileProvider.overrideWith(
          (ref) => completer.future,
        ),
      ]),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows safe error fallback when profile fails', (tester) async {
    await tester.pumpWidget(
      _buildApp([
        currentUserAccountProfileProvider.overrideWith(
          (ref) async => throw Exception('profile load failed'),
        ),
      ]),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Impossibile caricare la home in questo momento.'),
      findsOneWidget,
    );
  });
}
