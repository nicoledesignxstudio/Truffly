type JsonPrimitive = string | number | boolean | null;
type JsonValue = JsonPrimitive | JsonObject | JsonValue[];
type JsonObject = { [key: string]: JsonValue };

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type, stripe-signature, x-request-id, x-correlation-id",
};

const stripeApiBaseUrl = "https://api.stripe.com/v1";
const paymentAttemptExpiryMinutes = 30;
const webhookSignatureToleranceSeconds = 300;

export type PaymentAttemptStatus =
  | "requires_payment_method"
  | "succeeded"
  | "failed"
  | "expired";

export type StripeWebhookProcessingStatus =
  | "processing"
  | "processed"
  | "failed"
  | "ignored";

export type CreatePaymentIntentErrorCode =
  | "method_not_allowed"
  | "unauthorized"
  | "user_not_found"
  | "inactive_account"
  | "invalid_json_body"
  | "invalid_payment_attempt_id"
  | "invalid_truffle_id"
  | "invalid_shipping_address_id"
  | "shipping_address_not_found"
  | "truffle_not_found"
  | "truffle_not_available"
  | "self_purchase_forbidden"
  | "forbidden"
  | "payment_attempt_payload_mismatch"
  | "payment_attempt_already_succeeded"
  | "payment_attempt_failed"
  | "payment_attempt_expired"
  | "payment_attempt_not_found"
  | "payment_intent_not_ready"
  | "payment_attempt_in_progress_for_truffle"
  | "stripe_api_error"
  | "payment_unknown_error";

export type StripeWebhookErrorCode =
  | "method_not_allowed"
  | "missing_webhook_signature"
  | "invalid_webhook_signature"
  | "invalid_webhook_payload"
  | "payment_attempt_not_found"
  | "payment_attempt_mismatch"
  | "payment_attempt_order_creation_failed"
  | "webhook_unknown_error";

export class AppError extends Error {
  constructor(
    readonly code: CreatePaymentIntentErrorCode | StripeWebhookErrorCode,
    readonly status: number,
    message: string,
    override readonly cause?: unknown,
  ) {
    super(message);
    this.name = "AppError";
  }
}

export type CurrentUserRecord = {
  id: string;
  isActive: boolean;
};

export type TrufflePurchaseRecord = {
  id: string;
  sellerId: string;
  status: string;
  priceTotal: number;
  shippingPriceItaly?: number;
  shippingPriceAbroad?: number;
};

export type ShippingAddressRecord = {
  id: string;
  userId: string;
  fullName: string;
  street: string;
  city: string;
  postalCode: string;
  countryCode: string;
  phone: string;
};

export type PaymentAttemptRecord = {
  id: string;
  buyerId: string;
  sellerId: string;
  truffleId: string;
  shippingAddressId: string;
  status: PaymentAttemptStatus;
  requestFingerprint: string;
  stripePaymentIntentId: string | null;
  totalPrice: number;
  commissionAmount: number;
  sellerAmount: number;
  shippingFullName: string;
  shippingStreet: string;
  shippingCity: string;
  shippingPostalCode: string;
  shippingCountryCode: string;
  shippingPhone: string;
  orderId: string | null;
  expiresAt: string;
};

export type BeginPaymentAttemptArgs = {
  attemptId: string;
  buyerId: string;
  sellerId: string;
  truffleId: string;
  shippingAddressId: string;
  requestFingerprint: string;
  totalPrice: number;
  commissionAmount: number;
  sellerAmount: number;
  shippingFullName: string;
  shippingStreet: string;
  shippingCity: string;
  shippingPostalCode: string;
  shippingCountryCode: string;
  shippingPhone: string;
  expiresAt: string;
};

export type BeginPaymentAttemptResult = {
  attempt: PaymentAttemptRecord | null;
  isNew: boolean;
  conflict: "open_truffle_attempt" | null;
};

export type StripePaymentIntentResult = {
  id: string;
  clientSecret: string;
  status: string;
  metadata?: Record<string, string>;
  paymentMethodTypes?: string[];
  automaticPaymentMethodsEnabled?: boolean;
};

export type StripeWebhookEvent = {
  id: string;
  type: string;
  api_version?: string;
  created?: number;
  data: {
    object: {
      id: string;
      object: string;
      metadata?: Record<string, string>;
      last_payment_error?: {
        code?: string;
        message?: string;
      };
      status?: string;
    };
  };
};

export type RegisterWebhookEventResult = {
  isDuplicate: boolean;
};

export type CreateOrderFromPaymentAttemptResult = {
  orderId: string;
  created: boolean;
  paymentAttemptStatus: PaymentAttemptStatus;
};

export type MarkPaymentAttemptFailedResult = {
  idempotent: boolean;
  status: PaymentAttemptStatus;
};

export type PaymentStore = {
  getCurrentUser(userId: string): Promise<CurrentUserRecord | null>;
  getTruffleForPurchase(
    truffleId: string,
  ): Promise<TrufflePurchaseRecord | null>;
  getShippingAddress(
    userId: string,
    shippingAddressId: string,
  ): Promise<ShippingAddressRecord | null>;
  expireStalePaymentAttempts(truffleId: string, nowIso: string): Promise<void>;
  beginOrReadPaymentAttempt(
    args: BeginPaymentAttemptArgs,
  ): Promise<BeginPaymentAttemptResult>;
  attachStripePaymentIntent(
    attemptId: string,
    stripePaymentIntentId: string,
  ): Promise<void>;
  getPaymentAttemptById(
    attemptId: string,
  ): Promise<PaymentAttemptRecord | null>;
  getPaymentAttemptByStripeIntentId(
    stripePaymentIntentId: string,
  ): Promise<PaymentAttemptRecord | null>;
  markPaymentAttemptFailed(args: {
    attemptId: string;
    failureCode: string | null;
    failureMessage: string | null;
  }): Promise<MarkPaymentAttemptFailedResult>;
  registerWebhookEvent(args: {
    stripeEventId: string;
    eventType: string;
    stripeObjectId: string | null;
    requestId: string;
    metadata: JsonObject;
  }): Promise<RegisterWebhookEventResult>;
  completeWebhookEvent(args: {
    stripeEventId: string;
    processingStatus: Extract<
      StripeWebhookProcessingStatus,
      "processed" | "ignored"
    >;
  }): Promise<void>;
  failWebhookEvent(args: {
    stripeEventId: string;
    errorCode: string;
    errorMessage: string;
  }): Promise<void>;
  createOrderFromPaymentAttempt(args: {
    attemptId: string;
    requestId: string;
  }): Promise<CreateOrderFromPaymentAttemptResult>;
  insertAuditLog(args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string | null;
    metadata: JsonObject;
  }): Promise<void>;
};

