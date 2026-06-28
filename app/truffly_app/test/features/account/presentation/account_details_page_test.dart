import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/application/account_details_providers.dart';
import 'package:truffly_app/features/account/data/account_details_service.dart';
import 'package:truffly_app/features/account/presentation/account_details_page.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeAccountDetailsService implements AccountDetailsService {
  _FakeAccountDetailsService(this.profile);

  final CurrentUserProfile profile;
  int updateProfileCalls = 0;
  int updateEmailCalls = 0;
  final Completer<AuthResult<AuthUnit>> profileCompleter =
      Completer<AuthResult<AuthUnit>>();

  bool delayProfileUpdate = false;

  @override
  Future<AuthResult<CurrentUserProfile>> loadCurrentProfile() async {
    return AuthSuccess<CurrentUserProfile>(profile);
  }

  @override
  Future<AuthResult<AuthUnit>> updateProfile({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String? region,
    required String? bio,
    required String? profileImageUrl,
    required bool isSeller,
  }) {
    updateProfileCalls += 1;
    if (delayProfileUpdate) {
      return profileCompleter.future;
    }
    return Future.value(const AuthSuccess<AuthUnit>(AuthUnit.value));
  }

  @override
  Future<AuthResult<AuthUnit>> updateEmail({
    required String email,
  }) async {
    updateEmailCalls += 1;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

class _TestAuthNotifier extends AuthNotifier {
  int refreshCalls = 0;

  @override
  AuthState build() {
    return const AuthAuthenticatedReady(
      userId: 'u1',
      email: 'user@test.com',
    );
  }

  @override
  Future<AuthResult<AuthUnit>> refreshAuthState() async {
    refreshCalls += 1;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

CurrentUserProfile _profile({
  required bool isSeller,
  String email = 'user@test.com',
  String countryCode = 'IT',
  String? region = 'TOSCANA',
}) {
  return CurrentUserProfile(
    userId: 'u1',
    email: email,
    onboardingCompleted: true,
    firstName: 'Mario',
    lastName: 'Rossi',
    role: isSeller ? 'seller' : 'buyer',
    sellerStatus: isSeller ? 'approved' : 'not_requested',
    countryCode: countryCode,
    region: region,
    bio: isSeller ? 'Bio seller' : null,
    profileImageUrl: isSeller ? 'https://example.com/avatar.jpg' : null,
  );
}

Widget _buildApp({
  required AccountDetailsService service,
  AuthNotifier? authNotifier,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [
      accountDetailsServiceProvider.overrideWithValue(service),
      if (authNotifier != null)
        authNotifierProvider.overrideWith(() => authNotifier),
    ],
    child: MaterialApp.router(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AccountDetailsPage(),
          ),
          GoRoute(
            path: AppRoutes.verifyEmail,
            builder: (context, state) => Scaffold(
              body: Center(
                child: Text(
                  AppLocalizations.of(context)!
                      .accountDetailsEmailVerificationSent,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Finder get _firstNameField => find.byKey(const Key('account_first_name_field'));
Finder get _lastNameField => find.byKey(const Key('account_last_name_field'));
Finder get _emailField => find.byKey(const Key('account_email_field'));
Finder get _countryField => find.byKey(const Key('account_country_field'));
Finder get _regionField => find.byKey(const Key('account_region_field'));
Finder get _bioField => find.byKey(const Key('account_bio_field'));
Finder get _changeEmailButton => find.text('Change email');
Finder get _saveEmailButton => find.text('Save new email');
Finder get _changePhotoButton => find.text('Change photo');
Finder get _removePhotoButton => find.text('Remove photo');
Finder get _saveButton => find.byKey(const Key('account_save_button'));

void main() {
  testWidgets('buyer form shows only shared fields', (tester) async {
    final service = _FakeAccountDetailsService(
      _profile(isSeller: false, countryCode: 'FR', region: null),
    );

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    expect(_firstNameField, findsOneWidget);
    expect(_lastNameField, findsOneWidget);
    expect(_changeEmailButton, findsOneWidget);
    expect(_countryField, findsOneWidget);

    expect(_bioField, findsNothing);
    expect(_changePhotoButton, findsNothing);
    expect(_removePhotoButton, findsNothing);

    expect(find.text('Mario'), findsOneWidget);
    expect(find.text('Rossi'), findsOneWidget);
    expect(find.text('user@test.com'), findsOneWidget);
    expect(find.text('France'), findsOneWidget);
    expect(find.text('Bio'), findsNothing);
  });

  testWidgets('seller form shows bio and profile image sections', (
    tester,
  ) async {
    final service = _FakeAccountDetailsService(_profile(isSeller: true));

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    expect(_firstNameField, findsOneWidget);
    expect(_lastNameField, findsOneWidget);
    expect(_changeEmailButton, findsOneWidget);
    expect(_bioField, findsOneWidget);
    expect(find.text('Italy'), findsOneWidget);
    expect(find.text('Toscana'), findsOneWidget);
    expect(_changePhotoButton, findsOneWidget);
    expect(_removePhotoButton, findsNothing);

    expect(find.text('Bio'), findsOneWidget);
  });

  testWidgets('region is visible and required when country is Italy', (
    tester,
  ) async {
    final service = _FakeAccountDetailsService(
      _profile(isSeller: false, countryCode: 'IT', region: null),
    );

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    expect(find.text('Region'), findsOneWidget);
    expect(_regionField, findsOneWidget);

    await tester.enterText(_firstNameField, 'Luigi');
    await tester.pumpAndSettle();
    await tester.ensureVisible(_saveButton);
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(find.text('Region is required.'), findsOneWidget);
  });

  testWidgets('region helper is shown when country is not Italy', (
    tester,
  ) async {
    final service = _FakeAccountDetailsService(
      _profile(isSeller: false, countryCode: 'FR', region: null),
    );

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    expect(_regionField, findsNothing);
    expect(find.text('France'), findsOneWidget);
  });

  testWidgets('saving state disables submit button', (tester) async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    service.delayProfileUpdate = true;

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    await tester.enterText(_firstNameField, 'Luigi');
    await tester.pumpAndSettle();
    await tester.ensureVisible(_saveButton);
    await tester.tap(_saveButton);
    await tester.pump();

    final button = tester.widget<AuthPrimaryButton>(_saveButton);
    expect(button.isLoading, isTrue);

    service.profileCompleter.complete(const AuthSuccess<AuthUnit>(AuthUnit.value));
    await tester.pumpAndSettle();
  });

  testWidgets('profile-only submit shows success message', (tester) async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));

    await tester.pumpWidget(_buildApp(service: service));
    await tester.pumpAndSettle();

    await tester.enterText(_firstNameField, 'Luigi');
    await tester.pumpAndSettle();
    await tester.ensureVisible(_saveButton);
    await tester.tap(_saveButton);
    await tester.pumpAndSettle();

    expect(service.updateProfileCalls, 1);
    expect(service.updateEmailCalls, 0);
    expect(find.text('Account details updated successfully.'), findsOneWidget);
  });

  testWidgets('email change shows verification message and redirects', (
    tester,
  ) async {
    final service = _FakeAccountDetailsService(_profile(isSeller: false));
    final authNotifier = _TestAuthNotifier();

    await tester.pumpWidget(
      _buildApp(
        service: service,
        authNotifier: authNotifier,
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(_changeEmailButton);
    await tester.tap(_changeEmailButton);
    await tester.pumpAndSettle();
    await tester.enterText(_emailField, 'new@test.com');
    await tester.pumpAndSettle();
    await tester.ensureVisible(_saveEmailButton);
    await tester.tap(_saveEmailButton);
    await tester.pumpAndSettle();

    expect(service.updateProfileCalls, 0);
    expect(service.updateEmailCalls, 1);
    expect(
      find.text(
        'Check both your current and new email addresses and confirm both links to complete the change.',
      ),
      findsWidgets,
    );
    expect(authNotifier.refreshCalls, 0);
  });
}
