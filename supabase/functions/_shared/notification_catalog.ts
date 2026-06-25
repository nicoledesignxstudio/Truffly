export type NotificationMetadata = Record<string, unknown>;

export const highImportanceNotificationTypes = new Set([
  "order_confirmed",
  "order_shipped",
  "order_auto_cancelled_unshipped",
  "refund_started",
  "refund_completed",
  "delivery_confirmation_reminder",
  "order_completed",
  "review_request",
  "seller_approved",
  "seller_rejected",
  "seller_new_order",
  "seller_shipping_24h_reminder",
  "seller_shipping_final_reminder",
  "seller_order_cancelled_unshipped",
  "seller_payment_released",
  "seller_new_review",
]);

const italianPushFallbacks: Record<
  string,
  { title: string; body: (metadata: NotificationMetadata) => string }
> = {
  order_confirmed: pushFallback(
    "Ordine confermato",
    (m) =>
      `Il tuo ordine per "${
        truffleName(m)
      }" è stato confermato. Il venditore ha 48 ore per spedirlo.`,
  ),
  order_shipped: pushFallback(
    "Ordine spedito",
    (m) => `Il tuo ordine per "${truffleName(m)}" è stato spedito.`,
  ),
  order_auto_cancelled_unshipped: pushFallback(
    "Ordine annullato",
    (m) =>
      `L'ordine per "${
        truffleName(m)
      }" è stato annullato perché non è stato spedito entro 48 ore.`,
  ),
  refund_started: pushFallback(
    "Rimborso avviato",
    (m) => `Il rimborso per "${truffleName(m)}" è stato avviato.`,
  ),
  refund_completed: pushFallback(
    "Rimborso completato",
    (m) => `Il rimborso per "${truffleName(m)}" è stato completato.`,
  ),
  delivery_confirmation_reminder: pushFallback(
    "Conferma la consegna",
    (m) =>
      `Hai ricevuto "${
        truffleName(m)
      }"? Conferma la consegna per completare l'ordine.`,
  ),
  order_completed: pushFallback(
    "Ordine completato",
    (m) => `L'ordine per "${truffleName(m)}" è stato completato.`,
  ),
  review_request: pushFallback(
    "Lascia una recensione",
    (m) => `Raccontaci com'è andata con "${truffleName(m)}".`,
  ),
  seller_approved: pushFallback(
    "Venditore approvato",
    () =>
      "La tua richiesta è stata approvata. Completa Stripe per iniziare a pubblicare tartufi.",
  ),
  seller_rejected: pushFallback(
    "Richiesta non approvata",
    () =>
      "La tua richiesta come venditore non è stata approvata. Controlla i dettagli o contatta l'assistenza.",
  ),
  seller_new_order: pushFallback(
    "Nuovo ordine ricevuto",
    (m) =>
      `Hai ricevuto un nuovo ordine per "${
        truffleName(m)
      }". Spediscilo entro 48 ore.`,
  ),
  seller_shipping_24h_reminder: pushFallback(
    "Promemoria spedizione",
    (m) =>
      `Ricordati di spedire "${
        truffleName(m)
      }". Hai ancora 24 ore per aggiungere il tracking.`,
  ),
  seller_shipping_final_reminder: pushFallback(
    "Ultimo promemoria spedizione",
    (m) =>
      `Ultime ore per spedire "${
        truffleName(m)
      }". Senza tracking l'ordine verrà annullato.`,
  ),
  seller_order_cancelled_unshipped: pushFallback(
    "Ordine annullato",
    (m) =>
      `L'ordine per "${
        truffleName(m)
      }" è stato annullato perché non è stato spedito entro 48 ore.`,
  ),
  seller_payment_released: pushFallback(
    "Pagamento rilasciato",
    (m) => `Il pagamento per "${truffleName(m)}" è stato rilasciato.`,
  ),
  seller_new_review: pushFallback(
    "Nuova recensione",
    (m) => `Hai ricevuto una nuova recensione per "${truffleName(m)}".`,
  ),
};

type NotificationDescriptor = {
  titleKey: string;
  bodyKey: string;
  defaultTitle: string;
  defaultBody: (metadata: NotificationMetadata) => string;
  defaultTargetRoute?: string;
  defaultTargetIdKey?: string;
};

const fallbackTruffleName = "your truffle";
const fallbackSellerName = "the seller";
const fallbackTrackingCode = "tracking unavailable";
const fallbackSellerAmount = "your payout";

