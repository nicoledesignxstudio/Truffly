import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/features/auth/presentation/verify_email_screen.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TestBootstrapNotifier extends BootstrapNotifier {
  @override
  BootstrapState build() => const BootstrapInitial();
}

void main() {
  testWidgets(
    'VerifyEmailScreen hides back icon and shows resend plus login fallback actions',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          bootstrapNotifierProvider.overrideWith(TestBootstrapNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const VerifyEmailScreen(
              prefilledEmail: 'user@example.com',
            ),
          ),
        ),
      );

      expect(find.byType(AuthBackButton), findsNothing);
      expect(find.text('I verified my email'), findsOneWidget);
      expect(find.text('Resend email'), findsOneWidget);
      expect(find.text('Sign out'), findsNothing);
      expect(find.textContaining('user@example.com'), findsOneWidget);
    },
  );
}
