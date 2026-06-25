import 'dart:convert';

import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';

final class PushNotificationPayload {
  const PushNotificationPayload({
    required this.type,
    required this.targetRoute,
    required this.targetId,
    required this.notificationId,
    required this.metadata,
  });

  final String type;
  final String? targetRoute;
  final String? targetId;
  final String? notificationId;
  final Map<String, Object?> metadata;

  String? resolveRoute({String? currentUserId}) {
    return resolveNotificationRoute(
      AppNotification(
        id: notificationId ?? '',
        type: type,
        message: '',
        isRead: true,
        createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        targetRoute: targetRoute,
        targetId: targetId,
        metadata: metadata,
      ),
      currentUserId: currentUserId,
    );
  }
}

String? resolveNotificationRoute(
  AppNotification notification, {
  String? currentUserId,
}) {
  final explicit = _resolveExplicitRoute(
    notification.targetRoute,
    targetId: notification.targetId,
    currentUserId: currentUserId,
  );
  if (explicit != null) {
    return explicit;
  }

  final orderId = _readValue(notification, 'order_id') ?? notification.targetId;
  final truffleId =
      _readValue(notification, 'truffle_id') ?? notification.targetId;

  return switch (notification.type.trim()) {
    'order_confirmed' ||
    'order_shipped' ||
    'tracking_available' ||
    'delivery_confirmation_reminder' ||
    'order_completed' ||
    'order_auto_completed' ||
    'order_cancelled_by_seller' ||
    'order_auto_cancelled_unshipped' ||
    'refund_started' ||
    'refund_completed' when orderId != null => AppRoutes.accountOrderDetailPath(
      orderId,
    ),
    'review_request' when orderId != null =>
      '${AppRoutes.accountOrderDetailPath(orderId)}?openReview=true',
    'favorite_truffle_unavailable' => AppRoutes.accountFavorites,
    'favorite_truffle_expiring' when truffleId != null =>
      AppRoutes.truffleDetailPath(truffleId),
    'seller_application_submitted' ||
    'seller_approved' ||
    'seller_rejected' ||
    'stripe_onboarding_required' ||
    'stripe_onboarding_completed' => AppRoutes.accountBecomeSeller,
    'truffle_published' when truffleId != null => AppRoutes.truffleDetailPath(
      truffleId,
    ),
    'truffle_deleted' || 'truffle_expired' => AppRoutes.accountMyTruffles,
    'seller_new_order' ||
    'seller_shipping_24h_reminder' ||
    'seller_shipping_final_reminder' ||
    'seller_order_cancelled_unshipped' ||
    'seller_order_marked_shipped' ||
    'seller_delivery_confirmed_by_buyer' ||
    'seller_order_auto_completed' ||
    'seller_payment_released' ||
    'seller_payment_processing' ||
    'seller_payment_failed' when orderId != null =>
      AppRoutes.accountOrderDetailPath(orderId),
    'seller_new_review' || 'seller_auto_review_received'
        when currentUserId != null =>
      AppRoutes.sellerProfilePath(currentUserId),
    'profile_updated' => AppRoutes.accountDetails,
    'security_new_login' => AppRoutes.accountSettings,
    'buyer_welcome' => AppRoutes.truffles,
    _ => AppRoutes.notifications,
  };
}

String? resolveNotificationRouteFromPushData(
  Map<String, dynamic> data, {
  String? currentUserId,
}) {
  return parsePushNotificationPayload(
    data,
  ).resolveRoute(currentUserId: currentUserId);
}

PushNotificationPayload parsePushNotificationPayload(
  Map<String, dynamic> data,
) {
  return PushNotificationPayload(
    type:
        (data['notification_type'] as String?)?.trim() ??
        (data['type'] as String?)?.trim() ??
        '',
    targetRoute: _trimmedString(data['target_route']),
    targetId: _trimmedString(data['target_id']),
    notificationId: _trimmedString(data['notification_id']),
    metadata: _parseMetadata(data['metadata']),
  );
}

String? _resolveExplicitRoute(
  String? rawRoute, {
  required String? targetId,
  required String? currentUserId,
}) {
  final route = rawRoute?.trim();
  if (route == null || route.isEmpty) {
    return null;
  }

  if (route.startsWith('/orders/') && route.endsWith('/review')) {
    final orderId = _extractTailId(route, 'orders', fallback: targetId);
    return orderId == null
        ? AppRoutes.notifications
        : '${AppRoutes.accountOrderDetailPath(orderId)}?openReview=true';
  }
  if (route.startsWith('/orders/')) {
    final orderId = _extractTailId(route, 'orders', fallback: targetId);
    return orderId == null
        ? AppRoutes.notifications
        : AppRoutes.accountOrderDetailPath(orderId);
  }
  if (route.startsWith('/seller/orders/')) {
    final orderId = _extractTailId(route, 'orders', fallback: targetId);
    return orderId == null
        ? AppRoutes.notifications
        : AppRoutes.accountOrderDetailPath(orderId);
  }
  if (route.startsWith('/truffles/')) {
    final truffleId = _extractTailId(route, 'truffles', fallback: targetId);
    return truffleId == null
        ? AppRoutes.notifications
        : AppRoutes.truffleDetailPath(truffleId);
  }
  if (route == '/favorites') {
    return AppRoutes.accountFavorites;
  }
  if (route == '/account/seller-status' ||
      route == '/account/payments/stripe') {
    return AppRoutes.accountBecomeSeller;
  }
  if (route == '/seller/truffles/new') {
    return AppRoutes.accountMyTruffles;
  }
  if (route == '/seller/profile/reviews') {
    return currentUserId == null
        ? AppRoutes.account
        : AppRoutes.sellerProfilePath(currentUserId);
  }
  if (route == '/account/details') {
    return AppRoutes.accountDetails;
  }
  if (route == '/settings/security') {
    return AppRoutes.accountSettings;
  }
  if (route == '/notifications') {
    return AppRoutes.notifications;
  }

  return route.startsWith('/') ? route : null;
}

String? _extractTailId(String route, String segment, {String? fallback}) {
  final parts = route.split('/').where((part) => part.isNotEmpty).toList();
  final index = parts.indexOf(segment);
  if (index == -1 || index + 1 >= parts.length) {
    return fallback;
  }
  final value = parts[index + 1].trim();
  return value.isEmpty ? fallback : value;
}

String? _readValue(AppNotification notification, String key) {
  final value = notification.metadata[key];
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String? _trimmedString(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

Map<String, Object?> _parseMetadata(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return {
          for (final entry in decoded.entries)
            entry.key.toString(): entry.value,
        };
      }
    } catch (_) {
      return const {};
    }
  }
  if (raw is Map) {
    return {for (final entry in raw.entries) entry.key.toString(): entry.value};
  }
  return const {};
}
