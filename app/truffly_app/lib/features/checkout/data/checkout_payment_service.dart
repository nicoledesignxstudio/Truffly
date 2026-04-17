import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/env.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/truffle/domain/truffle_detail.dart';

enum CheckoutFailure {
  network,
  unauthenticated,
  forbidden,
  notFound,
  validation,
  paymentCanceled,
  paymentFailed,
  unknown,
}

enum CheckoutPaymentStatus { success, canceled, failure }

class CheckoutPaymentSheetResult {
  const CheckoutPaymentSheetResult._({
    required this.status,
    this.paymentAttemptId,
    this.stripePaymentIntentId,
    this.failure,
  });

  const CheckoutPaymentSheetResult.success({
    required String paymentAttemptId,
    required String stripePaymentIntentId,
  }) : this._(
         status: CheckoutPaymentStatus.success,
         paymentAttemptId: paymentAttemptId,
         stripePaymentIntentId: stripePaymentIntentId,
       );

  const CheckoutPaymentSheetResult.canceled()
    : this._(
        status: CheckoutPaymentStatus.canceled,
        failure: CheckoutFailure.paymentCanceled,
      );

  const CheckoutPaymentSheetResult.failure(CheckoutFailure failure)
    : this._(
        status: CheckoutPaymentStatus.failure,
        failure: failure,
      );

  final CheckoutPaymentStatus status;
  final String? paymentAttemptId;
  final String? stripePaymentIntentId;
  final CheckoutFailure? failure;

  bool get isSuccess => status == CheckoutPaymentStatus.success;
}

class CheckoutPaymentService {
  CheckoutPaymentService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  static const _timeout = Duration(seconds: 18);
  static const _merchantDisplayName = 'Truffly';
  static const _returnUrl = 'truffly://stripe-redirect';

