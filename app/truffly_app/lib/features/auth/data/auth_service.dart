import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/auth_redirects.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';

final class AuthUserSnapshot {
  const AuthUserSnapshot({
    required this.userId,
    required this.email,
    required this.emailVerified,
  });

  final String userId;
  final String email;
  final bool emailVerified;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthUserSnapshot &&
            other.userId == userId &&
            other.email == email &&
            other.emailVerified == emailVerified);
  }

  @override
  int get hashCode => Object.hash(userId, email, emailVerified);
}

final class AuthService {
  AuthService(this._supabaseClient);

  static const Duration _requestTimeout = Duration(seconds: 12);

  final SupabaseClient _supabaseClient;

  Future<AuthResult<AuthSignupSuccess>> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      final response = await _supabaseClient.auth
          .signUp(
            email: normalizedEmail,
            password: password,
            emailRedirectTo:
                emailRedirectTo ?? AuthRedirects.verifyEmailCallbackUri.toString(),
          )
          .timeout(_requestTimeout);
      return AuthSuccess<AuthSignupSuccess>(
        AuthSignupSuccess(
          email: normalizedEmail,
          sessionEstablished: response.session != null,
        ),
      );
    } catch (error) {
      return AuthFailureResult<AuthSignupSuccess>(_mapAuthError(error));
    }
  }

  Future<AuthResult<AuthUnit>> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      await _supabaseClient.auth
          .signInWithPassword(email: normalizedEmail, password: password)
          .timeout(_requestTimeout);
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapAuthError(error));
    }
  }

  Future<AuthResult<AuthUnit>> signOut() async {
    try {
      await _supabaseClient.auth.signOut().timeout(_requestTimeout);
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapAuthError(error));
    }
  }

  Future<AuthResult<AuthUnit>> resendVerificationEmail({
    required String email,
    String? emailRedirectTo,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      await _supabaseClient.auth
          .resend(
            email: normalizedEmail,
            type: OtpType.signup,
            emailRedirectTo:
                emailRedirectTo ?? AuthRedirects.verifyEmailCallbackUri.toString(),
          )
          .timeout(_requestTimeout);
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapAuthError(error));
    }
  }

  Future<AuthResult<AuthUnit>> sendPasswordResetEmail({
    required String email,
    String? emailRedirectTo,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      await _supabaseClient.auth
          .resetPasswordForEmail(
            normalizedEmail,
            redirectTo:
                emailRedirectTo ??
                AuthRedirects.resetPasswordCallbackUri.toString(),
          )
          .timeout(_requestTimeout);
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapAuthError(error));
    }
  }

  Future<AuthResult<AuthUnit>> updatePassword({
    required String newPassword,
  }) async {
    try {
      await _supabaseClient.auth
          .updateUser(
            UserAttributes(password: newPassword),
          )
          .timeout(_requestTimeout);
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapAuthError(error));
    }
  }

  Session? getCurrentSession() {
    return _supabaseClient.auth.currentSession;
  }

  Future<AuthResult<AuthUserSnapshot>> refreshUser() async {
    try {
      final response =
          await _supabaseClient.auth.getUser().timeout(_requestTimeout);
      final user = response.user;
      if (user == null) {
        return const AuthFailureResult<AuthUserSnapshot>(
          UnauthenticatedFailure(),
        );
      }
      return AuthSuccess<AuthUserSnapshot>(_toUserSnapshot(user));
    } catch (error) {
      return AuthFailureResult<AuthUserSnapshot>(_mapAuthError(error));
    }
  }

  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  AuthUserSnapshot _toUserSnapshot(User user) {
    // Supabase exposes the dedicated email verification timestamp.
    // This is the source of truth for email verification state.
    return AuthUserSnapshot(
      userId: user.id,
      email: (user.email ?? '').trim(),
      emailVerified: user.emailConfirmedAt != null,
    );
  }

  AuthFailure _mapAuthError(Object error) {
    if (error is TimeoutException) {
      return const TimeoutFailure();
    }

    if (error is SocketException || error is HttpException) {
      return const NetworkErrorFailure();
    }

    if (error is AuthException) {
      final statusCode = int.tryParse((error.statusCode ?? '').trim());
      final code = (error.code ?? '').trim().toLowerCase();
      final message = error.message.toLowerCase();

      if (statusCode == 408 ||
          statusCode == 504 ||
          code == 'request_timeout' ||
          code == 'hook_timeout' ||
          code == 'hook_timeout_after_retry') {
        return const TimeoutFailure();
      }

      if (code == 'session_not_found' ||
          code == 'no_authorization' ||
          code == 'bad_jwt' ||
          error is AuthSessionMissingException) {
        return const UnauthenticatedFailure();
      }

      if (code == 'email_exists' ||
          code == 'user_already_exists' ||
          code == 'identity_already_exists' ||
          message.contains('already registered') ||
          message.contains('email already') ||
          message.contains('already exists')) {
        return const EmailAlreadyUsedFailure();
      }

      if (code == 'email_not_confirmed' ||
          code == 'provider_email_needs_verification' ||
          message.contains('email not confirmed') ||
          message.contains('email not verified')) {
        return const EmailNotVerifiedFailure();
      }

      if (statusCode == 401 ||
          code == 'invalid_credentials' ||
          code == 'user_not_found' ||
          message.contains('invalid login credentials') ||
          message.contains('invalid credentials')) {
        return const InvalidCredentialsFailure();
      }

      if (code == 'otp_expired' ||
          code == 'flow_state_expired' ||
          code == 'flow_state_not_found' ||
          code == 'bad_code_verifier' ||
          _looksLikeRecoveryLinkError(message)) {
        return const ResetLinkInvalidFailure();
      }

      if (statusCode != null && statusCode >= 500) {
        return const NetworkErrorFailure();
      }
    }

    return const UnknownAuthFailure();
  }

  bool _looksLikeRecoveryLinkError(String message) {
    final hasTokenRef = message.contains('token') || message.contains('otp');
    final hasInvalidRef =
        message.contains('invalid') || message.contains('expired');
    final hasRecoveryRef =
        message.contains('recovery') || message.contains('reset password');

    return (hasTokenRef && hasInvalidRef) || hasRecoveryRef;
  }
}
