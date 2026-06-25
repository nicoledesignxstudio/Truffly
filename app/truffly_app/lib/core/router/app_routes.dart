class AppRoutes {
  static const startup = '/startup';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const account = '/account';
  static const notifications = '/notifications';
  static const accountOrders = '/account/orders';
  static const accountOrderDetail = '/account/orders/:orderId';
  static const accountFavorites = '/account/favorites';
  static const accountDetails = '/account/details';
  static const accountShipping = '/account/shipping';
  static const accountShippingAdd = '/account/shipping/add';
  static const accountShippingEdit = '/account/shipping/:addressId/edit';
  static const accountBecomeSeller = '/account/become-seller';
  static const accountSellerOnboarding = '/account/become-seller/onboarding';
  static const accountMyTruffles = '/account/my-truffles';
  static const accountGuide = '/account/guide';
  static const accountSupport = '/account/support';
  static const accountSettings = '/account/settings';
  static const accountPrivacyPolicy = '/account/settings/privacy-policy';
  static const accountTerms = '/account/settings/terms';
  static const accountRefundAndCancellation =
      '/account/settings/refund-and-cancellation';
  static const accountLegalInformation = '/account/settings/legal-information';
  static const truffles = '/truffles';
  static const checkout = '/checkout/:truffleId';
  static const sellers = '/sellers';
  static const guides = '/guides';
  static const truffleDetail = '/truffles/:truffleId';
  static const sellerProfile = '/sellers/:sellerId';
  static const truffleGuide = '/guides/truffles/:truffleType';

  static String signupWithPrefill(String email) {
    final normalizedEmail = email.trim();
    final query = Uri(
      queryParameters: {
        if (normalizedEmail.isNotEmpty) 'email': normalizedEmail,
      },
    ).query;
    return query.isEmpty ? signup : '$signup?$query';
  }

  static String verifyEmailWithPrefill(
    String email, {
    bool manualFlow = false,
  }) {
    final normalizedEmail = email.trim();
    final queryParameters = <String, String>{
      'email': normalizedEmail,
      if (manualFlow) 'source': 'email_change',
    };
    final query = Uri(queryParameters: queryParameters).query;
    return '$verifyEmail?$query';
  }

  static String truffleDetailPath(String truffleId) {
    return '/truffles/$truffleId';
  }

  static String checkoutPath(String truffleId) {
    return '/checkout/$truffleId';
  }

  static String sellerProfilePath(String sellerId) {
    return '/sellers/$sellerId';
  }

  static String accountOrderDetailPath(String orderId) {
    return '/account/orders/$orderId';
  }

  static String accountShippingEditPath(String addressId) {
    return '/account/shipping/$addressId/edit';
  }

  static String truffleGuidePath(String truffleType) {
    return '/guides/truffles/$truffleType';
  }
}
