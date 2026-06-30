import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/data/account_deletion_service.dart';
import 'package:truffly_app/features/account/presentation/account_privacy_policy_page.dart';
import 'package:truffly_app/features/account/presentation/account_refund_and_cancellation_page.dart';
import 'package:truffly_app/features/account/presentation/account_legal_information_page.dart';
import 'package:truffly_app/features/account/presentation/account_settings_page.dart';
import 'package:truffly_app/features/account/presentation/account_terms_and_conditions_page.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/push/application/notification_preferences_provider.dart';
import 'package:truffly_app/features/push/data/push_token_service.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

Widget _buildStandaloneApp({PushTokenServiceApi? pushTokenService}) {
  final overrides = <Override>[
    notificationPreferenceServiceProvider.overrideWithValue(
      pushTokenService ?? _FakePushTokenService(),
    ),
  ];

  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      locale: Locale('en'),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountSettingsPage(),
    ),
  );
}

class _FakeAccountDeletionService implements AccountDeletionService {
  _FakeAccountDeletionService({required this.result});

  final Completer<AccountDeletionResult> completer =
      Completer<AccountDeletionResult>();
  final AccountDeletionResult result;
  int calls = 0;

  @override
  Future<AccountDeletionResult> deleteCurrentAccount() {
    calls += 1;
    if (completer.isCompleted) {
      return Future.value(result);
    }
    return completer.future;
  }
}

class _FakePushTokenService implements PushTokenServiceApi {
  _FakePushTokenService({this.enabled = false});

  bool enabled;
  int enableCalls = 0;
  int readCalls = 0;
  int setCalls = 0;
  bool? lastSetEnabled;

  @override
  Future<void> clearCurrentToken() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationEnableResult> enableCurrentDeviceNotifications({
    bool requestPermission = true,
  }) async {
    enableCalls += 1;
    enabled = true;
    return const NotificationEnableResult(NotificationEnableStatus.enabled);
  }

  @override
  Future<bool> isCurrentDeviceNotificationsEnabled() async {
    readCalls += 1;
    return enabled;
  }

  @override
  Future<void> setCurrentDeviceNotificationsEnabled(bool enabled) async {
    setCalls += 1;
    lastSetEnabled = enabled;
    this.enabled = enabled;
  }

  @override
  Future<void> syncCurrentToken({String? token}) async {}

  @override
  Future<void> openSystemNotificationSettings() async {}
}

class _TestAuthNotifier extends AuthNotifier {
  int signOutCalls = 0;

  @override
  AuthState build() {
    return const AuthAuthenticatedReady(userId: 'u1', email: 'user@test.com');
  }

  @override
  Future<AuthResult<AuthUnit>> signOut() async {
    signOutCalls += 1;
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }
}

Widget _buildRouterApp({PushTokenServiceApi? pushTokenService}) {
  final router = GoRouter(
    initialLocation: AppRoutes.accountSettings,
    routes: [
      GoRoute(
        path: AppRoutes.accountSettings,
        builder: (context, state) => const AccountSettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountPrivacyPolicy,
        builder: (context, state) => const AccountPrivacyPolicyPage(),
      ),
      GoRoute(
        path: AppRoutes.accountTerms,
        builder: (context, state) => const AccountTermsAndConditionsPage(),
      ),
      GoRoute(
        path: AppRoutes.accountRefundAndCancellation,
        builder: (context, state) => const AccountRefundAndCancellationPage(),
      ),
      GoRoute(
        path: AppRoutes.accountLegalInformation,
        builder: (context, state) => const AccountLegalInformationPage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      notificationPreferenceServiceProvider.overrideWithValue(
        pushTokenService ?? _FakePushTokenService(),
      ),
    ],
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  testWidgets('renders settings sections and tiles', (tester) async {
    await tester.pumpWidget(_buildStandaloneApp());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byKey(const Key('settings_language_tile')), findsOneWidget);
    expect(
      find.byKey(const Key('settings_notifications_tile')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('settings_privacy_tile')), findsOneWidget);
    expect(find.byKey(const Key('settings_terms_tile')), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_legal_information_tile')),
      120,
    );
    expect(find.byKey(const Key('settings_refund_tile')), findsOneWidget);
    expect(
      find.byKey(const Key('settings_legal_information_tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('settings_delete_account_tile')),
      findsOneWidget,
    );
  });

  testWidgets('language selection updates app locale provider', (tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPreferenceServiceProvider.overrideWithValue(
            _FakePushTokenService(),
          ),
        ],
        child: Builder(
          builder: (context) {
            container = ProviderScope.containerOf(context, listen: false);
            return const MaterialApp(
              locale: Locale('en'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: AccountSettingsPage(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_language_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Italiano'));
    await tester.pumpAndSettle();

    expect(container.read(appLocaleCodeProvider), 'it');
  });

  testWidgets('navigates to every legal page', (tester) async {
    await tester.pumpWidget(_buildRouterApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_privacy_tile')));
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsOneWidget);

    final context = tester.element(find.text('Privacy Policy').first);
    GoRouter.of(context).go(AppRoutes.accountSettings);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_terms_tile')));
    await tester.pumpAndSettle();
    expect(find.text('Terms & Conditions'), findsOneWidget);

    GoRouter.of(
      tester.element(find.text('Terms & Conditions').first),
    ).go(AppRoutes.accountSettings);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_refund_tile')),
      120,
    );
    await tester.tap(find.byKey(const Key('settings_refund_tile')));
    await tester.pumpAndSettle();
    expect(find.text('Refund & Cancellation'), findsOneWidget);

    GoRouter.of(
      tester.element(find.text('Refund & Cancellation').first),
    ).go(AppRoutes.accountSettings);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('settings_legal_information_tile')),
      120,
    );
    await tester.tap(find.byKey(const Key('settings_legal_information_tile')));
    await tester.pumpAndSettle();
    expect(find.text('Legal Information'), findsOneWidget);
  });

  testWidgets('shows delete account confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildStandaloneApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_delete_account_tile')));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });

  testWidgets('delete account flow calls the service once and signs out', (
    tester,
  ) async {
    final deletionService = _FakeAccountDeletionService(
      result: const AccountDeletionResult(
        status: AccountDeletionOutcome.deactivated,
        requestId: 'req-1',
      ),
    );
    final authNotifier = _TestAuthNotifier();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accountDeletionServiceProvider.overrideWithValue(deletionService),
          authNotifierProvider.overrideWith(() => authNotifier),
          notificationPreferenceServiceProvider.overrideWithValue(
            _FakePushTokenService(),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AccountSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_delete_account_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pump();

    expect(deletionService.calls, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    deletionService.completer.complete(deletionService.result);
    await tester.pumpAndSettle();

    expect(authNotifier.signOutCalls, 1);
    expect(
      find.text(
        'Your account was deactivated for compliance. You have been signed out.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('notifications toggle persists through push token service', (
    tester,
  ) async {
    final pushTokenService = _FakePushTokenService(enabled: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationPreferenceServiceProvider.overrideWithValue(
            pushTokenService,
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: AccountSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    expect(tester.widget<Switch>(switchFinder).value, isFalse);

    await tester.tap(switchFinder);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(pushTokenService.enableCalls, 1);
    expect(tester.widget<Switch>(switchFinder).value, isTrue);
  });
}
