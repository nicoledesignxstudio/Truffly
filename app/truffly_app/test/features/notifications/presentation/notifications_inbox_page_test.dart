import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/features/notifications/application/notifications_providers.dart';
import 'package:truffly_app/features/notifications/data/notifications_repository.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';
import 'package:truffly_app/features/notifications/presentation/notifications_inbox_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';

void main() {
  testWidgets('shows loading state while notifications resolve', (
    tester,
  ) async {
    final completer = Completer<List<AppNotification>>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsInboxProvider.overrideWith((ref) => completer.future),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NotificationsInboxPage(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows empty state when there are no notifications', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsInboxProvider.overrideWith((ref) async => const []),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NotificationsInboxPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.text('You are all caught up. New updates will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('renders notification titles and messages', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsInboxProvider.overrideWith(
            (ref) async => [
              AppNotification(
                id: 'n1',
                type: 'order_completed',
                message: '',
                isRead: false,
                createdAt: DateTime(2026, 4, 1, 10, 30),
                targetRoute: '/orders/order-1',
                targetId: 'order-1',
                metadata: const {
                  'order_id': 'order-1',
                  'truffle_name': 'White Truffle',
                },
              ),
              AppNotification(
                id: 'n2',
                type: 'tracking_available',
                message: '',
                isRead: true,
                createdAt: DateTime(2026, 4, 1, 11, 30),
                targetRoute: '/orders/order-2',
                targetId: 'order-2',
                metadata: const {
                  'order_id': 'order-2',
                  'truffle_name': 'Black Truffle',
                  'tracking_code': 'TRACK-2',
                },
              ),
            ],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NotificationsInboxPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Order completed'), findsOneWidget);
    expect(find.text('Tracking available'), findsOneWidget);
    expect(
      find.text('The order “White Truffle” has been completed.'),
      findsOneWidget,
    );
    expect(
      find.text('Tracking is available for “Black Truffle”: TRACK-2.'),
      findsOneWidget,
    );
  });

  testWidgets('marks notification as read and routes on tap', (tester) async {
    final repository = _FakeNotificationsRepository();
    final router = GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsInboxPage(),
        ),
        GoRoute(
          path: '/account/orders/:orderId',
          builder: (context, state) => Text(state.pathParameters['orderId']!),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationsInboxProvider.overrideWith(
            (ref) async => [
              AppNotification(
                id: 'n1',
                type: 'order_completed',
                message: '',
                isRead: false,
                createdAt: DateTime(2026, 4, 1, 10, 30),
                targetRoute: '/orders/order-99',
                targetId: 'order-99',
                metadata: const {
                  'order_id': 'order-99',
                  'truffle_name': 'White Truffle',
                },
              ),
            ],
          ),
          notificationsRepositoryProvider.overrideWithValue(repository),
          currentUserAccountProfileProvider.overrideWith(
            (ref) async => const CurrentUserProfile(
              userId: 'user-1',
              email: 'user@example.com',
              onboardingCompleted: true,
              firstName: 'User',
              lastName: 'One',
              role: 'buyer',
              sellerStatus: 'not_requested',
              countryCode: 'IT',
              region: 'PIE',
              bio: null,
              profileImageUrl: null,
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Order completed'));
    await tester.pumpAndSettle();

    expect(repository.markedIds, ['n1']);
    expect(find.text('order-99'), findsOneWidget);
  });
}

class _FakeNotificationsRepository extends NotificationsRepository {
  _FakeNotificationsRepository() : super(_NoopSupabaseClient());

  final List<String> markedIds = [];

  @override
  Future<void> markAsRead(String notificationId) async {
    markedIds.add(notificationId);
  }
}

class _NoopSupabaseClient {}
