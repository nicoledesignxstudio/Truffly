import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/presentation/account_privacy_policy_page.dart';
import 'package:truffly_app/features/account/presentation/account_settings_page.dart';
import 'package:truffly_app/features/account/presentation/account_terms_and_conditions_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

Widget _buildStandaloneApp() {
  return const ProviderScope(
    child: MaterialApp(
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

Widget _buildRouterApp() {
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
    ],
  );

  return ProviderScope(
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
    expect(find.byKey(const Key('settings_notifications_tile')), findsOneWidget);
    expect(find.byKey(const Key('settings_privacy_tile')), findsOneWidget);
    expect(find.byKey(const Key('settings_terms_tile')), findsOneWidget);
    expect(find.byKey(const Key('settings_delete_account_tile')), findsOneWidget);
  });

  testWidgets('language selection updates app locale provider', (tester) async {
    late ProviderContainer container;

    await tester.pumpWidget(
      ProviderScope(
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

  testWidgets('navigates to privacy policy and terms pages', (tester) async {
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
  });

  testWidgets('shows delete account confirmation dialog', (tester) async {
    await tester.pumpWidget(_buildStandaloneApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_delete_account_tile')));
    await tester.pumpAndSettle();

    expect(find.text('Delete your account?'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
  });
}