const descriptors: Record<string, NotificationDescriptor> = {
  order_confirmed: descriptor(
    "notificationOrderConfirmedTitle",
    "notificationOrderConfirmedMessage",
    "Order confirmed",
    (m) =>
      `Your order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been confirmed. The seller has 48 hours to ship it.`,
    "/orders/{orderId}",
    "order_id",
  ),
  payment_failed: descriptor(
    "notificationPaymentFailedTitle",
    "notificationPaymentFailedMessage",
    "Payment failed",
    (m) =>
      `The payment for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” failed. You can try again from checkout.`,
    "/truffles/{truffleId}",
    "truffle_id",
  ),
  order_shipped: descriptor(
    "notificationOrderShippedTitle",
    "notificationOrderShippedMessage",
    "Order shipped",
    (m) =>
      `Your order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been shipped.`,
    "/orders/{orderId}",
    "order_id",
  ),
  tracking_available: descriptor(
    "notificationTrackingAvailableTitle",
    "notificationTrackingAvailableMessage",
    "Tracking available",
    (m) =>
      `Tracking is available for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”: ${readString(m, "tracking_code") ?? fallbackTrackingCode}.`,
    "/orders/{orderId}",
    "order_id",
  ),
  delivery_confirmation_reminder: descriptor(
    "notificationDeliveryConfirmationReminderTitle",
    "notificationDeliveryConfirmationReminderMessage",
    "Confirm delivery",
    (m) =>
      `Have you received “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”? Confirm delivery to complete the order.`,
    "/orders/{orderId}",
    "order_id",
  ),
  order_completed: descriptor(
    "notificationOrderCompletedTitle",
    "notificationOrderCompletedMessage",
    "Order completed",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been completed.`,
    "/orders/{orderId}",
    "order_id",
  ),
  order_auto_completed: descriptor(
    "notificationOrderAutoCompletedTitle",
    "notificationOrderAutoCompletedMessage",
    "Order automatically completed",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” was automatically completed.`,
    "/orders/{orderId}",
    "order_id",
  ),
  order_cancelled_by_seller: descriptor(
    "notificationOrderCancelledBySellerTitle",
    "notificationOrderCancelledBySellerMessage",
    "Order cancelled",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” was cancelled by the seller. Your refund will be started.`,
    "/orders/{orderId}",
    "order_id",
  ),
  order_auto_cancelled_unshipped: descriptor(
    "notificationOrderAutoCancelledUnshippedTitle",
    "notificationOrderAutoCancelledUnshippedMessage",
    "Order cancelled",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” was cancelled because it was not shipped within 48 hours.`,
    "/orders/{orderId}",
    "order_id",
  ),
  refund_started: descriptor(
    "notificationRefundStartedTitle",
    "notificationRefundStartedMessage",
    "Refund started",
    (m) =>
      `The refund for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been started.`,
    "/orders/{orderId}",
    "order_id",
  ),
  refund_completed: descriptor(
    "notificationRefundCompletedTitle",
    "notificationRefundCompletedMessage",
    "Refund completed",
    (m) =>
      `The refund for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been completed.`,
    "/orders/{orderId}",
    "order_id",
  ),
  review_request: descriptor(
    "notificationReviewRequestTitle",
    "notificationReviewRequestMessage",
    "Leave a review",
    (m) =>
      `How was your experience with “${
        readString(m, "seller_name") ?? fallbackSellerName
      }”? Leave a review for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”.`,
    "/orders/{orderId}/review",
    "order_id",
  ),
  review_auto_created: descriptor(
    "notificationReviewAutoCreatedTitle",
    "notificationReviewAutoCreatedMessage",
    "Automatic review",
    (m) =>
      `We automatically completed the review for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”.`,
    "/orders/{orderId}",
    "order_id",
  ),
  favorite_truffle_unavailable: descriptor(
    "notificationFavoriteTruffleUnavailableTitle",
    "notificationFavoriteTruffleUnavailableMessage",
    "Truffle no longer available",
    (m) =>
      `“${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” is no longer available.`,
    "/favorites",
  ),
  favorite_truffle_expiring: descriptor(
    "notificationFavoriteTruffleExpiringTitle",
    "notificationFavoriteTruffleExpiringMessage",
    "Listing expiring soon",
    (m) =>
      `“${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” is still available, but the listing is about to expire.`,
    "/truffles/{truffleId}",
    "truffle_id",
  ),
  seller_application_submitted: descriptor(
    "notificationSellerApplicationSubmittedTitle",
    "notificationSellerApplicationSubmittedMessage",
    "Request submitted",
    () =>
      "Your request to sell on Truffly has been submitted. We’ll notify you once it has been reviewed.",
    "/account/seller-status",
  ),
  seller_approved: descriptor(
    "notificationSellerApprovedTitle",
    "notificationSellerApprovedMessage",
    "Seller approved",
    () =>
      "You have been approved as a seller. Complete Stripe to start publishing truffles.",
    "/account/payments/stripe",
  ),
  seller_rejected: descriptor(
    "notificationSellerRejectedTitle",
    "notificationSellerRejectedMessage",
    "Request not approved",
    () =>
      "Your seller request was not approved. Check the details or contact support.",
    "/account/seller-status",
  ),
  stripe_onboarding_required: descriptor(
    "notificationStripeOnboardingRequiredTitle",
    "notificationStripeOnboardingRequiredMessage",
    "Set up payments",
    () => "Complete your payment setup to start selling on Truffly.",
    "/account/payments/stripe",
  ),
  stripe_onboarding_completed: descriptor(
    "notificationStripeOnboardingCompletedTitle",
    "notificationStripeOnboardingCompletedMessage",
    "Payments set up",
    () => "Payments are set up. You can now publish your truffles.",
    "/seller/truffles/new",
  ),
  truffle_published: descriptor(
    "notificationTrufflePublishedTitle",
    "notificationTrufflePublishedMessage",
    "Truffle published",
    (m) =>
      `“${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been published and is now visible to users.`,
    "/truffles/{truffleId}",
    "truffle_id",
  ),
  truffle_deleted: descriptor(
    "notificationTruffleDeletedTitle",
    "notificationTruffleDeletedMessage",
    "Truffle deleted",
    (m) =>
      `“${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been deleted.`,
    "/seller/truffles",
  ),
  truffle_expired: descriptor(
    "notificationTruffleExpiredTitle",
    "notificationTruffleExpiredMessage",
    "Listing expired",
    (m) =>
      `The listing “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has expired and is no longer visible.`,
    "/seller/truffles",
  ),
  seller_new_order: descriptor(
    "notificationSellerNewOrderTitle",
    "notificationSellerNewOrderMessage",
    "New order received",
    (m) =>
      `You received a new order for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”. Ship it within 48 hours.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_shipping_24h_reminder: descriptor(
    "notificationSellerShipping24hReminderTitle",
    "notificationSellerShipping24hReminderMessage",
    "Shipping reminder",
    (m) =>
      `Remember to ship “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”. You still have 24 hours to add tracking.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_shipping_final_reminder: descriptor(
    "notificationSellerShippingFinalReminderTitle",
    "notificationSellerShippingFinalReminderMessage",
    "Final shipping reminder",
    (m) =>
      `Last hours to ship “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”. If you do not add tracking, the order will be cancelled.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_order_cancelled_unshipped: descriptor(
    "notificationSellerOrderCancelledUnshippedTitle",
    "notificationSellerOrderCancelledUnshippedMessage",
    "Order cancelled",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” was cancelled because it was not shipped within 48 hours.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_order_marked_shipped: descriptor(
    "notificationSellerOrderMarkedShippedTitle",
    "notificationSellerOrderMarkedShippedMessage",
    "Order shipped",
    (m) =>
      `You marked “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” as shipped. We’ll notify the buyer.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_delivery_confirmed_by_buyer: descriptor(
    "notificationSellerDeliveryConfirmedByBuyerTitle",
    "notificationSellerDeliveryConfirmedByBuyerMessage",
    "Delivery confirmed",
    (m) =>
      `The buyer confirmed delivery of “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_order_auto_completed: descriptor(
    "notificationSellerOrderAutoCompletedTitle",
    "notificationSellerOrderAutoCompletedMessage",
    "Order automatically completed",
    (m) =>
      `The order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” was automatically completed.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_payment_released: descriptor(
    "notificationSellerPaymentReleasedTitle",
    "notificationSellerPaymentReleasedMessage",
    "Payment released",
    (m) =>
      `The payment for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” has been released. You will receive ${
        readString(m, "seller_amount") ?? fallbackSellerAmount
      }.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_payment_processing: descriptor(
    "notificationSellerPaymentProcessingTitle",
    "notificationSellerPaymentProcessingMessage",
    "Payment processing",
    (m) =>
      `The payment for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }” is being processed.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_payment_failed: descriptor(
    "notificationSellerPaymentFailedTitle",
    "notificationSellerPaymentFailedMessage",
    "Payment issue",
    (m) =>
      `There is an issue with the payment for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”. We are checking it.`,
    "/seller/orders/{orderId}",
    "order_id",
  ),
  seller_new_review: descriptor(
    "notificationSellerNewReviewTitle",
    "notificationSellerNewReviewMessage",
    "New review",
    (m) =>
      `You received a new review for “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”.`,
    "/seller/profile/reviews",
  ),
  seller_auto_review_received: descriptor(
    "notificationSellerAutoReviewReceivedTitle",
    "notificationSellerAutoReviewReceivedMessage",
    "Automatic review received",
    (m) =>
      `An automatic review was added for the order “${
        readString(m, "truffle_name") ?? fallbackTruffleName
      }”.`,
    "/seller/profile/reviews",
  ),
  profile_updated: descriptor(
    "notificationProfileUpdatedTitle",
    "notificationProfileUpdatedMessage",
    "Profile updated",
    () => "Your profile changes have been saved.",
    "/account/details",
  ),
  security_new_login: descriptor(
    "notificationSecurityNewLoginTitle",
    "notificationSecurityNewLoginMessage",
    "New login",
    () => "A new login to your account was detected.",
    "/settings/security",
  ),
};

export function buildNotificationEnvelope(args: {
  type: string;
  metadata?: NotificationMetadata;
  title?: string;
  message?: string;
  targetRoute?: string;
  targetId?: string;
}) {
  const metadata = args.metadata ?? {};
  const descriptor = descriptors[args.type];
  const resolvedTargetRoute = args.targetRoute ??
    resolveTargetRoute(args.type, metadata);
  const resolvedTargetId = args.targetId ??
    resolveTargetId(args.type, metadata);

  return {
    type: args.type,
    titleKey: descriptor?.titleKey ?? "notificationGenericTitle",
    bodyKey: descriptor?.bodyKey ?? "notificationGenericMessage",
    title: args.title ?? descriptor?.defaultTitle ?? "Notification",
    message: args.message ??
      descriptor?.defaultBody(metadata) ??
      "Open the notification center to view the latest update.",
    targetRoute: resolvedTargetRoute,
    targetId: resolvedTargetId,
    metadata,
  };
}

export function buildPushData(
  envelope: ReturnType<typeof buildNotificationEnvelope>,
) {
  const data: Record<string, string> = {
    type: envelope.type,
    notification_type: envelope.type,
    title_key: envelope.titleKey,
    body_key: envelope.bodyKey,
  };

  const encodedMetadata = safeJsonString(envelope.metadata);
  if (encodedMetadata) {
    data.metadata = encodedMetadata;
  }
  if (envelope.targetRoute) {
    data.target_route = envelope.targetRoute;
  }
  if (envelope.targetId) {
    data.target_id = envelope.targetId;
  }

  for (const [key, value] of Object.entries(envelope.metadata)) {
    const safeValue = safeDataValue(value);
    if (safeValue != null) data[key] = safeValue;
  }

  return data;
}

export function buildItalianPushContent(args: {
  type: string;
  metadata?: NotificationMetadata;
  title?: string;
  body?: string;
}): { title: string; body: string } {
  const fallback = italianPushFallbacks[args.type];
  const metadata = args.metadata ?? {};
  return {
    title: args.title?.trim() || fallback?.title || "Truffly",
    body: args.body?.trim() ||
      fallback?.body(metadata) ||
      "Apri Truffly per vedere il nuovo aggiornamento.",
  };
}

export function isHighImportanceNotification(type: string): boolean {
  return highImportanceNotificationTypes.has(type.trim());
}

function descriptor(
  titleKey: string,
  bodyKey: string,
  defaultTitle: string,
  defaultBody: NotificationDescriptor["defaultBody"],
  defaultTargetRoute?: string,
  defaultTargetIdKey?: string,
): NotificationDescriptor {
  return {
    titleKey,
    bodyKey,
    defaultTitle,
    defaultBody,
    defaultTargetRoute,
    defaultTargetIdKey,
  };
}

function resolveTargetRoute(
  type: string,
  metadata: NotificationMetadata,
): string | null {
  const descriptor = descriptors[type];
  if (!descriptor?.defaultTargetRoute) return null;
  if (
    descriptor.defaultTargetRoute.includes("{orderId}") &&
    readString(metadata, "order_id") == null
  ) {
    return null;
  }
  if (
    descriptor.defaultTargetRoute.includes("{truffleId}") &&
    readString(metadata, "truffle_id") == null
  ) {
    return null;
  }
  return descriptor.defaultTargetRoute
    .replace("{orderId}", readString(metadata, "order_id") ?? "")
    .replace("{truffleId}", readString(metadata, "truffle_id") ?? "");
}

function resolveTargetId(
  type: string,
  metadata: NotificationMetadata,
): string | null {
  const descriptor = descriptors[type];
  if (!descriptor?.defaultTargetIdKey) return null;
  return readString(metadata, descriptor.defaultTargetIdKey);
}

function readString(
  metadata: NotificationMetadata,
  key: string,
): string | null {
  const value = metadata[key];
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }
  if (typeof value === "number") {
    return value.toString();
  }
  return null;
}

function pushFallback(
  title: string,
  body: (metadata: NotificationMetadata) => string,
) {
  return { title, body };
}

function truffleName(metadata: NotificationMetadata): string {
  return readString(metadata, "truffle_name") ?? "il tuo tartufo";
}

function safeDataValue(value: unknown): string | null {
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed && trimmed.length <= 1000 ? trimmed : null;
  }
  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }
  if (typeof value === "boolean") {
    return String(value);
  }
  return null;
}

function safeJsonString(value: unknown): string | null {
  try {
    const encoded = JSON.stringify(value);
    return encoded.length <= 3000 ? encoded : null;
  } catch {
    return null;
  }
}
