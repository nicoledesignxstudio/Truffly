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
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.sellerStatus,
    required this.countryCode,
    required this.region,
    required this.bio,
    required this.profileImageUrl,
  });

  final String userId;
  final String email;
  final bool onboardingCompleted;
  final String? firstName;
  final String? lastName;
  final String role;
  final String sellerStatus;
  final String? countryCode;
  final String? region;
  final String? bio;
  final String? profileImageUrl;

  bool get isSeller => role == 'seller';

  String get displayName {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    final fullName = '$first $last'.trim();
    if (fullName.isNotEmpty) return fullName;

    final normalizedEmail = email.trim();
    if (normalizedEmail.isNotEmpty) {
      return normalizedEmail.split('@').first.trim();
    }

    return 'Truffly';
  }

  String get initials {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();

    final parts = <String>[
      if (first.isNotEmpty) first,
      if (last.isNotEmpty) last,
    ];
    if (parts.isNotEmpty) {
      return parts.take(2).map((part) => part[0].toUpperCase()).join();
    }

    final normalizedEmail = email.trim();
    if (normalizedEmail.isNotEmpty) {
      return normalizedEmail[0].toUpperCase();
    }

    return 'T';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CurrentUserProfile &&
            other.userId == userId &&
            other.email == email &&
            other.onboardingCompleted == onboardingCompleted &&
            other.firstName == firstName &&
            other.lastName == lastName &&
            other.role == role &&
            other.sellerStatus == sellerStatus &&
            other.countryCode == countryCode &&
            other.region == region &&
            other.bio == bio &&
            other.profileImageUrl == profileImageUrl);
  }

  @override
  int get hashCode => Object.hash(
    userId,
    email,
    onboardingCompleted,
    firstName,
    lastName,
    role,
    sellerStatus,
    countryCode,
    region,
    bio,
    profileImageUrl,
  );
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
          .select(
            'id, onboarding_completed, first_name, last_name, role, '
            'seller_status, country_code, region, bio, profile_image_url',
          )
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
        firstName: (row['first_name'] as String?)?.trim(),
        lastName: (row['last_name'] as String?)?.trim(),
        role: (row['role'] as String? ?? 'buyer').trim().toLowerCase(),
        sellerStatus:
            (row['seller_status'] as String? ?? 'not_requested')
                .trim()
                .toLowerCase(),
        countryCode: (row['country_code'] as String?)?.trim().toUpperCase(),
        region: (row['region'] as String?)?.trim(),
        bio: (row['bio'] as String?)?.trim(),
        profileImageUrl: (row['profile_image_url'] as String?)?.trim(),
      );

      return AuthSuccess<CurrentUserProfile>(profile);
    } catch (error) {
      return AuthFailureResult<CurrentUserProfile>(_mapProfileError(error));
    }
  }

  Future<AuthResult<AuthUnit>> completeBuyerOnboarding({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String? region,
  }) async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      return const AuthFailureResult<AuthUnit>(UnauthenticatedFailure());
    }

    try {
      await _supabaseClient
          .from('users')
          .update({
            'first_name': firstName,
            'last_name': lastName,
            'country_code': countryCode,
            'region': region,
            'onboarding_completed': true,
          })
          .eq('id', authUser.id)
          .select('id')
          .single()
          .timeout(_requestTimeout);

      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapProfileError(error));
    }
  }

  Future<AuthResult<AuthUnit>> updateCurrentUserProfileDetails({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String? region,
    required String? bio,
    required String? profileImageUrl,
  }) async {
    final authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      return const AuthFailureResult<AuthUnit>(UnauthenticatedFailure());
    }

    final normalizedCountryCode = countryCode.trim().toUpperCase();
    final normalizedRegion = normalizedCountryCode == 'IT'
        ? _normalizeOptional(region)
        : null;

    try {
      await _supabaseClient
          .from('users')
          .update({
            'first_name': firstName.trim(),
            'last_name': lastName.trim(),
            'country_code': normalizedCountryCode,
            'region': normalizedRegion,
            'bio': _normalizeOptional(bio),
            'profile_image_url': _normalizeOptional(profileImageUrl),
          })
          .eq('id', authUser.id)
          .select('id')
          .single()
          .timeout(_requestTimeout);

      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      return AuthFailureResult<AuthUnit>(_mapProfileError(error));
    }
  }

  String? _normalizeOptional(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
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

      final message = error.message.toLowerCase();
      if (message.contains('network') || message.contains('fetch')) {
        return const NetworkErrorFailure();
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