export type StripeGateway = {
  createPaymentIntent(args: {
    amountCents: number;
    currency: "eur";
    metadata: Record<string, string>;
    idempotencyKey: string;
    paymentMethodTypes?: string[];
  }): Promise<StripePaymentIntentResult>;
  retrievePaymentIntent(
    paymentIntentId: string,
  ): Promise<StripePaymentIntentResult>;
};

type CreatePaymentIntentRequestPayload = {
  payment_attempt_id?: string;
  truffle_id?: string;
  shipping_address_id?: string;
};

type CreatePaymentIntentHandlerDeps = {
  request: Request;
  requestId: string;
  authenticatedUserId: string | null;
  store: PaymentStore;
  stripeGateway: StripeGateway;
  now?: () => Date;
};

type StripeWebhookHandlerDeps = {
  request: Request;
  requestId: string;
  store: PaymentStore;
  webhookSecret: string;
  now?: () => Date;
};

type FinalizePaymentAttemptHandlerDeps = {
  request: Request;
  requestId: string;
  authenticatedUserId: string | null;
  store: PaymentStore;
  stripeGateway: StripeGateway;
  now?: () => Date;
};

const paymentAttemptSelectClause =
  "id, buyer_id, seller_id, truffle_id, shipping_address_id, order_id, status, request_fingerprint, stripe_payment_intent_id, total_price, commission_amount, seller_amount, shipping_full_name, shipping_street, shipping_city, shipping_postal_code, shipping_country_code, shipping_phone, expires_at";

export async function handleCreatePaymentIntent(
  deps: CreatePaymentIntentHandlerDeps,
): Promise<Response> {
  const request = deps.request;
  const requestId = deps.requestId;
  const now = deps.now ?? (() => new Date());

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      requestId,
    );
  }

  if (deps.authenticatedUserId == null) {
    return errorResponse(
      "unauthorized",
      "Authentication is required.",
      401,
      requestId,
    );
  }

  let payload: CreatePaymentIntentRequestPayload;
  try {
    payload = await request.json();
  } catch {
    return errorResponse(
      "invalid_json_body",
      "Request body must be valid JSON.",
      400,
      requestId,
    );
  }

  const attemptId = normalizeUuid(payload.payment_attempt_id);
  if (attemptId == null) {
    return errorResponse(
      "invalid_payment_attempt_id",
      "A valid payment attempt id is required.",
      400,
      requestId,
    );
  }

  const truffleId = normalizeUuid(payload.truffle_id);
  if (truffleId == null) {
    return errorResponse(
      "invalid_truffle_id",
      "A valid truffle id is required.",
      400,
      requestId,
    );
  }

  const shippingAddressId = normalizeUuid(payload.shipping_address_id);
  if (shippingAddressId == null) {
    return errorResponse(
      "invalid_shipping_address_id",
      "A valid shipping address id is required.",
      400,
      requestId,
    );
  }

  try {
    const currentUser = await deps.store.getCurrentUser(
      deps.authenticatedUserId,
    );
    if (currentUser == null) {
      throw new AppError(
        "user_not_found",
        404,
        "Authenticated user profile was not found.",
      );
    }
    if (!currentUser.isActive) {
      throw new AppError(
        "inactive_account",
        403,
        "The authenticated account is inactive.",
      );
    }

    const shippingAddress = await deps.store.getShippingAddress(
      currentUser.id,
      shippingAddressId,
    );
    if (shippingAddress == null) {
      throw new AppError(
        "shipping_address_not_found",
        404,
        "The requested shipping address was not found.",
      );
    }

    const truffle = await deps.store.getTruffleForPurchase(truffleId);
    if (truffle == null) {
      throw new AppError(
        "truffle_not_found",
        404,
        "The requested truffle was not found.",
      );
    }

    if (truffle.sellerId === currentUser.id) {
      throw new AppError(
        "self_purchase_forbidden",
        403,
        "You cannot buy your own truffle.",
      );
    }

    if (truffle.status !== "active") {
      throw new AppError(
        "truffle_not_available",
        409,
        "The selected truffle is not available for purchase.",
      );
    }

    const currentTimestamp = now();
    const nowIso = currentTimestamp.toISOString();

    await deps.store.expireStalePaymentAttempts(
      truffle.id,
      nowIso,
    );

    const normalizedShippingCountryCode = normalizeCountryCode(
      shippingAddress.countryCode,
    );
    const shippingPrice = resolveShippingPriceForAddress({
      shippingCountryCode: normalizedShippingCountryCode,
      shippingPriceItaly: truffle.shippingPriceItaly,
      shippingPriceAbroad: truffle.shippingPriceAbroad,
    });
    const totalPrice = roundMoney(truffle.priceTotal + shippingPrice);
    const commissionAmount = roundMoney(totalPrice * 0.1);
    const sellerAmount = roundMoney(totalPrice - commissionAmount);
    const requestFingerprint = buildPaymentAttemptFingerprint({
      truffleId,
      shippingAddressId,
    });
    const expiresAt = new Date(
      currentTimestamp.getTime() + paymentAttemptExpiryMinutes * 60 * 1000,
    ).toISOString();

    const attemptRegistration = await deps.store.beginOrReadPaymentAttempt({
      attemptId,
      buyerId: currentUser.id,
      sellerId: truffle.sellerId,
      truffleId: truffle.id,
      shippingAddressId: shippingAddress.id,
      requestFingerprint,
      totalPrice,
      commissionAmount,
      sellerAmount,
      shippingFullName: shippingAddress.fullName,
      shippingStreet: shippingAddress.street,
      shippingCity: shippingAddress.city,
      shippingPostalCode: shippingAddress.postalCode,
      shippingCountryCode: normalizedShippingCountryCode,
      shippingPhone: shippingAddress.phone,
      expiresAt,
    });

    if (attemptRegistration.conflict === "open_truffle_attempt") {
      throw new AppError(
        "payment_attempt_in_progress_for_truffle",
        409,
        "Another payment attempt is already in progress for this truffle.",
      );
    }

    if (attemptRegistration.attempt == null) {
      throw new AppError(
        "payment_unknown_error",
        500,
        "Payment attempt registration did not return a record.",
      );
    }

    const attempt = attemptRegistration.attempt;

    if (attempt.requestFingerprint !== requestFingerprint) {
      throw new AppError(
        "payment_attempt_payload_mismatch",
        409,
        "This payment attempt id was already used with a different payload.",
      );
    }

    if (attempt.status === "succeeded") {
      throw new AppError(
        "payment_attempt_already_succeeded",
        409,
        "This payment attempt has already completed successfully.",
      );
    }

    if (attempt.status === "failed") {
      throw new AppError(
        "payment_attempt_failed",
        409,
        "This payment attempt has already failed.",
      );
    }

    if (attempt.status === "expired") {
      throw new AppError(
        "payment_attempt_expired",
        409,
        "This payment attempt has expired.",
      );
    }

    if (
      attempt.status === "requires_payment_method" &&
      isPaymentAttemptTemporallyExpired(attempt.expiresAt, currentTimestamp)
    ) {
      await deps.store.expireStalePaymentAttempts(truffle.id, nowIso);
      throw new AppError(
        "payment_attempt_expired",
        409,
        "This payment attempt has expired.",
      );
    }

    if (attemptRegistration.isNew) {
      await safeAuditInsert(deps.store, {
        entityType: "payment_attempt",
        entityId: attempt.id,
        action: "payment_attempt_created",
        performedBy: currentUser.id,
        metadata: {
          action: "payment_attempt_created",
          request_id: requestId,
          result: "succeeded",
          truffle_id: truffle.id,
          shipping_address_id: shippingAddress.id,
          shipping_price: shippingPrice,
          total_price: totalPrice,
          currency: "eur",
        },
      });
    }

    let stripePaymentIntent: StripePaymentIntentResult;
    if (attempt.stripePaymentIntentId != null) {
      stripePaymentIntent = await deps.stripeGateway.retrievePaymentIntent(
        attempt.stripePaymentIntentId,
      );
      assertReusableExistingPaymentIntent(stripePaymentIntent);
      if (!isCardOnlyPaymentIntent(stripePaymentIntent)) {
        stripePaymentIntent = await deps.stripeGateway.createPaymentIntent({
          amountCents: toStripeAmountCents(totalPrice),
          currency: "eur",
          metadata: {
            buyer_id: currentUser.id,
            truffle_id: truffle.id,
            payment_attempt_id: attempt.id,
            shipping_address_id: shippingAddress.id,
          },
          idempotencyKey: buildStripePaymentIntentRepairIdempotencyKey(
            attempt.id,
          ),
          paymentMethodTypes: ["card"],
        });

        await deps.store.attachStripePaymentIntent(
          attempt.id,
          stripePaymentIntent.id,
        );

        await safeAuditInsert(deps.store, {
          entityType: "payment_attempt",
          entityId: attempt.id,
          action: "payment_intent_recreated_card_only",
          performedBy: currentUser.id,
          metadata: {
            action: "payment_intent_recreated_card_only",
            request_id: requestId,
            result: "succeeded",
            stripe_payment_intent_id: stripePaymentIntent.id,
            amount_cents: toStripeAmountCents(totalPrice),
            currency: "eur",
          },
        });
      }
    } else {
      stripePaymentIntent = await deps.stripeGateway.createPaymentIntent({
        amountCents: toStripeAmountCents(totalPrice),
        currency: "eur",
        metadata: {
          buyer_id: currentUser.id,
          truffle_id: truffle.id,
          payment_attempt_id: attempt.id,
          shipping_address_id: shippingAddress.id,
        },
        idempotencyKey: buildStripePaymentIntentIdempotencyKey(attempt.id),
        paymentMethodTypes: ["card"],
      });

      await deps.store.attachStripePaymentIntent(
        attempt.id,
        stripePaymentIntent.id,
      );

      await safeAuditInsert(deps.store, {
        entityType: "payment_attempt",
        entityId: attempt.id,
        action: "payment_intent_created",
        performedBy: currentUser.id,
        metadata: {
          action: "payment_intent_created",
          request_id: requestId,
          result: "succeeded",
          stripe_payment_intent_id: stripePaymentIntent.id,
          amount_cents: toStripeAmountCents(totalPrice),
          currency: "eur",
        },
      });
    }

    return jsonResponse({
      payment_attempt_id: attempt.id,
      stripe_payment_intent_id: stripePaymentIntent.id,
      client_secret: stripePaymentIntent.clientSecret,
      request_id: requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeCreatePaymentIntentError(error);
    console.error("create_payment_intent failed", {
      request_id: requestId,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
      cause_code: readErrorCode(normalizedError.cause),
      cause_message: readErrorMessage(normalizedError.cause),
    });
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
    );
  }
}

