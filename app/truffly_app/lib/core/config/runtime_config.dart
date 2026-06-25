class RuntimeConfig {
  RuntimeConfig._();

  static const String _defaultStripeAppleMerchantIdentifier =
      'merchant.com.truffly.app';

  static const String _stripePublishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  static const String _stripePublishableKeyTest =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY_TEST');
  static const String _stripeMerchantIdentifier =
      String.fromEnvironment('STRIPE_MERCHANT_IDENTIFIER');
  static const String _stripeMerchantCountryCode =
      String.fromEnvironment('STRIPE_MERCHANT_COUNTRY_CODE');
  static const String _stripeGooglePayTestEnv =
      String.fromEnvironment('STRIPE_GOOGLE_PAY_TEST_ENV');
  static const String _androidDeviceHost =
      String.fromEnvironment('ANDROID_DEVICE_HOST');

  static String get stripePublishableKey {
    final publishableKey = _stripePublishableKey.trim();
    if (publishableKey.isNotEmpty) {
      return publishableKey;
    }

    final testKey = _stripePublishableKeyTest.trim();
    if (testKey.isNotEmpty) {
      return testKey;
    }

    throw StateError(
      'Missing Stripe publishable key. '
      'Pass STRIPE_PUBLISHABLE_KEY or STRIPE_PUBLISHABLE_KEY_TEST via dart-define.',
    );
  }

  static String get stripeAppleMerchantIdentifier {
    final value = _stripeMerchantIdentifier.trim();
    return value.isEmpty ? _defaultStripeAppleMerchantIdentifier : value;
  }

  static String get stripeMerchantCountryCode {
    final value = _stripeMerchantCountryCode.trim();
    return (value.isEmpty ? 'IT' : value).toUpperCase();
  }

  static bool get stripeGooglePayTestEnv {
    final configured = _stripeGooglePayTestEnv.trim().toLowerCase();
    if (configured == 'true') return true;
    if (configured == 'false') return false;
    return !stripePublishableKey.startsWith('pk_live_');
  }

  static String? get androidDeviceHost {
    final value = _androidDeviceHost.trim();
    return value.isEmpty ? null : value;
  }
}
