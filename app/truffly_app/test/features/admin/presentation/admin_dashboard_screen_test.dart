import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:truffly_app/features/admin/presentation/admin_providers.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('admin dashboard blocks non-admin users', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserIsAdminProvider.overrideWith((ref) => false)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AdminDashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Access denied'), findsOneWidget);
    expect(find.text('Seller requests'), findsNothing);
  });
}