export async function handleFinalizePaymentAttempt(
  deps: FinalizePaymentAttemptHandlerDeps,
): Promise<Response> {
  const request = deps.request;
  const requestId = deps.requestId;
  const now = deps.now ?? (() => new Date());

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      requestId,
    );
  }

  if (deps.authenticatedUserId == null) {
    return errorResponse(
      "unauthorized",
      "Authentication is required.",
      401,
      requestId,
    );
  }

  let payload: { payment_attempt_id?: string; stripe_payment_intent_id?: string };
  try {
    payload = await request.json();
  } catch {
    return errorResponse(
      "invalid_json_body",
      "Request body must be valid JSON.",
      400,
      requestId,
    );
  }

  const attemptId = normalizeUuid(payload.payment_attempt_id);
  if (attemptId == null) {
    return errorResponse(
      "invalid_payment_attempt_id",
      "A valid payment attempt id is required.",
      400,
      requestId,
    );
  }

  const payloadStripePaymentIntentId = normalizeNonEmptyString(
    payload.stripe_payment_intent_id,
  );

  try {
    const currentUser = await deps.store.getCurrentUser(
      deps.authenticatedUserId,
    );
    if (currentUser == null) {
      throw new AppError(
        "user_not_found",
        404,
        "Authenticated user profile was not found.",
      );
    }
    if (!currentUser.isActive) {
      throw new AppError(
        "inactive_account",
        403,
        "The authenticated account is inactive.",
      );
    }

    const attempt = await deps.store.getPaymentAttemptById(attemptId);
    if (attempt == null) {
      throw new AppError(
        "payment_attempt_not_found",
        404,
        "The requested payment attempt was not found.",
      );
    }

    if (attempt.buyerId !== currentUser.id) {
      throw new AppError(
        "forbidden",
        403,
        "You are not allowed to finalize this payment attempt.",
      );
    }

    if (attempt.stripePaymentIntentId == null) {
      throw new AppError(
        "payment_unknown_error",
        409,
        "The payment attempt does not have a Stripe PaymentIntent yet.",
      );
    }

    if (
      payloadStripePaymentIntentId != null &&
      payloadStripePaymentIntentId !== attempt.stripePaymentIntentId
    ) {
      throw new AppError(
        "payment_attempt_payload_mismatch",
        409,
        "The provided PaymentIntent does not match the stored payment attempt.",
      );
    }

    const stripePaymentIntent = await deps.stripeGateway.retrievePaymentIntent(
      attempt.stripePaymentIntentId,
    );
    if (stripePaymentIntent.id !== attempt.stripePaymentIntentId) {
      throw new AppError(
        "payment_attempt_payload_mismatch",
        409,
        "The Stripe PaymentIntent id does not match the stored payment attempt.",
      );
    }

    const metadataPaymentAttemptId = normalizeUuid(
      stripePaymentIntent.metadata?.payment_attempt_id,
    );
    if (metadataPaymentAttemptId !== attempt.id) {
      throw new AppError(
        "payment_attempt_payload_mismatch",
        409,
        "The Stripe PaymentIntent metadata does not match the stored payment attempt.",
      );
    }

    if (stripePaymentIntent.status !== "succeeded") {
      return jsonResponse({
        payment_attempt_id: attempt.id,
        stripe_payment_intent_id: stripePaymentIntent.id,
        payment_intent_status: stripePaymentIntent.status,
        finalized: false,
        request_id: requestId,
      }, 202);
    }

    const createdOrder = await deps.store.createOrderFromPaymentAttempt({
      attemptId: attempt.id,
      requestId,
    });

    await safeAuditInsert(deps.store, {
      entityType: "payment_attempt",
      entityId: attempt.id,
      action: "payment_attempt_finalized",
      performedBy: currentUser.id,
      metadata: {
        action: "payment_attempt_finalized",
        request_id: requestId,
        result: "succeeded",
        stripe_payment_intent_id: stripePaymentIntent.id,
        order_id: createdOrder.orderId,
        created: createdOrder.created,
      },
    });

    return jsonResponse({
      payment_attempt_id: attempt.id,
      stripe_payment_intent_id: stripePaymentIntent.id,
      order_id: createdOrder.orderId,
      created: createdOrder.created,
      payment_attempt_status: createdOrder.paymentAttemptStatus,
      finalized: true,
      request_id: requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeCreatePaymentIntentError(error);
    console.error("finalize_payment_attempt failed", {
      request_id: requestId,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
      cause_code: readErrorCode(normalizedError.cause),
      cause_message: readErrorMessage(normalizedError.cause),
    });
    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
    );
  }
}

