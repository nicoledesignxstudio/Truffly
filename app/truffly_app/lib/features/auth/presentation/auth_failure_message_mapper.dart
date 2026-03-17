import 'package:truffly_app/l10n/app_localizations.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';

String loginFailureMessage(
  AuthFailure failure,
  AppLocalizations l10n,
) {
  return switch (failure) {
    InvalidCredentialsFailure() => l10n.authErrorInvalidCredentials,
    EmailNotVerifiedFailure() => l10n.authErrorEmailNotVerified,
    NetworkErrorFailure() => l10n.authErrorNetwork,
    TimeoutFailure() => l10n.authErrorTimeout,
    UnknownAuthFailure() => l10n.authErrorUnknown,
    _ => l10n.authErrorLoginFallback,
  };
}

String signupFailureMessage(
  AuthFailure failure,
  AppLocalizations l10n,
) {
  return switch (failure) {
    EmailAlreadyUsedFailure() => l10n.authErrorEmailAlreadyUsed,
    NetworkErrorFailure() => l10n.authErrorNetwork,
    TimeoutFailure() => l10n.authErrorTimeout,
    UnknownAuthFailure() => l10n.authErrorUnknown,
    _ => l10n.authErrorSignupFallback,
  };
}

