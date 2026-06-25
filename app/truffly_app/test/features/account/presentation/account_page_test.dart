import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/presentation/account_page.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/push/application/notification_preferences_provider.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('account page does not expose payments entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserAccountProfileProvider.overrideWith(
            (ref) async => _profile,
          ),
          notificationsEnabledProvider.overrideWith((ref) async => false),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AccountPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Payments'), findsNothing);
  });
}

const _profile = CurrentUserProfile(
  userId: 'buyer-1',
  email: 'buyer@test.com',
  onboardingCompleted: true,
  firstName: 'Buyer',
  lastName: 'Test',
  role: 'buyer',
  sellerStatus: 'not_requested',
  countryCode: 'IT',
  region: 'TOSCANA',
  bio: null,
  profileImageUrl: null,
);
