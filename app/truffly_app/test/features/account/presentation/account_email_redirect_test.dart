import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/router/app_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/application/account_details_providers.dart';
import 'package:truffly_app/features/account/data/account_details_service.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/verify_email_screen.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeBootstrapNotifier extends BootstrapNotifier {
  @override
  BootstrapState build() => const BootstrapAuthenticated();
}

class _FakeAccountDetailsService implements AccountDetailsService {
  _FakeAccountDetailsService(this.profile);

  final CurrentUserProfile profile;
  int updateProfileCalls = 0;
  int updateEmailCalls = 0;
  String? lastUpdatedEmail;

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
  }) async {
    updateProfileCalls += 1;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }

  @override
  Future<AuthResult<AuthUnit>> updateEmail({
    required String email,
  }) async {
    updateEmailCalls += 1;
    lastUpdatedEmail = email;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

class _MutableAuthNotifier extends AuthNotifier {
  _MutableAuthNotifier({
    required this.initialState,
    this.refreshedState,
  });

  final AuthState initialState;
  final AuthState? refreshedState;
  int refreshCalls = 0;

  @override
  AuthState build() => initialState;

  @override
  Future<AuthResult<AuthUnit>> refreshAuthState() async {
    refreshCalls += 1;
    if (refreshedState != null) {
      state = refreshedState!;
    }
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

CurrentUserProfile _profile() {
  return const CurrentUserProfile(
    userId: 'u1',
    email: 'verified@test.com',
    onboardingCompleted: true,
    firstName: 'Mario',
    lastName: 'Rossi',
    role: 'buyer',
    sellerStatus: 'not_requested',
    countryCode: 'IT',
    region: 'TOSCANA',
    bio: null,
    profileImageUrl: null,
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required ProviderContainer container,
  required Locale locale,
}) async {
  final router = container.read(appRouterProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );

  await tester.pumpAndSettle();

  router.go(AppRoutes.accountDetails);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'redirects to /verify-email after email change and shows the english verification screen',
    (tester) async {
      final fakeService = _FakeAccountDetailsService(_profile());
      final authNotifier = _MutableAuthNotifier(
        initialState: const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
        refreshedState: const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'new-email@test.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          bootstrapNotifierProvider.overrideWith(_FakeBootstrapNotifier.new),
          authNotifierProvider.overrideWith(() => authNotifier),
          accountDetailsServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await _pumpApp(
        tester,
        container: container,
        locale: const Locale('en'),
      );

      await tester.enterText(
        find.byKey(const Key('account_email_field')),
        'new-email@test.com',
      );
      await tester.tap(find.byKey(const Key('account_save_button')));
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);

      expect(fakeService.updateProfileCalls, 1);
      expect(fakeService.updateEmailCalls, 1);
      expect(fakeService.lastUpdatedEmail, 'new-email@test.com');

      expect(authNotifier.refreshCalls, 1);
      expect(container.read(authNotifierProvider), isA<AuthAuthenticatedUnverified>());
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.verifyEmail);
      expect(find.byType(VerifyEmailScreen), findsOneWidget);

      // Verifica testo persistente della schermata verify-email
      expect(
        find.text(
          'We sent a verification link to your new email address. Verify your email to continue.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows the italian verification screen after email change',
    (tester) async {
      final fakeService = _FakeAccountDetailsService(_profile());
      final authNotifier = _MutableAuthNotifier(
        initialState: const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
        refreshedState: const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'new-email@test.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          bootstrapNotifierProvider.overrideWith(_FakeBootstrapNotifier.new),
          authNotifierProvider.overrideWith(() => authNotifier),
          accountDetailsServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await _pumpApp(
        tester,
        container: container,
        locale: const Locale('it'),
      );

      await tester.enterText(
        find.byKey(const Key('account_email_field')),
        'new-email@test.com',
      );
      await tester.tap(find.byKey(const Key('account_save_button')));
      await tester.pumpAndSettle();

      expect(fakeService.updateProfileCalls, 1);
      expect(fakeService.updateEmailCalls, 1);
      expect(authNotifier.refreshCalls, 1);
      expect(find.byType(VerifyEmailScreen), findsOneWidget);

      expect(
        find.text(
          "Ti abbiamo inviato un link di verifica al nuovo indirizzo email. Verifica l'email per continuare.",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'does not redirect when only profile data changes and email stays the same',
    (tester) async {
      final fakeService = _FakeAccountDetailsService(_profile());
      final authNotifier = _MutableAuthNotifier(
        initialState: const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
        refreshedState: const AuthAuthenticatedUnverified(
          userId: 'u1',
          email: 'verified@test.com',
        ),
      );

      final container = ProviderContainer(
        overrides: [
          bootstrapNotifierProvider.overrideWith(_FakeBootstrapNotifier.new),
          authNotifierProvider.overrideWith(() => authNotifier),
          accountDetailsServiceProvider.overrideWithValue(fakeService),
        ],
      );
      addTearDown(container.dispose);

      await _pumpApp(
        tester,
        container: container,
        locale: const Locale('en'),
      );

      await tester.enterText(
        find.byKey(const Key('account_first_name_field')),
        'Luigi',
      );
      await tester.tap(find.byKey(const Key('account_save_button')));
      await tester.pumpAndSettle();

      final router = container.read(appRouterProvider);

      expect(fakeService.updateProfileCalls, 1);
      expect(fakeService.updateEmailCalls, 0);
      expect(authNotifier.refreshCalls, 0);

      expect(
        container.read(authNotifierProvider),
        const AuthAuthenticatedReady(
          userId: 'u1',
          email: 'verified@test.com',
        ),
      );
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.accountDetails);
      expect(find.byType(VerifyEmailScreen), findsNothing);
      expect(find.text('Account details updated successfully.'), findsOneWidget);
    },
  );
}