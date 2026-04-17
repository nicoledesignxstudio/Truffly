import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/auth_callback_context.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/presentation/reset_password_screen.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('ResetPasswordScreen rejects invalid recovery context', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseClientProvider.overrideWithValue(
            SupabaseClient(
              'https://example.supabase.co',
              'public-anon-key',
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ResetPasswordScreen(
            callbackContext: AuthCallbackContext.fromUri(
              Uri.parse('/reset-password?type=recovery'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Reset password'), findsOneWidget);
    expect(find.text('Recovery session is invalid. Open the reset link again.'), findsOneWidget);
  });
}