export async function handleStripeWebhook(
  deps: StripeWebhookHandlerDeps,
): Promise<Response> {
  const request = deps.request;
  const requestId = deps.requestId;
  const now = deps.now ?? (() => new Date());

  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return errorResponse(
      "method_not_allowed",
      "Only POST requests are supported.",
      405,
      requestId,
    );
  }

  const signatureHeader = request.headers.get("stripe-signature");
  if (!signatureHeader) {
    return errorResponse(
      "missing_webhook_signature",
      "Stripe-Signature header is required.",
      400,
      requestId,
    );
  }

  const rawBody = await request.text();
  const signatureVerification = await verifyStripeWebhookSignature({
    payload: rawBody,
    signatureHeader,
    secret: deps.webhookSecret,
    now,
    toleranceSeconds: webhookSignatureToleranceSeconds,
  });

  if (!signatureVerification.ok) {
    return errorResponse(
      "invalid_webhook_signature",
      "Webhook signature verification failed.",
      400,
      requestId,
    );
  }

  let event: StripeWebhookEvent;
  try {
    event = JSON.parse(rawBody) as StripeWebhookEvent;
  } catch {
    return errorResponse(
      "invalid_webhook_payload",
      "Webhook payload must be valid JSON.",
      400,
      requestId,
    );
  }

  const supportedEvent = normalizeSupportedStripeWebhookEvent(event);
  if (supportedEvent == null) {
    return jsonResponse({
      ignored: true,
      request_id: requestId,
    }, 200);
  }

  const stripePaymentIntentId = normalizeNonEmptyString(
    supportedEvent.data.object.id,
  );
  const paymentAttemptId = normalizeUuid(
    supportedEvent.data.object.metadata?.payment_attempt_id,
  );

  if (stripePaymentIntentId == null || paymentAttemptId == null) {
    return errorResponse(
      "invalid_webhook_payload",
      "Webhook payload is missing required payment metadata.",
      400,
      requestId,
    );
  }

  try {
    const webhookRegistration = await deps.store.registerWebhookEvent({
      stripeEventId: supportedEvent.id,
      eventType: supportedEvent.type,
      stripeObjectId: stripePaymentIntentId,
      requestId,
      metadata: {
        payment_attempt_id: paymentAttemptId,
      },
    });

    if (webhookRegistration.isDuplicate) {
      return jsonResponse({
        received: true,
        duplicate: true,
        request_id: requestId,
      }, 200);
    }

    const attempt = await deps.store.getPaymentAttemptById(paymentAttemptId);
    if (attempt == null) {
      throw new AppError(
        "payment_attempt_not_found",
        404,
        "The payment attempt referenced by the webhook was not found.",
      );
    }

    if (attempt.stripePaymentIntentId !== stripePaymentIntentId) {
      throw new AppError(
        "payment_attempt_mismatch",
        409,
        "The webhook PaymentIntent does not match the stored payment attempt.",
      );
    }

    await safeAuditInsert(deps.store, {
      entityType: "payment_attempt",
      entityId: attempt.id,
      action: "webhook_received",
      performedBy: null,
      metadata: {
        action: "webhook_received",
        request_id: requestId,
        result: "received",
        stripe_event_id: supportedEvent.id,
        stripe_payment_intent_id: stripePaymentIntentId,
        event_type: supportedEvent.type,
      },
    });

    if (supportedEvent.type === "payment_intent.succeeded") {
      const orderResult = await deps.store.createOrderFromPaymentAttempt({
        attemptId: attempt.id,
        requestId,
      });

      await safeAuditInsert(deps.store, {
        entityType: "payment_attempt",
        entityId: attempt.id,
        action: "payment_intent_succeeded",
        performedBy: null,
        metadata: {
          action: "payment_intent_succeeded",
          request_id: requestId,
          result: "succeeded",
          stripe_event_id: supportedEvent.id,
          stripe_payment_intent_id: stripePaymentIntentId,
          order_id: orderResult.orderId,
          created_order: orderResult.created,
        },
      });

      if (orderResult.created) {
        await safeAuditInsert(deps.store, {
          entityType: "order",
          entityId: orderResult.orderId,
          action: "order_created_from_payment",
          performedBy: null,
          metadata: {
            action: "order_created_from_payment",
            request_id: requestId,
            result: "succeeded",
            payment_attempt_id: attempt.id,
            stripe_event_id: supportedEvent.id,
            stripe_payment_intent_id: stripePaymentIntentId,
          },
        });
      }

      await deps.store.completeWebhookEvent({
        stripeEventId: supportedEvent.id,
        processingStatus: "processed",
      });

      return jsonResponse({
        received: true,
        processed: true,
        request_id: requestId,
      }, 200);
    }

    const markFailedResult = await deps.store.markPaymentAttemptFailed({
      attemptId: attempt.id,
      failureCode: supportedEvent.data.object.last_payment_error?.code ?? null,
      failureMessage: supportedEvent.data.object.last_payment_error?.message ??
        null,
    });

    await safeAuditInsert(deps.store, {
      entityType: "payment_attempt",
      entityId: attempt.id,
      action: "payment_intent_failed",
      performedBy: null,
      metadata: {
        action: "payment_intent_failed",
        request_id: requestId,
        result: markFailedResult.idempotent ? "idempotent_replay" : "succeeded",
        stripe_event_id: supportedEvent.id,
        stripe_payment_intent_id: stripePaymentIntentId,
        failure_code: supportedEvent.data.object.last_payment_error?.code ??
          null,
      },
    });

    await deps.store.completeWebhookEvent({
      stripeEventId: supportedEvent.id,
      processingStatus: "processed",
    });

    return jsonResponse({
      received: true,
      processed: true,
      request_id: requestId,
    }, 200);
  } catch (error) {
    const normalizedError = normalizeStripeWebhookError(error);
    console.error("stripe_webhook failed", {
      request_id: requestId,
      code: normalizedError.code,
      status: normalizedError.status,
      message: normalizedError.message,
      cause_code: readErrorCode(normalizedError.cause),
      cause_message: readErrorMessage(normalizedError.cause),
    });

    await safeFailWebhookEvent(
      deps.store,
      supportedEvent.id,
      normalizedError.code,
      normalizedError.message,
    );

    return errorResponse(
      normalizedError.code,
      normalizedError.message,
      normalizedError.status,
      requestId,
    );
  }
}