  Future<CheckoutPaymentSheetResult> presentPaymentSheet({
    required TruffleDetail truffle,
    required ShippingAddress shippingAddress,
  }) async {
    final paymentAttemptId = _generatePaymentAttemptId();
    final intentResult = await _createPaymentIntent(
      paymentAttemptId: paymentAttemptId,
      truffleId: truffle.id,
      shippingAddressId: shippingAddress.id,
    );

    if (intentResult.failure != null) {
      return CheckoutPaymentSheetResult.failure(intentResult.failure!);
    }

    final session = intentResult.session;
    if (session == null) {
      return const CheckoutPaymentSheetResult.failure(CheckoutFailure.unknown);
    }

    try {
      await Stripe.instance.resetPaymentSheetCustomer();
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] reset payment sheet customer failed: $error',
        );
      }
    }

    final initFailure = await _initializePaymentSheet(
      session: session,
      truffle: truffle,
      shippingAddress: shippingAddress,
    );
    if (initFailure != null) {
      return CheckoutPaymentSheetResult.failure(initFailure);
    }

    try {
      await Stripe.instance.presentPaymentSheet();
      return CheckoutPaymentSheetResult.success(
        paymentAttemptId: session.paymentAttemptId,
        stripePaymentIntentId: session.stripePaymentIntentId,
      );
    } on StripeException catch (error) {
      return _mapStripePresentationError(error);
    } on SocketException {
      return const CheckoutPaymentSheetResult.failure(CheckoutFailure.network);
    } on TimeoutException {
      return const CheckoutPaymentSheetResult.failure(CheckoutFailure.network);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] present payment sheet failed: $error',
        );
      }
      return const CheckoutPaymentSheetResult.failure(CheckoutFailure.unknown);
    }
  }

  Future<String?> finalizePaymentAttempt({
    required String paymentAttemptId,
    required String stripePaymentIntentId,
  }) async {
    try {
      final response = await _supabaseClient.functions
          .invoke(
            'finalize_payment_attempt',
            body: {
              'payment_attempt_id': paymentAttemptId,
              'stripe_payment_intent_id': stripePaymentIntentId,
            },
          )
          .timeout(_timeout);

      if (response.status < 200 || response.status >= 300) {
        if (kDebugMode) {
          debugPrint(
            '[CheckoutPaymentService] finalize payment attempt failed with status ${response.status}',
          );
        }
        return null;
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return null;
      }

      final orderId = data['order_id'] as String?;
      return orderId;
    } on FunctionException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] finalize payment attempt function error: ${error.status}',
        );
      }
      return null;
    } on SocketException {
      return null;
    } on TimeoutException {
      return null;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] finalize payment attempt failed: $error',
        );
      }
      return null;
    }
  }

  Future<CheckoutFailure?> _initializePaymentSheet({
    required _CheckoutIntentSession session,
    required TruffleDetail truffle,
    required ShippingAddress shippingAddress,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: _buildPaymentSheetParameters(
          session: session,
          truffle: truffle,
          shippingAddress: shippingAddress,
          includeWallets: true,
        ),
      );
      return null;
    } on StripeConfigException catch (error) {
      if (_canRetryWithoutWallets(error.message)) {
        return _retryWithoutWallets(
          session: session,
          truffle: truffle,
          shippingAddress: shippingAddress,
          error: error.message,
        );
      }
      return CheckoutFailure.paymentFailed;
    } on StripeException catch (error) {
      final message = [
        error.error.localizedMessage,
        error.error.message,
        error.error.stripeErrorCode,
      ].whereType<String>().join(' ');
      if (_canRetryWithoutWallets(message)) {
        return _retryWithoutWallets(
          session: session,
          truffle: truffle,
          shippingAddress: shippingAddress,
          error: message,
        );
      }
      return CheckoutFailure.paymentFailed;
    } on SocketException {
      return CheckoutFailure.network;
    } on TimeoutException {
      return CheckoutFailure.network;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] init payment sheet failed: $error',
        );
      }
      return CheckoutFailure.unknown;
    }
  }

  Future<CheckoutFailure?> _retryWithoutWallets({
    required _CheckoutIntentSession session,
    required TruffleDetail truffle,
    required ShippingAddress shippingAddress,
    required String error,
  }) async {
    if (kDebugMode) {
      debugPrint(
        '[CheckoutPaymentService] retrying payment sheet without wallets: $error',
      );
    }
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: _buildPaymentSheetParameters(
          session: session,
          truffle: truffle,
          shippingAddress: shippingAddress,
          includeWallets: false,
        ),
      );
      return null;
    } on StripeException catch (retryError) {
      final code = retryError.error.code;
      if (code == FailureCode.Timeout) {
        return CheckoutFailure.network;
      }
      return CheckoutFailure.paymentFailed;
    } on StripeConfigException {
      return CheckoutFailure.paymentFailed;
    } on SocketException {
      return CheckoutFailure.network;
    } on TimeoutException {
      return CheckoutFailure.network;
    } catch (retryError) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] retry without wallets failed: $retryError',
        );
      }
      return CheckoutFailure.unknown;
    }
  }

  SetupPaymentSheetParameters _buildPaymentSheetParameters({
    required _CheckoutIntentSession session,
    required TruffleDetail truffle,
    required ShippingAddress shippingAddress,
    required bool includeWallets,
  }) {
    final totalAmount = truffle.priceTotal + _shippingCost(truffle, shippingAddress);
    return SetupPaymentSheetParameters(
      paymentIntentClientSecret: session.clientSecret,
      merchantDisplayName: _merchantDisplayName,
      style: ThemeMode.light,
      appearance: const PaymentSheetAppearance(
        colors: PaymentSheetAppearanceColors(
          primary: Color(0xFF151618),
          background: Color(0xFFFFFFFF),
          componentBackground: Color(0xFFFFFFFF),
          componentBorder: Color(0x24151618),
          componentDivider: Color(0x24151618),
          componentText: Color(0xFF151618),
          primaryText: Color(0xFF151618),
          secondaryText: Color(0xCC151618),
          placeholderText: Color(0x80151618),
          icon: Color(0xFF151618),
          error: Color(0xFFC62828),
        ),
        shapes: PaymentSheetShape(
          borderRadius: 10,
          borderWidth: 1.2,
          shadow: PaymentSheetShadowParams(
            color: Color(0xFF151618),
            opacity: 0.08,
            offset: PaymentSheetShadowOffset(x: 0, y: 6),
          ),
        ),
        primaryButton: PaymentSheetPrimaryButtonAppearance(
          colors: PaymentSheetPrimaryButtonTheme(
            light: PaymentSheetPrimaryButtonThemeColors(
              background: Color(0xFF151618),
              text: Color(0xFFFFFFFF),
              border: Color(0xFF151618),
            ),
          ),
          shapes: PaymentSheetPrimaryButtonShape(
            blurRadius: 0,
            borderWidth: 0,
            shadow: PaymentSheetShadowParams(
              color: Color(0xFF151618),
              opacity: 0,
              offset: PaymentSheetShadowOffset(x: 0, y: 0),
            ),
          ),
        ),
      ),
      billingDetails: BillingDetails(
        name: shippingAddress.fullName,
        address: Address(
          city: shippingAddress.city,
          country: shippingAddress.countryCode,
          line1: shippingAddress.street,
          line2: null,
          postalCode: shippingAddress.postalCode,
          state: null,
        ),
      ),
      billingDetailsCollectionConfiguration:
          const BillingDetailsCollectionConfiguration(
            name: CollectionMode.always,
            email: CollectionMode.never,
            phone: CollectionMode.never,
            address: AddressCollectionMode.full,
            attachDefaultsToPaymentMethod: false,
          ),
      primaryButtonLabel: 'Pay securely',
      returnURL: _returnUrl,
      allowsDelayedPaymentMethods: false,
      paymentMethodOrder: const ['card'],
      linkDisplayParams: const LinkDisplayParams(
        linkDisplay: LinkDisplay.never,
      ),
      applePay: includeWallets && Platform.isIOS && _applePayEnabled
          ? PaymentSheetApplePay(
              merchantCountryCode: Env.stripeMerchantCountryCode,
              buttonType: PlatformButtonType.buy,
              cartItems: [
                ApplePayCartSummaryItem.immediate(
                  label: _merchantDisplayName,
                  amount: totalAmount.toStringAsFixed(2),
                ),
              ],
            )
          : null,
      googlePay: includeWallets && Platform.isAndroid
          ? PaymentSheetGooglePay(
              merchantCountryCode: Env.stripeMerchantCountryCode,
              currencyCode: 'EUR',
              testEnv: true,
              buttonType: PlatformButtonType.pay,
              label: _merchantDisplayName,
            )
          : null,
    );
  }

  Future<_CreatePaymentIntentResult> _createPaymentIntent({
    required String paymentAttemptId,
    required String truffleId,
    required String shippingAddressId,
  }) async {
    try {
      final response = await _supabaseClient.functions
          .invoke(
            'create_payment_intent',
            body: {
              'payment_attempt_id': paymentAttemptId,
              'truffle_id': truffleId,
              'shipping_address_id': shippingAddressId,
            },
          )
          .timeout(_timeout);

      if (response.status < 200 || response.status >= 300) {
        return _CreatePaymentIntentResult.failure(
          _mapFunctionFailure(response.status),
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return const _CreatePaymentIntentResult.failure(CheckoutFailure.unknown);
      }

      final clientSecret = data['client_secret'] as String?;
      final stripePaymentIntentId = data['stripe_payment_intent_id'] as String?;
      final confirmedAttemptId = data['payment_attempt_id'] as String?;

      if (clientSecret == null ||
          stripePaymentIntentId == null ||
          confirmedAttemptId == null) {
        return const _CreatePaymentIntentResult.failure(CheckoutFailure.unknown);
      }

      return _CreatePaymentIntentResult.success(
        _CheckoutIntentSession(
          paymentAttemptId: confirmedAttemptId,
          stripePaymentIntentId: stripePaymentIntentId,
          clientSecret: clientSecret,
        ),
      );
    } on FunctionException catch (error) {
      return _CreatePaymentIntentResult.failure(
        _mapFunctionFailure(error.status),
      );
    } on SocketException {
      return const _CreatePaymentIntentResult.failure(CheckoutFailure.network);
    } on TimeoutException {
      return const _CreatePaymentIntentResult.failure(CheckoutFailure.network);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[CheckoutPaymentService] create payment intent failed: $error',
        );
      }
      return const _CreatePaymentIntentResult.failure(CheckoutFailure.unknown);
    }
  }

  CheckoutPaymentSheetResult _mapStripePresentationError(StripeException error) {
    return switch (error.error.code) {
      FailureCode.Canceled => const CheckoutPaymentSheetResult.canceled(),
      FailureCode.Timeout => const CheckoutPaymentSheetResult.failure(
        CheckoutFailure.network,
      ),
      _ => const CheckoutPaymentSheetResult.failure(
        CheckoutFailure.paymentFailed,
      ),
    };
  }

  CheckoutFailure _mapFunctionFailure(int status) {
    return switch (status) {
      400 || 409 || 422 => CheckoutFailure.validation,
      401 => CheckoutFailure.unauthenticated,
      403 => CheckoutFailure.forbidden,
      404 => CheckoutFailure.notFound,
      408 || 429 || 503 => CheckoutFailure.network,
      _ => CheckoutFailure.unknown,
    };
  }

  double _shippingCost(
    TruffleDetail truffle,
    ShippingAddress shippingAddress,
  ) {
    final countryCode = shippingAddress.countryCode.toUpperCase();
    if (countryCode == 'IT') {
      return truffle.shippingPriceItaly;
    }
    return truffle.shippingPriceAbroad;
  }

  bool get _applePayEnabled =>
      (Env.stripeMerchantIdentifier ?? '').trim().isNotEmpty;

  bool _canRetryWithoutWallets(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('apple pay') ||
        normalized.contains('google pay') ||
        normalized.contains('merchantidentifier') ||
        normalized.contains('merchant identifier');
  }

  String _generatePaymentAttemptId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return [
      hex.substring(0, 8),
      hex.substring(8, 12),
      hex.substring(12, 16),
      hex.substring(16, 20),
      hex.substring(20, 32),
    ].join('-');
  }
}

class _CheckoutIntentSession {
  const _CheckoutIntentSession({
    required this.paymentAttemptId,
    required this.stripePaymentIntentId,
    required this.clientSecret,
  });

  final String paymentAttemptId;
  final String stripePaymentIntentId;
  final String clientSecret;
}

class _CreatePaymentIntentResult {
  const _CreatePaymentIntentResult.success(this.session) : failure = null;
  const _CreatePaymentIntentResult.failure(this.failure) : session = null;

  final _CheckoutIntentSession? session;
  final CheckoutFailure? failure;
}
