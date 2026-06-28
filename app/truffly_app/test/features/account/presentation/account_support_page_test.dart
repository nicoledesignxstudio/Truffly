import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/data/account_support_launcher.dart';
import 'package:truffly_app/features/account/presentation/account_support_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeAccountSupportLauncher extends AccountSupportLauncher {
  _FakeAccountSupportLauncher(this.result);

  final bool result;
  int callCount = 0;

  @override
  Future<bool> composeSupportEmail() async {
    callCount += 1;
    return result;
  }
}

Widget _buildApp(AccountSupportLauncher launcher) {
  return ProviderScope(
    overrides: [accountSupportLauncherProvider.overrideWithValue(launcher)],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const AccountSupportPage(),
    ),
  );
}

void main() {
  testWidgets('renders FAQ and contact CTA', (tester) async {
    await tester.pumpWidget(_buildApp(_FakeAccountSupportLauncher(true)));
    await tester.pumpAndSettle();

    expect(find.text('Support'), findsOneWidget);
    expect(find.text('Buying & Orders'), findsOneWidget);
    expect(find.byKey(const Key('support_faq_buy_truffle')), findsOneWidget);

    await tester.dragUntilVisible(
      find.byKey(const Key('support_email_button')),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('support_email_button')), findsOneWidget);
    expect(find.text('support@truffly.com'), findsOneWidget);
  });

  testWidgets('expands FAQ answer', (tester) async {
    await tester.pumpWidget(_buildApp(_FakeAccountSupportLauncher(true)));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Browse available truffles, open a listing, review the product details, select a shipping address, and complete payment securely through Truffly.',
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('support_faq_buy_truffle')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Browse available truffles, open a listing, review the product details, select a shipping address, and complete payment securely through Truffly.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('tap on support CTA launches email flow', (tester) async {
    final launcher = _FakeAccountSupportLauncher(true);

    await tester.pumpWidget(_buildApp(launcher));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.byKey(const Key('support_email_button')),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('support_email_button')));
    await tester.pumpAndSettle();

    expect(launcher.callCount, 1);
  });

  testWidgets('shows feedback when email app cannot open', (tester) async {
    await tester.pumpWidget(_buildApp(_FakeAccountSupportLauncher(false)));
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.byKey(const Key('support_email_button')),
      find.byType(Scrollable).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('support_email_button')));
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to open your email app right now.'),
      findsOneWidget,
    );
  });
}