export async function verifyStripeWebhookSignature(args: {
  payload: string;
  signatureHeader: string;
  secret: string;
  now?: () => Date;
  toleranceSeconds?: number;
}): Promise<{ ok: boolean }> {
  const now = args.now ?? (() => new Date());
  const toleranceSeconds = args.toleranceSeconds ??
    webhookSignatureToleranceSeconds;
  const parsedSignature = parseStripeSignatureHeader(args.signatureHeader);
  if (parsedSignature == null) {
    return { ok: false };
  }

  const currentTimestamp = Math.floor(now().getTime() / 1000);
  if (
    Math.abs(currentTimestamp - parsedSignature.timestamp) > toleranceSeconds
  ) {
    return { ok: false };
  }

  const signedPayload = `${parsedSignature.timestamp}.${args.payload}`;
  const expectedSignature = await computeStripeWebhookSignature(
    args.secret,
    signedPayload,
  );

  return {
    ok: parsedSignature.v1Signatures.some((signature) =>
      timingSafeEqual(signature, expectedSignature)
    ),
  };
}

export function createStripeGateway(
  fetchImpl: typeof fetch,
  secretKey: string,
): StripeGateway {
  return {
    async createPaymentIntent(args) {
      const paymentMethodTypes = args.paymentMethodTypes?.length
        ? args.paymentMethodTypes
        : ["card"];
      const paymentMethodFormEntries = Object.fromEntries(
        paymentMethodTypes.map((type, index) => [
          `payment_method_types[${index}]`,
          type,
        ]),
      );
      const response = await stripeApiRequest(fetchImpl, secretKey, {
        path: "/payment_intents",
        method: "POST",
        idempotencyKey: args.idempotencyKey,
        form: {
          amount: `${args.amountCents}`,
          currency: args.currency,
          ...paymentMethodFormEntries,
          ...flattenStripeMetadata(args.metadata),
        },
      });

      return {
        id: readRequiredStripeString(response, "id"),
        clientSecret: readRequiredStripeString(response, "client_secret"),
        status: readRequiredStripeString(response, "status"),
      };
    },

    async retrievePaymentIntent(paymentIntentId) {
      const response = await stripeApiRequest(fetchImpl, secretKey, {
        path: `/payment_intents/${encodeURIComponent(paymentIntentId)}`,
        method: "GET",
      });

      return {
        id: readRequiredStripeString(response, "id"),
        clientSecret: readRequiredStripeString(response, "client_secret"),
        status: readRequiredStripeString(response, "status"),
        metadata: readMetadataMap(response),
        paymentMethodTypes: readStringArray(response.payment_method_types),
        automaticPaymentMethodsEnabled: readAutomaticPaymentMethodsEnabled(
          response.automatic_payment_methods,
        ),
      };
    },
  };
}

