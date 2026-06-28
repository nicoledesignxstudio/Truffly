import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/auth/presentation/welcome_screen.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('welcome screen does not show google login button', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TickerMode(enabled: false, child: WelcomeScreen()),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('Continue with Google'), findsNothing);
    expect(find.text('Sign up to Truffly'), findsOneWidget);
  });
}
