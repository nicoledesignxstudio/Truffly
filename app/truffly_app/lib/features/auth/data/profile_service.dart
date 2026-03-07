import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';

final class CurrentUserProfile {
  const CurrentUserProfile({
    required this.userId,
    required this.email,
    required this.onboardingCompleted,
  });

  final String userId;
  final String email;
  final bool onboardingCompleted;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CurrentUserProfile &&
            other.userId == userId &&
            other.email == email &&
            other.onboardingCompleted == onboardingCompleted);
  }

  @override
  int get hashCode => Object.hash(userId, email, onboardingCompleted);
}

final class ProfileService {
  ProfileService(this._supabaseClient);

  static const Duration _requestTimeout = Duration(seconds: 12);

  final SupabaseClient _supabaseClient;

  Future<AuthResult<CurrentUserProfile>> getCurrentUserProfile() async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      return const AuthFailureResult<CurrentUserProfile>(
        UnauthenticatedFailure(),
      );
    }

    try {
      final row = await _supabaseClient
          .from('users')
          .select('id, onboarding_completed')
          .eq('id', authUser.id)
          .maybeSingle()
          .timeout(_requestTimeout);

      if (row == null) {
        return const AuthFailureResult<CurrentUserProfile>(
          UserProfileMissingFailure(),
        );
      }

      final userId = row['id'] as String?;
      if (userId == null || userId.trim().isEmpty) {
        return const AuthFailureResult<CurrentUserProfile>(
          UserProfileMissingFailure(),
        );
      }

      final profile = CurrentUserProfile(
        userId: userId,
        email: (authUser.email ?? '').trim(),
        onboardingCompleted: row['onboarding_completed'] as bool? ?? false,
      );

      return AuthSuccess<CurrentUserProfile>(profile);
    } catch (error) {
      return AuthFailureResult<CurrentUserProfile>(_mapProfileError(error));
    }
  }

  AuthFailure _mapProfileError(Object error) {
    if (error is TimeoutException) {
      return const TimeoutFailure();
    }

    if (error is SocketException || error is HttpException) {
      return const NetworkErrorFailure();
    }

    if (error is PostgrestException) {
      if (error.code == 'PGRST116') {
        return const UserProfileMissingFailure();
      }

      // PostgREST codes are not reliable HTTP status codes.
      // Keep a conservative mapping and avoid fake precision.
      return const UnknownAuthFailure();
    }

    if (error is AuthException) {
      final statusCode = int.tryParse((error.statusCode ?? '').trim());
      final code = (error.code ?? '').trim().toLowerCase();

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
          statusCode == 401 ||
          statusCode == 403 ||
          error is AuthSessionMissingException) {
        return const UnauthenticatedFailure();
      }

      if (statusCode != null && statusCode >= 500) {
        return const NetworkErrorFailure();
      }

      return const UnknownAuthFailure();
    }

    return const UnknownAuthFailure();
  }
}