export function createSupabasePaymentStore(adminClient: any): PaymentStore {
  return {
    async getCurrentUser(userId) {
      const { data, error } = await adminClient
        .from("users")
        .select("id, is_active")
        .eq("id", userId)
        .single();

      if (error || !data) {
        return null;
      }

      return {
        id: data.id as string,
        isActive: data.is_active as boolean,
      };
    },

    async getTruffleForPurchase(truffleId) {
      const { data, error } = await adminClient
        .from("truffles")
        .select(
          "id, seller_id, status, price_total, shipping_price_italy, shipping_price_abroad",
        )
        .eq("id", truffleId)
        .single();

      if (error || !data) {
        return null;
      }

      return {
        id: data.id as string,
        sellerId: data.seller_id as string,
        status: data.status as string,
        priceTotal: toNumber(data.price_total),
        shippingPriceItaly: toNullableNumber(data.shipping_price_italy),
        shippingPriceAbroad: toNullableNumber(data.shipping_price_abroad),
      };
    },

    async getShippingAddress(userId, shippingAddressId) {
      const { data, error } = await adminClient
        .from("shipping_addresses")
        .select(
          "id, user_id, full_name, street, city, postal_code, country_code, phone",
        )
        .eq("id", shippingAddressId)
        .eq("user_id", userId)
        .single();

      if (error || !data) {
        return null;
      }

      return {
        id: data.id as string,
        userId: data.user_id as string,
        fullName: data.full_name as string,
        street: data.street as string,
        city: data.city as string,
        postalCode: data.postal_code as string,
        countryCode: data.country_code as string,
        phone: data.phone as string,
      };
    },

    async expireStalePaymentAttempts(truffleId, nowIso) {
      const { error } = await adminClient
        .from("payment_attempts")
        .update({
          status: "expired",
          processed_at: nowIso,
          failure_code: "payment_attempt_expired",
          failure_message: "Payment attempt expired before confirmation.",
        })
        .eq("truffle_id", truffleId)
        .eq("status", "requires_payment_method")
        .lt("expires_at", nowIso);

      if (error) {
        throw error;
      }
    },

    async beginOrReadPaymentAttempt(args) {
      const insertResult = await adminClient
        .from("payment_attempts")
        .insert({
          id: args.attemptId,
          buyer_id: args.buyerId,
          seller_id: args.sellerId,
          truffle_id: args.truffleId,
          shipping_address_id: args.shippingAddressId,
          request_fingerprint: args.requestFingerprint,
          total_price: args.totalPrice,
          commission_amount: args.commissionAmount,
          seller_amount: args.sellerAmount,
          shipping_full_name: args.shippingFullName,
          shipping_street: args.shippingStreet,
          shipping_city: args.shippingCity,
          shipping_postal_code: args.shippingPostalCode,
          shipping_country_code: args.shippingCountryCode,
          shipping_phone: args.shippingPhone,
          expires_at: args.expiresAt,
        })
        .select(paymentAttemptSelectClause)
        .single();

      if (!insertResult.error && insertResult.data) {
        return {
          attempt: mapPaymentAttemptRow(insertResult.data),
          isNew: true,
          conflict: null,
        };
      }

      if (insertResult.error?.code !== "23505") {
        throw insertResult.error;
      }

      const existingAttempt = await this.getPaymentAttemptById(args.attemptId);
      if (existingAttempt != null) {
        return {
          attempt: existingAttempt,
          isNew: false,
          conflict: null,
        };
      }

      const openAttemptResult = await adminClient
        .from("payment_attempts")
        .select(paymentAttemptSelectClause)
        .eq("truffle_id", args.truffleId)
        .eq("status", "requires_payment_method")
        .maybeSingle();

      if (openAttemptResult.error) {
        throw openAttemptResult.error;
      }

      if (openAttemptResult.data) {
        const openAttempt = mapPaymentAttemptRow(openAttemptResult.data);
        if (
          openAttempt.buyerId === args.buyerId &&
          openAttempt.shippingAddressId === args.shippingAddressId &&
          openAttempt.requestFingerprint === args.requestFingerprint
        ) {
          return {
            attempt: openAttempt,
            isNew: false,
            conflict: null,
          };
        }
      }

      return {
        attempt: null,
        isNew: false,
        conflict: "open_truffle_attempt",
      };
    },

    async attachStripePaymentIntent(attemptId, stripePaymentIntentId) {
      const { error } = await adminClient
        .from("payment_attempts")
        .update({
          stripe_payment_intent_id: stripePaymentIntentId,
        })
        .eq("id", attemptId);

      if (error) {
        throw error;
      }
    },

    async getPaymentAttemptById(attemptId) {
      const { data, error } = await adminClient
        .from("payment_attempts")
        .select(paymentAttemptSelectClause)
        .eq("id", attemptId)
        .maybeSingle();

      if (error || !data) {
        return null;
      }

      return mapPaymentAttemptRow(data);
    },

    async getPaymentAttemptByStripeIntentId(stripePaymentIntentId) {
      const { data, error } = await adminClient
        .from("payment_attempts")
        .select(paymentAttemptSelectClause)
        .eq("stripe_payment_intent_id", stripePaymentIntentId)
        .maybeSingle();

      if (error || !data) {
        return null;
      }

      return mapPaymentAttemptRow(data);
    },

    async markPaymentAttemptFailed(args) {
      const attempt = await this.getPaymentAttemptById(args.attemptId);
      if (attempt == null) {
        throw new AppError(
          "payment_attempt_not_found",
          404,
          "The payment attempt was not found.",
        );
      }

      if (attempt.status === "succeeded" || attempt.status === "failed") {
        return {
          idempotent: true,
          status: attempt.status,
        };
      }

      const { error } = await adminClient
        .from("payment_attempts")
        .update({
          status: "failed",
          processed_at: new Date().toISOString(),
          failure_code: args.failureCode,
          failure_message: truncateForStorage(args.failureMessage),
        })
        .eq("id", args.attemptId);

      if (error) {
        throw error;
      }

      return {
        idempotent: false,
        status: "failed" as PaymentAttemptStatus,
      };
    },

    async registerWebhookEvent(args) {
      const { error } = await adminClient
        .from("stripe_webhook_events")
        .insert({
          stripe_event_id: args.stripeEventId,
          event_type: args.eventType,
          stripe_object_id: args.stripeObjectId,
          request_id: args.requestId,
          metadata: args.metadata,
        });

      if (!error) {
        return { isDuplicate: false };
      }

      if (error.code === "23505") {
        const { data: existingEvent, error: existingEventError } =
          await adminClient
            .from("stripe_webhook_events")
            .select("processing_status")
            .eq("stripe_event_id", args.stripeEventId)
            .maybeSingle();

        if (existingEventError) {
          throw existingEventError;
        }

        const processingStatus = existingEvent?.processing_status as
          | StripeWebhookProcessingStatus
          | undefined;

        if (processingStatus === "failed") {
          const { error: retryUpdateError } = await adminClient
            .from("stripe_webhook_events")
            .update({
              processing_status: "processing",
              request_id: args.requestId,
              error_code: null,
              error_message: null,
              processed_at: null,
              metadata: args.metadata,
            })
            .eq("stripe_event_id", args.stripeEventId)
            .eq("processing_status", "failed");

          if (retryUpdateError) {
            throw retryUpdateError;
          }

          return { isDuplicate: false };
        }

        return { isDuplicate: true };
      }

      throw error;
    },

    async completeWebhookEvent(args) {
      const { error } = await adminClient
        .from("stripe_webhook_events")
        .update({
          processing_status: args.processingStatus,
          processed_at: new Date().toISOString(),
          error_code: null,
          error_message: null,
        })
        .eq("stripe_event_id", args.stripeEventId);

      if (error) {
        throw error;
      }
    },

    async failWebhookEvent(args) {
      const { error } = await adminClient
        .from("stripe_webhook_events")
        .update({
          processing_status: "failed",
          processed_at: new Date().toISOString(),
          error_code: args.errorCode,
          error_message: truncateForStorage(args.errorMessage),
        })
        .eq("stripe_event_id", args.stripeEventId);

      if (error) {
        throw error;
      }
    },

    async createOrderFromPaymentAttempt(args) {
      const { data, error } = await adminClient
        .rpc("create_order_from_payment_attempt", {
          p_payment_attempt_id: args.attemptId,
          p_request_id: args.requestId,
        })
        .single();

      if (error || !data) {
        throw error ??
          new Error("create_order_from_payment_attempt returned no data");
      }

      return {
        orderId: data.order_id as string,
        created: data.created as boolean,
        paymentAttemptStatus: data
          .payment_attempt_status as PaymentAttemptStatus,
      };
    },

    async insertAuditLog(args) {
      const { error } = await adminClient
        .from("audit_logs")
        .insert({
          entity_type: args.entityType,
          entity_id: args.entityId,
          action: args.action,
          performed_by: args.performedBy,
          metadata: args.metadata,
        });

      if (error) {
        throw error;
      }
    },
  };
}

