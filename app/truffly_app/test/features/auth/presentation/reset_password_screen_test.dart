import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/auth/presentation/reset_password_screen.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('ResetPasswordScreen shows reset password form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResetPasswordScreen(),
        ),
      ),
    );

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Update password'), findsOneWidget);
  });
}
