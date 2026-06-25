import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';
import 'package:truffly_app/features/notifications/presentation/notification_route_resolver.dart';

void main() {
  test('maps review targets to order detail with review flag', () {
    final route = resolveNotificationRoute(
      AppNotification(
        id: 'n1',
        type: 'review_request',
        message: '',
        isRead: false,
        createdAt: DateTime(2026, 6, 14),
        targetRoute: '/orders/order-1/review',
        targetId: 'order-1',
        metadata: const {'order_id': 'order-1'},
      ),
      currentUserId: 'seller-1',
    );

    expect(
      route,
      '${AppRoutes.accountOrderDetailPath('order-1')}?openReview=true',
    );
  });

  test('maps seller review inbox route to current seller profile', () {
    final route = resolveNotificationRoute(
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
      currentUserId: 'seller-42',
    );

    expect(route, AppRoutes.sellerProfilePath('seller-42'));
  });

  test('parses push payload metadata and falls back to notifications inbox', () {
    final route = resolveNotificationRouteFromPushData(
      {
        'type': 'generic',
        'notification_id': 'notif-1',
        'target_route': '   ',
        'target_id': 'target-1',
        'metadata': '{"foo":"bar","count":2}',
      },
      currentUserId: 'user-1',
    );

    expect(route, AppRoutes.notifications);
  });

  test('parses push payload explicit route for order detail', () {
    final payload = parsePushNotificationPayload(
      {
        'notification_type': 'order_completed',
        'notification_id': 'notif-2',
        'target_route': '/orders/order-55',
        'target_id': 'order-55',
        'metadata': {'order_id': 'order-55'},
      },
    );

    expect(payload.notificationId, 'notif-2');
    expect(payload.targetRoute, '/orders/order-55');
    expect(payload.targetId, 'order-55');
    expect(payload.metadata['order_id'], 'order-55');
    expect(
      payload.resolveRoute(currentUserId: 'user-1'),
      AppRoutes.accountOrderDetailPath('order-55'),
    );
  });
}