export function getRequestId(request: Request): string {
  const headerValue = request.headers.get("x-request-id") ??
    request.headers.get("x-correlation-id");
  const normalized = normalizeNonEmptyString(headerValue);
  return normalized ?? crypto.randomUUID();
}

export function validateRuntimeSupabaseUrl(supabaseUrl: string): string | null {
  let parsedUrl: URL;
  try {
    parsedUrl = new URL(supabaseUrl);
  } catch {
    return "SUPABASE_URL is not a valid URL for the Stripe payment runtime.";
  }

  if (parsedUrl.hostname === "10.0.2.2") {
    return "SUPABASE_URL points to the Android emulator loopback. Edge Functions must not be started with the Flutter app env file.";
  }

  return null;
}

function buildPaymentAttemptFingerprint(args: {
  truffleId: string;
  shippingAddressId: string;
}): string {
  return JSON.stringify({
    truffle_id: args.truffleId,
    shipping_address_id: args.shippingAddressId,
  });
}

function buildStripePaymentIntentIdempotencyKey(attemptId: string): string {
  return `truffly_payment_intent_${attemptId}`;
}

function buildStripePaymentIntentRepairIdempotencyKey(
  attemptId: string,
): string {
  return `truffly_payment_intent_${attemptId}_card_only_repair`;
}

function assertReusableExistingPaymentIntent(
  paymentIntent: StripePaymentIntentResult,
): void {
  switch (paymentIntent.status) {
    case "requires_payment_method":
    case "requires_confirmation":
    case "requires_action":
      return;
    case "succeeded":
      throw new AppError(
        "payment_attempt_already_succeeded",
        409,
        "The existing payment intent has already succeeded and cannot be reused.",
      );
    case "canceled":
      throw new AppError(
        "payment_attempt_failed",
        409,
        "The existing payment intent was canceled and cannot be reused.",
      );
    default:
      throw new AppError(
        "payment_unknown_error",
        409,
        `The existing payment intent is in non-reusable status ${paymentIntent.status}.`,
      );
  }
}

function isCardOnlyPaymentIntent(
  paymentIntent: StripePaymentIntentResult,
): boolean {
  const paymentMethodTypes = paymentIntent.paymentMethodTypes
    ?.map((type) => type.trim().toLowerCase())
    .filter((type) => type.length > 0);
  if (paymentMethodTypes != null && paymentMethodTypes.length > 0) {
    return paymentMethodTypes.length === 1 && paymentMethodTypes[0] === "card";
  }

  if (paymentIntent.automaticPaymentMethodsEnabled === true) {
    return false;
  }

  return true;
}

function normalizeSupportedStripeWebhookEvent(
  event: StripeWebhookEvent,
): StripeWebhookEvent | null {
  if (event?.type === "payment_intent.succeeded") {
    return event;
  }

  if (event?.type === "payment_intent.payment_failed") {
    return event;
  }

  return null;
}

