import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/auth_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<sb.AuthState>? _authStateSub;
  bool _isInitialized = false;
  bool _isEvaluating = false;
  bool _hasPendingEvaluation = false;
  AuthState? _lastResolvedState;

  @override
  AuthState build() {
    ref.onDispose(() {
      final sub = _authStateSub;
      _authStateSub = null;
      if (sub != null) {
        unawaited(sub.cancel());
      }
    });
    return const AuthChecking();
  }

  void ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    _subscribeToAuthStateChanges();
    unawaited(_requestAuthEvaluation());
  }

  Future<AuthResult<AuthUnit>> signUp({
    required String email,
    required String password,
  }) async {
    final result = await ref.read(authServiceProvider).signUp(
          email: email,
          password: password,
        );

    if (result.isSuccess) {
      await _requestAuthEvaluation();
    }

    return result;
  }

  Future<AuthResult<AuthUnit>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await ref.read(authServiceProvider).signIn(
          email: email,
          password: password,
        );

    if (result.isSuccess) {
      await _requestAuthEvaluation();
    }

    return result;
  }

  Future<AuthResult<AuthUnit>> signOut() async {
    final result = await ref.read(authServiceProvider).signOut();

    await _requestAuthEvaluation();

    return result;
  }

  Future<AuthResult<AuthUnit>> recheckVerificationStatus() async {
    final refreshResult = await ref.read(authServiceProvider).refreshUser();
    await _requestAuthEvaluation();

    if (refreshResult.isFailure) {
      return AuthFailureResult<AuthUnit>(refreshResult.failureOrNull!);
    }
    return const AuthSuccess<AuthUnit>(AuthUnit.value);
  }

  void _subscribeToAuthStateChanges() {
    if (_authStateSub != null) return;

    final supabase = ref.read(supabaseClientProvider);
    _authStateSub = supabase.auth.onAuthStateChange.listen((authState) {
      final shouldReevaluate = switch (authState.event) {
        sb.AuthChangeEvent.signedIn ||
        sb.AuthChangeEvent.signedOut ||
        sb.AuthChangeEvent.tokenRefreshed ||
        sb.AuthChangeEvent.userUpdated ||
        sb.AuthChangeEvent.passwordRecovery => true,
        sb.AuthChangeEvent.initialSession ||
        sb.AuthChangeEvent.mfaChallengeVerified => false,
      };

      if (shouldReevaluate) {
        unawaited(_requestAuthEvaluation());
      }
    });
  }

  Future<void> _requestAuthEvaluation() async {
    _hasPendingEvaluation = true;
    if (_isEvaluating) return;

    _isEvaluating = true;
    try {
      while (_hasPendingEvaluation) {
        _hasPendingEvaluation = false;
        await _evaluateAuthStateOnce();
      }
    } finally {
      _isEvaluating = false;
    }
  }

  Future<void> _evaluateAuthStateOnce() async {
    final previousStableState = _lastResolvedState ?? const AuthUnauthenticated();
    _setResolvedState(const AuthChecking());

    try {
      final authService = ref.read(authServiceProvider);
      final profileService = ref.read(profileServiceProvider);
      final authUser = ref.read(supabaseClientProvider).auth.currentUser;

      final session = authService.getCurrentSession();
      if (session == null) {
        _setResolvedState(const AuthUnauthenticated());
        return;
      }

      final refreshedUserResult = await authService.refreshUser();
      if (refreshedUserResult is AuthFailureResult<AuthUserSnapshot>) {
        _setResolvedState(
          _safeStateForFailure(
            refreshedUserResult.failure,
            previousStableState: previousStableState,
            authUser: authUser,
          ),
        );
        return;
      }

      final userSnapshot =
          (refreshedUserResult as AuthSuccess<AuthUserSnapshot>).data;

      if (!userSnapshot.emailVerified) {
        _setResolvedState(
          AuthAuthenticatedUnverified(
            userId: userSnapshot.userId,
            email: userSnapshot.email,
          ),
        );
        return;
      }

      final profileResult = await profileService.getCurrentUserProfile();
      if (profileResult is AuthFailureResult<CurrentUserProfile>) {
        _setResolvedState(
          _safeStateForFailure(
            profileResult.failure,
            previousStableState: previousStableState,
            authUser: authUser,
          ),
        );
        return;
      }

      final profile = (profileResult as AuthSuccess<CurrentUserProfile>).data;
      if (!profile.onboardingCompleted) {
        _setResolvedState(
          AuthAuthenticatedOnboardingRequired(
            userId: profile.userId,
            email: profile.email,
          ),
        );
        return;
      }

      _setResolvedState(
        AuthAuthenticatedReady(
          userId: profile.userId,
          email: profile.email,
        ),
      );
    } catch (_) {
      _setResolvedState(
        _safeStateForFailure(
          const UnknownAuthFailure(),
          previousStableState: previousStableState,
          authUser: ref.read(supabaseClientProvider).auth.currentUser,
        ),
      );
    }
  }

  void _setResolvedState(AuthState nextState) {
    state = nextState;
    if (nextState is! AuthChecking) {
      _lastResolvedState = nextState;
    }
  }

  AuthState _safeStateForFailure(
    AuthFailure failure, {
    required AuthState previousStableState,
    required sb.User? authUser,
  }) {
    return switch (failure) {
      UnauthenticatedFailure() => const AuthUnauthenticated(),
      InvalidCredentialsFailure() => const AuthUnauthenticated(),
      UserProfileMissingFailure() => const AuthUnauthenticated(),
      EmailAlreadyUsedFailure() => const AuthUnauthenticated(),
      ResetLinkInvalidFailure() => const AuthUnauthenticated(),
      EmailNotVerifiedFailure() =>
        _toUnverifiedOrFallback(authUser),
      NetworkErrorFailure() ||
      TimeoutFailure() ||
      UnknownAuthFailure() =>
        _conservativeTransientFallback(
          previousStableState: previousStableState,
          authUser: authUser,
        ),
    };
  }

  AuthState _toUnverifiedOrFallback(sb.User? authUser) {
    if (authUser == null) return const AuthUnauthenticated();
    return AuthAuthenticatedUnverified(
      userId: authUser.id,
      email: (authUser.email ?? '').trim(),
    );
  }

  AuthState _conservativeTransientFallback({
    required AuthState previousStableState,
    required sb.User? authUser,
  }) {
    if (authUser != null && authUser.emailConfirmedAt == null) {
      return AuthAuthenticatedUnverified(
        userId: authUser.id,
        email: (authUser.email ?? '').trim(),
      );
    }

    return switch (previousStableState) {
      AuthAuthenticatedUnverified() => previousStableState,
      AuthAuthenticatedOnboardingRequired() => previousStableState,
      AuthAuthenticatedReady() => previousStableState,
      AuthChecking() || AuthUnauthenticated() => const AuthUnauthenticated(),
    };
  }
}
