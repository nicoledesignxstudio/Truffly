import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';
import 'package:truffly_app/features/notifications/presentation/notification_content.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  testWidgets('renders localized notification text from metadata', (
    tester,
  ) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final content = localizedNotificationContent(
      capturedContext,
      AppNotification(
        id: 'n1',
        type: 'tracking_available',
        message: '',
        isRead: false,
        createdAt: DateTime(2026, 6, 14),
        targetRoute: '/orders/order-1',
        targetId: 'order-1',
        metadata: const {
          'order_id': 'order-1',
          'truffle_name': 'Black Summer Truffle',
          'tracking_code': 'TRACK-42',
        },
      ),
    );

    expect(content.title, 'Tracking available');
    expect(
      content.message,
      'Tracking is available for “Black Summer Truffle”: TRACK-42.',
    );
  });

  testWidgets('falls back when metadata is missing', (tester) async {
    late BuildContext capturedContext;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('it'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    final content = localizedNotificationContent(
      capturedContext,
      AppNotification(
        id: 'n2',
        type: 'seller_new_review',
        message: '',
        isRead: false,
        createdAt: DateTime(2026, 6, 14),
        targetRoute: '/seller/profile/reviews',
        targetId: null,
        metadata: const {},
      ),
    );

    expect(content.title, 'Nuova recensione');
    expect(
      content.message,
      'Hai ricevuto una nuova recensione per “il tuo tartufo”.',
    );
  });
}
