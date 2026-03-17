class AuthRedirects {
  static const _scheme = 'truffly';
  static const _host = 'auth';
  static const _verifyEmailPath = '/verify-email';
  static const _resetPasswordPath = '/reset-password';

  static Uri get verifyEmailCallbackUri => Uri(
        scheme: _scheme,
        host: _host,
        path: _verifyEmailPath,
      );

  static Uri get resetPasswordCallbackUri => Uri(
        scheme: _scheme,
        host: _host,
        path: _resetPasswordPath,
      );
}
