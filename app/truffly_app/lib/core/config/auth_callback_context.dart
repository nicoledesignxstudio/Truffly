class AuthCallbackContext {
  AuthCallbackContext._({
    required this.uri,
    required this.prefilledEmail,
    required this.type,
    required this.code,
    required this.accessToken,
    required this.refreshToken,
    required this.error,
    required this.errorDescription,
  });

  factory AuthCallbackContext.fromUri(Uri uri) {
    final query = uri.queryParameters;
    final fragment = _parseUriFragmentAsQueryParams(uri.fragment);

    return AuthCallbackContext._(
      uri: uri,
      prefilledEmail: _normalizedEmail(query['email']),
      type: _firstNonEmpty(query, fragment, 'type')?.toLowerCase(),
      code: _firstNonEmpty(query, fragment, 'code'),
      accessToken: _firstNonEmpty(query, fragment, 'access_token'),
      refreshToken: _firstNonEmpty(query, fragment, 'refresh_token'),
      error: _firstNonEmpty(query, fragment, 'error'),
      errorDescription: _firstNonEmpty(query, fragment, 'error_description'),
    );
  }

  final Uri uri;
  final String? prefilledEmail;
  final String? type;
  final String? code;
  final String? accessToken;
  final String? refreshToken;
  final String? error;
  final String? errorDescription;

  bool get hasValidPrefilledEmail => prefilledEmail != null;

  bool get hasCode => code != null;

  bool get hasSessionTokens => accessToken != null && refreshToken != null;

  bool get hasPartialSessionTokens =>
      (accessToken != null && refreshToken == null) ||
      (accessToken == null && refreshToken != null);

  bool get hasCallbackError => error != null || errorDescription != null;

  bool get hasValidVerifyContext {
    if (hasValidPrefilledEmail) return true;
    if (hasPartialSessionTokens) return false;

    final isAllowedVerifyType =
        type == 'signup' || type == 'invite' || type == 'email_change';
    if (!isAllowedVerifyType) return false;

    return hasCode || hasSessionTokens || hasCallbackError;
  }

  bool get hasValidRecoveryContext {
    if (type != 'recovery') return false;
    if (hasPartialSessionTokens) return false;
    return hasCode || hasSessionTokens;
  }

  bool get hasSessionMaterial => hasCode || hasSessionTokens;

  static String? _normalizedEmail(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (!trimmed.contains('@') || trimmed.startsWith('@') || trimmed.endsWith('@')) {
      return null;
    }
    return trimmed;
  }
}

Map<String, String> _parseUriFragmentAsQueryParams(String fragment) {
  if (fragment.trim().isEmpty) return const {};

  try {
    return Uri.splitQueryString(fragment);
  } catch (_) {
    return const {};
  }
}

String? _firstNonEmpty(
  Map<String, String> query,
  Map<String, String> fragment,
  String key,
) {
  final queryValue = query[key]?.trim();
  if (queryValue != null && queryValue.isNotEmpty) return queryValue;

  final fragmentValue = fragment[key]?.trim();
  if (fragmentValue != null && fragmentValue.isNotEmpty) return fragmentValue;

  return null;
}
