import 'package:flutter/material.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class NotificationContent {
  const NotificationContent({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}

NotificationContent localizedNotificationContent(
  BuildContext context,
  AppNotification notification,
) {
  final l10n = AppLocalizations.of(context)!;
  final type = _canonicalType(notification.type);

  return NotificationContent(
    title: _titleForType(l10n, notification, type),
    message: _messageForType(l10n, notification, type),
    icon: _iconForType(type),
  );
}

String _titleForType(
  AppLocalizations l10n,
  AppNotification notification,
  String type,
) {
  return switch (type) {
    'order_confirmed' => l10n.notificationOrderConfirmedTitle,
    'payment_failed' => l10n.notificationPaymentFailedTitle,
    'order_shipped' => l10n.notificationOrderShippedTitle,
    'tracking_available' => l10n.notificationTrackingAvailableTitle,
    'delivery_confirmation_reminder' =>
      l10n.notificationDeliveryConfirmationReminderTitle,
    'order_completed' => l10n.notificationOrderCompletedTitle,
    'order_auto_completed' => l10n.notificationOrderAutoCompletedTitle,
    'order_cancelled_by_seller' => l10n.notificationOrderCancelledBySellerTitle,
    'order_auto_cancelled_unshipped' =>
      l10n.notificationOrderAutoCancelledUnshippedTitle,
    'refund_started' => l10n.notificationRefundStartedTitle,
    'refund_completed' => l10n.notificationRefundCompletedTitle,
    'review_request' => l10n.notificationReviewRequestTitle,
    'review_auto_created' => l10n.notificationReviewAutoCreatedTitle,
    'favorite_truffle_unavailable' =>
      l10n.notificationFavoriteTruffleUnavailableTitle,
    'favorite_truffle_expiring' =>
      l10n.notificationFavoriteTruffleExpiringTitle,
    'seller_application_submitted' =>
      l10n.notificationSellerApplicationSubmittedTitle,
    'seller_approved' => l10n.notificationSellerApprovedTitle,
    'seller_rejected' => l10n.notificationSellerRejectedTitle,
    'stripe_onboarding_required' =>
      l10n.notificationStripeOnboardingRequiredTitle,
    'stripe_onboarding_completed' =>
      l10n.notificationStripeOnboardingCompletedTitle,
    'truffle_published' => l10n.notificationTrufflePublishedTitle,
    'truffle_deleted' => l10n.notificationTruffleDeletedTitle,
    'truffle_expired' => l10n.notificationTruffleExpiredTitle,
    'seller_new_order' => l10n.notificationSellerNewOrderTitle,
    'seller_shipping_24h_reminder' =>
      l10n.notificationSellerShipping24hReminderTitle,
    'seller_shipping_final_reminder' =>
      l10n.notificationSellerShippingFinalReminderTitle,
    'seller_order_cancelled_unshipped' =>
      l10n.notificationSellerOrderCancelledUnshippedTitle,
    'seller_order_marked_shipped' =>
      l10n.notificationSellerOrderMarkedShippedTitle,
    'seller_delivery_confirmed_by_buyer' =>
      l10n.notificationSellerDeliveryConfirmedByBuyerTitle,
    'seller_order_auto_completed' =>
      l10n.notificationSellerOrderAutoCompletedTitle,
    'seller_payment_released' => l10n.notificationSellerPaymentReleasedTitle,
    'seller_payment_processing' =>
      l10n.notificationSellerPaymentProcessingTitle,
    'seller_payment_failed' => l10n.notificationSellerPaymentFailedTitle,
    'seller_new_review' => l10n.notificationSellerNewReviewTitle,
    'seller_auto_review_received' =>
      l10n.notificationSellerAutoReviewReceivedTitle,
    'profile_updated' => l10n.notificationProfileUpdatedTitle,
    'security_new_login' => l10n.notificationSecurityNewLoginTitle,
    'buyer_welcome' => l10n.notificationBuyerWelcomeTitle,
    _ => l10n.notificationGenericTitle,
  };
}

String _messageForType(
  AppLocalizations l10n,
  AppNotification notification,
  String type,
) {
  return switch (type) {
    'order_confirmed' => l10n.notificationOrderConfirmedMessage(
      _truffleName(l10n, notification),
    ),
    'payment_failed' => l10n.notificationPaymentFailedMessage(
      _truffleName(l10n, notification),
    ),
    'order_shipped' => l10n.notificationOrderShippedMessage(
      _truffleName(l10n, notification),
    ),
    'tracking_available' => l10n.notificationTrackingAvailableMessage(
      _truffleName(l10n, notification),
      _trackingCode(l10n, notification),
    ),
    'delivery_confirmation_reminder' =>
      l10n.notificationDeliveryConfirmationReminderMessage(
        _truffleName(l10n, notification),
      ),
    'order_completed' => l10n.notificationOrderCompletedMessage(
      _truffleName(l10n, notification),
    ),
    'order_auto_completed' => l10n.notificationOrderAutoCompletedMessage(
      _truffleName(l10n, notification),
    ),
    'order_cancelled_by_seller' =>
      l10n.notificationOrderCancelledBySellerMessage(
        _truffleName(l10n, notification),
      ),
    'order_auto_cancelled_unshipped' =>
      l10n.notificationOrderAutoCancelledUnshippedMessage(
        _truffleName(l10n, notification),
      ),
    'refund_started' => l10n.notificationRefundStartedMessage(
      _truffleName(l10n, notification),
    ),
    'refund_completed' => l10n.notificationRefundCompletedMessage(
      _truffleName(l10n, notification),
    ),
    'review_request' => l10n.notificationReviewRequestMessage(
      _sellerName(l10n, notification),
      _truffleName(l10n, notification),
    ),
    'review_auto_created' => l10n.notificationReviewAutoCreatedMessage(
      _truffleName(l10n, notification),
    ),
    'favorite_truffle_unavailable' =>
      l10n.notificationFavoriteTruffleUnavailableMessage(
        _truffleName(l10n, notification),
      ),
    'favorite_truffle_expiring' =>
      l10n.notificationFavoriteTruffleExpiringMessage(
        _truffleName(l10n, notification),
      ),
    'seller_application_submitted' =>
      l10n.notificationSellerApplicationSubmittedMessage,
    'seller_approved' => l10n.notificationSellerApprovedMessage,
    'seller_rejected' => l10n.notificationSellerRejectedMessage,
    'stripe_onboarding_required' =>
      l10n.notificationStripeOnboardingRequiredMessage,
    'stripe_onboarding_completed' =>
      l10n.notificationStripeOnboardingCompletedMessage,
    'truffle_published' => l10n.notificationTrufflePublishedMessage(
      _truffleName(l10n, notification),
    ),
    'truffle_deleted' => l10n.notificationTruffleDeletedMessage(
      _truffleName(l10n, notification),
    ),
    'truffle_expired' => l10n.notificationTruffleExpiredMessage(
      _truffleName(l10n, notification),
    ),
    'seller_new_order' => l10n.notificationSellerNewOrderMessage(
      _truffleName(l10n, notification),
    ),
    'seller_shipping_24h_reminder' =>
      l10n.notificationSellerShipping24hReminderMessage(
        _truffleName(l10n, notification),
      ),
    'seller_shipping_final_reminder' =>
      l10n.notificationSellerShippingFinalReminderMessage(
        _truffleName(l10n, notification),
      ),
    'seller_order_cancelled_unshipped' =>
      l10n.notificationSellerOrderCancelledUnshippedMessage(
        _truffleName(l10n, notification),
      ),
    'seller_order_marked_shipped' =>
      l10n.notificationSellerOrderMarkedShippedMessage(
        _truffleName(l10n, notification),
      ),
    'seller_delivery_confirmed_by_buyer' =>
      l10n.notificationSellerDeliveryConfirmedByBuyerMessage(
        _truffleName(l10n, notification),
      ),
    'seller_order_auto_completed' =>
      l10n.notificationSellerOrderAutoCompletedMessage(
        _truffleName(l10n, notification),
      ),
    'seller_payment_released' => l10n.notificationSellerPaymentReleasedMessage(
      _truffleName(l10n, notification),
      _sellerAmount(l10n, notification),
    ),
    'seller_payment_processing' =>
      l10n.notificationSellerPaymentProcessingMessage(
        _truffleName(l10n, notification),
      ),
    'seller_payment_failed' => l10n.notificationSellerPaymentFailedMessage(
      _truffleName(l10n, notification),
    ),
    'seller_new_review' => l10n.notificationSellerNewReviewMessage(
      _truffleName(l10n, notification),
    ),
    'seller_auto_review_received' =>
      l10n.notificationSellerAutoReviewReceivedMessage(
        _truffleName(l10n, notification),
      ),
    'profile_updated' => l10n.notificationProfileUpdatedMessage,
    'security_new_login' => l10n.notificationSecurityNewLoginMessage,
    'buyer_welcome' => l10n.notificationBuyerWelcomeMessage,
    _ =>
      notification.message.trim().isNotEmpty
          ? notification.message.trim()
          : l10n.notificationGenericMessage,
  };
}

String _canonicalType(String rawType) {
  return switch (rawType.trim()) {
    'buyer_review_created' => 'seller_new_review',
    'auto_review_created' => 'seller_auto_review_received',
    'order_delivery_confirmation_reminder' => 'delivery_confirmation_reminder',
    'favorite_truffle_deleted' => 'favorite_truffle_unavailable',
    'order_auto_cancelled_unshipped_48h_buyer' =>
      'order_auto_cancelled_unshipped',
    'order_auto_cancelled_unshipped_48h_seller' =>
      'seller_order_cancelled_unshipped',
    'payout_released' => 'seller_payment_released',
    _ => rawType.trim(),
  };
}

IconData _iconForType(String type) {
  return switch (type) {
    'order_confirmed' || 'seller_new_order' => Icons.shopping_bag_outlined,
    'payment_failed' || 'seller_payment_failed' => Icons.error_outline_rounded,
    'order_shipped' ||
    'tracking_available' ||
    'seller_order_marked_shipped' ||
    'seller_shipping_24h_reminder' ||
    'seller_shipping_final_reminder' => Icons.local_shipping_outlined,
    'delivery_confirmation_reminder' => Icons.notifications_active_outlined,
    'order_completed' ||
    'order_auto_completed' ||
    'seller_delivery_confirmed_by_buyer' ||
    'seller_order_auto_completed' => Icons.check_circle_outline_rounded,
    'order_cancelled_by_seller' ||
    'order_auto_cancelled_unshipped' ||
    'seller_order_cancelled_unshipped' ||
    'refund_started' ||
    'refund_completed' => Icons.cancel_outlined,
    'review_request' ||
    'review_auto_created' ||
    'seller_new_review' ||
    'seller_auto_review_received' => Icons.reviews_outlined,
    'seller_application_submitted' => Icons.hourglass_bottom_rounded,
    'seller_approved' => Icons.verified_outlined,
    'seller_rejected' => Icons.close_rounded,
    'stripe_onboarding_required' ||
    'stripe_onboarding_completed' ||
    'seller_payment_released' ||
    'seller_payment_processing' => Icons.account_balance_wallet_outlined,
    'truffle_published' ||
    'truffle_deleted' ||
    'truffle_expired' ||
    'favorite_truffle_unavailable' ||
    'favorite_truffle_expiring' ||
    'buyer_welcome' => Icons.spa_outlined,
    'profile_updated' => Icons.person_outline_rounded,
    'security_new_login' => Icons.security_rounded,
    _ => Icons.notifications_none_rounded,
  };
}

String _truffleName(AppLocalizations l10n, AppNotification notification) {
  return _metadataString(notification, 'truffle_name') ??
      l10n.notificationFallbackTruffleName;
}

String _sellerName(AppLocalizations l10n, AppNotification notification) {
  return _metadataString(notification, 'seller_name') ??
      l10n.notificationFallbackSellerName;
}

String _trackingCode(AppLocalizations l10n, AppNotification notification) {
  return _metadataString(notification, 'tracking_code') ??
      l10n.notificationFallbackTrackingCode;
}

String _sellerAmount(AppLocalizations l10n, AppNotification notification) {
  return _metadataString(notification, 'seller_amount') ??
      l10n.notificationFallbackSellerAmount;
}

String? _metadataString(AppNotification notification, String key) {
  final value = notification.metadata[key];
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  if (value is num) {
    return value.toString();
  }
  return null;
}