async function safeAuditInsert(
  store: PaymentStore,
  args: {
    entityType: string;
    entityId: string;
    action: string;
    performedBy: string | null;
    metadata: JsonObject;
  },
): Promise<void> {
  try {
    await store.insertAuditLog(args);
  } catch (error) {
    console.error("stripe payment audit insert failed", {
      entity_type: args.entityType,
      entity_id: args.entityId,
      action: args.action,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

async function safeFailWebhookEvent(
  store: PaymentStore,
  stripeEventId: string,
  errorCode: string,
  errorMessage: string,
): Promise<void> {
  try {
    await store.failWebhookEvent({
      stripeEventId,
      errorCode,
      errorMessage,
    });
  } catch (error) {
    console.error("stripe_webhook event state update failed", {
      stripe_event_id: stripeEventId,
      code: readErrorCode(error),
      message: readErrorMessage(error),
    });
  }
}

async function stripeApiRequest(
  fetchImpl: typeof fetch,
  secretKey: string,
  args: {
    path: string;
    method: "GET" | "POST";
    idempotencyKey?: string;
    form?: Record<string, string>;
  },
): Promise<Record<string, unknown>> {
  const headers = new Headers({
    "Authorization": `Bearer ${secretKey}`,
  });

  let body: string | undefined;
  if (args.form != null) {
    headers.set("Content-Type", "application/x-www-form-urlencoded");
    body = new URLSearchParams(args.form).toString();
  }

  if (args.idempotencyKey != null) {
    headers.set("Idempotency-Key", args.idempotencyKey);
  }

  const response = await fetchImpl(`${stripeApiBaseUrl}${args.path}`, {
    method: args.method,
    headers,
    body,
  });

  const parsedBody = await response.json().catch(() => null);
  if (!response.ok || !parsedBody || typeof parsedBody !== "object") {
    throw new AppError(
      "stripe_api_error",
      502,
      "Stripe API request failed.",
      parsedBody,
    );
  }

  if ("error" in parsedBody) {
    throw new AppError(
      "stripe_api_error",
      502,
      "Stripe API returned an error response.",
      parsedBody,
    );
  }

  return parsedBody as Record<string, unknown>;
}

function flattenStripeMetadata(
  metadata: Record<string, string>,
): Record<string, string> {
  const flattened: Record<string, string> = {};
  for (const [key, value] of Object.entries(metadata)) {
    flattened[`metadata[${key}]`] = value;
  }
  return flattened;
}

function readRequiredStripeString(
  response: Record<string, unknown>,
  field: string,
): string {
  const value = response[field];
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new AppError(
      "stripe_api_error",
      502,
      `Stripe response is missing ${field}.`,
      response,
    );
  }
  return value;
}

function readMetadataMap(
  response: Record<string, unknown>,
): Record<string, string> | undefined {
  const metadata = response.metadata;
  if (!isRecord(metadata)) {
    return undefined;
  }

  const result: Record<string, string> = {};
  for (const [key, value] of Object.entries(metadata)) {
    if (typeof value === "string") {
      result[key] = value;
    }
  }

  return result;
}

function readStringArray(value: unknown): string[] | undefined {
  if (!Array.isArray(value)) {
    return undefined;
  }

  const strings = value.filter((item): item is string => typeof item === "string");
  return strings.length > 0 ? strings : undefined;
}

function readAutomaticPaymentMethodsEnabled(
  value: unknown,
): boolean | undefined {
  if (!isRecord(value)) {
    return undefined;
  }

  const enabled = value.enabled;
  return typeof enabled === "boolean" ? enabled : undefined;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function parseStripeSignatureHeader(signatureHeader: string): {
  timestamp: number;
  v1Signatures: string[];
} | null {
  const segments = signatureHeader
    .split(",")
    .map((segment) => segment.trim())
    .filter((segment) => segment.length > 0);

  let timestamp: number | null = null;
  const v1Signatures: string[] = [];

  for (const segment of segments) {
    const [key, value] = segment.split("=", 2);
    if (key === "t") {
      const parsed = Number.parseInt(value ?? "", 10);
      if (!Number.isFinite(parsed)) {
        return null;
      }
      timestamp = parsed;
    } else if (key === "v1" && value) {
      v1Signatures.push(value);
    }
  }

  if (timestamp == null || v1Signatures.length === 0) {
    return null;
  }

  return {
    timestamp,
    v1Signatures,
  };
}

async function computeStripeWebhookSignature(
  secret: string,
  payload: string,
): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const signatureBuffer = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(payload),
  );

  return bufferToHex(signatureBuffer);
}

function bufferToHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

function timingSafeEqual(left: string, right: string): boolean {
  if (left.length !== right.length) {
    return false;
  }

  let mismatch = 0;
  for (let index = 0; index < left.length; index++) {
    mismatch |= left.charCodeAt(index) ^ right.charCodeAt(index);
  }

  return mismatch === 0;
}

function normalizeCreatePaymentIntentError(error: unknown): AppError {
  if (error instanceof AppError) {
    return error;
  }

  return new AppError(
    "payment_unknown_error",
    500,
    "An unexpected error occurred while creating the payment intent.",
    error,
  );
}

function normalizeStripeWebhookError(error: unknown): AppError {
  if (error instanceof AppError) {
    return error;
  }

  const message = readErrorMessage(error);
  if (message === "payment_attempt_truffle_unavailable") {
    return new AppError(
      "payment_attempt_order_creation_failed",
      409,
      "The payment attempt could not create an order because the truffle is no longer available.",
      error,
    );
  }

  return new AppError(
    "webhook_unknown_error",
    500,
    "An unexpected error occurred while processing the Stripe webhook.",
    error,
  );
}

function jsonResponse(body: Record<string, unknown>, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

function errorResponse(
  error: CreatePaymentIntentErrorCode | StripeWebhookErrorCode,
  message: string,
  status: number,
  requestId: string,
): Response {
  return jsonResponse(
    {
      error,
      message,
      request_id: requestId,
    },
    status,
  );
}

function normalizeUuid(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
      .test(trimmed)
    ? trimmed
    : null;
}

function normalizeNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

function normalizeCountryCode(value: string): string {
  return value.trim().toUpperCase();
}

function resolveShippingPriceForAddress(args: {
  shippingCountryCode: string;
  shippingPriceItaly?: number;
  shippingPriceAbroad?: number;
}): number {
  const shippingPrice = args.shippingCountryCode === "IT"
    ? args.shippingPriceItaly ?? 0
    : args.shippingPriceAbroad ?? 0;
  return roundMoney(shippingPrice);
}

function isPaymentAttemptTemporallyExpired(
  expiresAtIso: string,
  currentTimestamp: Date,
): boolean {
  const expiresAtMs = Date.parse(expiresAtIso);
  if (Number.isNaN(expiresAtMs)) {
    return false;
  }

  return expiresAtMs <= currentTimestamp.getTime();
}

function toStripeAmountCents(amount: number): number {
  return Math.round(amount * 100);
}

function roundMoney(value: number): number {
  return Math.round(value * 100) / 100;
}

function readErrorCode(error: unknown): string {
  if (typeof error === "object" && error !== null && "code" in error) {
    const value = Reflect.get(error, "code");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function readErrorMessage(error: unknown): string {
  if (typeof error === "object" && error !== null && "message" in error) {
    const value = Reflect.get(error, "message");
    if (typeof value === "string") {
      return value;
    }
  }

  return "";
}

function truncateForStorage(value: string | null): string | null {
  if (value == null) {
    return null;
  }

  return value.length <= 500 ? value : `${value.slice(0, 497)}...`;
}

function toNumber(value: unknown): number {
  if (typeof value === "number") {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    if (Number.isFinite(parsed)) {
      return parsed;
    }
  }

  throw new Error("Expected a numeric value.");
}

function toNullableNumber(value: unknown): number | undefined {
  if (value == null) {
    return undefined;
  }

  return toNumber(value);
}

function mapPaymentAttemptRow(
  row: Record<string, unknown>,
): PaymentAttemptRecord {
  return {
    id: row.id as string,
    buyerId: row.buyer_id as string,
    sellerId: row.seller_id as string,
    truffleId: row.truffle_id as string,
    shippingAddressId: row.shipping_address_id as string,
    orderId: (row.order_id as string | null) ?? null,
    status: row.status as PaymentAttemptStatus,
    requestFingerprint: row.request_fingerprint as string,
    stripePaymentIntentId: (row.stripe_payment_intent_id as string | null) ??
      null,
    totalPrice: toNumber(row.total_price),
    commissionAmount: toNumber(row.commission_amount),
    sellerAmount: toNumber(row.seller_amount),
    shippingFullName: row.shipping_full_name as string,
    shippingStreet: row.shipping_street as string,
    shippingCity: row.shipping_city as string,
    shippingPostalCode: row.shipping_postal_code as string,
    shippingCountryCode: normalizeCountryCode(
      row.shipping_country_code as string,
    ),
    shippingPhone: row.shipping_phone as string,
    expiresAt: row.expires_at as string,
  };
}
