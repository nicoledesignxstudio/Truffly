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
  static const truffles = '/truffles';
  static const truffleDetail = '/truffles/:truffleId';

  static String verifyEmailWithPrefill(String email) {
    final normalizedEmail = email.trim();
    final query = Uri(queryParameters: {'email': normalizedEmail}).query;
    return '$verifyEmail?$query';
  }

  static String truffleDetailPath(String truffleId) {
    return '/truffles/$truffleId';
  }
}
