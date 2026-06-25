import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/auth_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/push/application/push_token_service_provider.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final passwordRecoveryFlowProvider =
    NotifierProvider<PasswordRecoveryFlowNotifier, bool>(
      PasswordRecoveryFlowNotifier.new,
    );

enum _AuthReevaluationTrigger {
  bootstrapHandoff,
  signedIn,
  signedOut,
  tokenRefreshed,
  userUpdated,
  passwordRecovery,
  appResumed,
  manualVerificationCheck,
  manualRefresh,
  localActionFallback,
}

class AuthNotifier extends Notifier<AuthState> {
  static const _startupRetryDelay = Duration(milliseconds: 600);

  StreamSubscription<sb.AuthState>? _authStateSub;
  AppLifecycleListener? _appLifecycleListener;
  final ListQueue<_QueuedAuthEvaluation> _evaluationQueue = ListQueue();
  _QueuedAuthEvaluation? _activeEvaluation;
  bool _isInitialized = false;
  bool _isInitializationScheduled = false;
  bool _isProcessingQueue = false;
  bool _isDisposed = false;
  bool _hasPendingStartupRetry = false;
  AuthState? _lastResolvedState;

  @override
  AuthState build() {
    final bootstrapState = ref.read(bootstrapNotifierProvider);
    _scheduleInitializationForBootstrapState(bootstrapState);

    ref.listen<BootstrapState>(bootstrapNotifierProvider, (_, next) {
      _scheduleInitializationForBootstrapState(next);
    });

    ref.onDispose(() {
      _disposeInternal();
    });
    return const AuthChecking();
  }

  void ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    _isInitializationScheduled = false;
    _subscribeToAuthStateChanges();
    _subscribeToAppLifecycle();
    unawaited(
      _requestAuthEvaluation(_AuthReevaluationTrigger.bootstrapHandoff),
    );
  }

  void _scheduleInitializationForBootstrapState(BootstrapState bootstrapState) {
    if (!_isBootstrapGateComplete(bootstrapState)) return;
    if (_isDisposed || _isInitialized || _isInitializationScheduled) return;

    _isInitializationScheduled = true;
    Future.microtask(() {
      if (_isDisposed) {
        _isInitializationScheduled = false;
        return;
      }
      ensureInitialized();
    });
  }

  Future<AuthResult<AuthSignupSuccess>> signUp({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .signUp(email: email, password: password);

    if (result.isFailure) {
      await _requestAuthEvaluation(
        _AuthReevaluationTrigger.localActionFallback,
      );
    } else if (result.dataOrNull?.sessionEstablished == true) {
      await _requestAuthEvaluation(_AuthReevaluationTrigger.signedIn);
    }

    return result;
  }

  Future<AuthResult<AuthUnit>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .signIn(email: email, password: password);

    if (result.isFailure) {
      await _requestAuthEvaluation(
        _AuthReevaluationTrigger.localActionFallback,
      );
    }

    return result;
  }

  Future<AuthResult<AuthUnit>> signOut() async {
    try {
      await ref.read(pushTokenServiceProvider).clearCurrentToken();
    } catch (_) {
      // Token cleanup should not block signing out.
    }

    final result = await ref.read(authServiceProvider).signOut();

    if (result.isSuccess) {
      ref.read(passwordRecoveryFlowProvider.notifier).clear();
      await _requestAuthEvaluation(_AuthReevaluationTrigger.signedOut);
    } else {
      await _requestAuthEvaluation(
        _AuthReevaluationTrigger.localActionFallback,
      );
    }

    return result;
  }

  Future<AuthResult<AuthUnit>> resendVerificationEmail({
    required String email,
  }) async {
    return ref.read(authServiceProvider).resendVerificationEmail(email: email);
  }

  Future<AuthResult<AuthUnit>> resendEmailChangeVerification({
    required String email,
  }) async {
    return ref
        .read(authServiceProvider)
        .resendEmailChangeVerification(email: email);
  }

  Future<AuthResult<AuthUnit>> sendPasswordResetEmail({
    required String email,
    String? emailRedirectTo,
  }) async {
    return ref
        .read(authServiceProvider)
        .sendPasswordResetEmail(email: email, emailRedirectTo: emailRedirectTo);
  }

  Future<AuthResult<AuthUnit>> updatePassword({
    required String newPassword,
  }) async {
    final result = await ref
        .read(authServiceProvider)
        .updatePassword(newPassword: newPassword);
    if (result.isSuccess) {
      ref.read(passwordRecoveryFlowProvider.notifier).clear();
    }
    return result;
  }

  Future<AuthResult<AuthUnit>> recheckVerificationStatus() async {
    return _requestAuthEvaluation(
      _AuthReevaluationTrigger.manualVerificationCheck,
    );
  }

  Future<AuthResult<AuthUnit>> completeEmailChange({
    required String expectedEmail,
  }) async {
    final verificationResult = await ref
        .read(authServiceProvider)
        .verifyEmailChangeCompleted(expectedEmail: expectedEmail);
    if (verificationResult.isFailure) {
      return verificationResult;
    }

    return signOut();
  }

  Future<AuthResult<AuthUnit>> refreshAuthState() async {
    return _requestAuthEvaluation(_AuthReevaluationTrigger.manualRefresh);
  }

  void _subscribeToAuthStateChanges() {
    if (_authStateSub != null) return;

    final supabase = ref.read(supabaseClientProvider);
    _authStateSub = supabase.auth.onAuthStateChange.listen(
      (authState) {
        if (authState.event == sb.AuthChangeEvent.passwordRecovery) {
          ref.read(passwordRecoveryFlowProvider.notifier).activate();
        }
        final trigger = _mapAuthEventToTrigger(authState.event);
        if (trigger != null) {
          unawaited(_requestAuthEvaluation(trigger));
        }
      },
      onError: (error, stackTrace) {
        // Stream errors mean auth sync may be stale; re-evaluate conservatively.
        unawaited(
          _requestAuthEvaluation(_AuthReevaluationTrigger.localActionFallback),
        );
      },
    );
  }

  void _subscribeToAppLifecycle() {
    if (_appLifecycleListener != null) return;

    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        unawaited(_requestAuthEvaluation(_AuthReevaluationTrigger.appResumed));
      },
    );
  }

  Future<AuthResult<AuthUnit>> _requestAuthEvaluation(
    _AuthReevaluationTrigger trigger,
  ) {
    if (_isDisposed) {
      return Future.value(
        const AuthFailureResult<AuthUnit>(UnknownAuthFailure()),
      );
    }

    final item = _QueuedAuthEvaluation(
      trigger: trigger,
      completer: Completer<AuthResult<AuthUnit>>(),
    );
    _evaluationQueue.add(item);
    _consumeEvaluationQueue();
    return item.completer.future;
  }

  void _consumeEvaluationQueue() {
    if (_isDisposed || _isProcessingQueue) return;

    _isProcessingQueue = true;
    unawaited(() async {
      try {
        while (!_isDisposed && _evaluationQueue.isNotEmpty) {
          final item = _evaluationQueue.removeFirst();
          _activeEvaluation = item;

          AuthResult<AuthUnit> result;
          try {
            result = await _evaluateAuthStateOnce(item.trigger);
          } catch (_) {
            result = const AuthFailureResult<AuthUnit>(UnknownAuthFailure());
          }

          if (!item.completer.isCompleted) {
            item.completer.complete(
              _isDisposed
                  ? const AuthFailureResult<AuthUnit>(UnknownAuthFailure())
                  : result,
            );
          }
          _activeEvaluation = null;
        }
      } finally {
        _isProcessingQueue = false;
        if (!_isDisposed && _evaluationQueue.isNotEmpty) {
          _consumeEvaluationQueue();
        }
      }
    }());
  }

  Future<AuthResult<AuthUnit>> _evaluateAuthStateOnce(
    _AuthReevaluationTrigger trigger,
  ) async {
    if (_isDisposed) {
      return const AuthFailureResult<AuthUnit>(UnknownAuthFailure());
    }

    final previousStableState =
        _lastResolvedState ?? const AuthUnauthenticated();
    final shouldShowCheckingGate =
        _lastResolvedState == null ||
        trigger == _AuthReevaluationTrigger.bootstrapHandoff;
    AuthUserSnapshot? latestUserSnapshot;

    if (shouldShowCheckingGate) {
      _setResolvedState(const AuthChecking());
    }

    try {
      final authService = ref.read(authServiceProvider);
      final profileService = ref.read(profileServiceProvider);

      final session = authService.getCurrentSession();
      if (session == null) {
        _setResolvedState(const AuthUnauthenticated());
        return const AuthFailureResult<AuthUnit>(UnauthenticatedFailure());
      }

      final refreshedUserResult = await authService.refreshUser();
      if (refreshedUserResult is AuthFailureResult<AuthUserSnapshot>) {
        final failure = refreshedUserResult.failure;
        final fallbackSnapshot = _fallbackUserSnapshotForRefreshFailure(
          trigger: trigger,
          currentAuthUser: _readCurrentAuthUser(),
        );
        if (fallbackSnapshot != null) {
          latestUserSnapshot = fallbackSnapshot;
        } else {
          final nextState = _safeStateForFailure(
            failure,
            previousStableState: previousStableState,
            latestUserSnapshot: latestUserSnapshot,
          );
          _setResolvedState(nextState);
          _scheduleStartupRetryIfNeeded(
            nextState: nextState,
            trigger: trigger,
            latestUserSnapshot: latestUserSnapshot,
          );
          return AuthFailureResult<AuthUnit>(failure);
        }
      } else {
        latestUserSnapshot =
            (refreshedUserResult as AuthSuccess<AuthUserSnapshot>).data;
      }

      if (!latestUserSnapshot.emailVerified) {
        _setResolvedState(
          AuthAuthenticatedUnverified(
            userId: latestUserSnapshot.userId,
            email: latestUserSnapshot.email,
          ),
        );
        if (trigger == _AuthReevaluationTrigger.manualVerificationCheck) {
          return const AuthFailureResult<AuthUnit>(EmailNotVerifiedFailure());
        }
        return const AuthSuccess<AuthUnit>(AuthUnit.value);
      }

      final profileResult = await profileService.getCurrentUserProfile();
      if (profileResult is AuthFailureResult<CurrentUserProfile>) {
        final failure = profileResult.failure;
        if (_shouldExpireSessionForFailure(failure, latestUserSnapshot)) {
          await _expireCurrentSession();
        }
        final nextState = _safeStateForFailure(
          failure,
          previousStableState: previousStableState,
          latestUserSnapshot: latestUserSnapshot,
        );
        _setResolvedState(nextState);
        _scheduleStartupRetryIfNeeded(
          nextState: nextState,
          trigger: trigger,
          latestUserSnapshot: latestUserSnapshot,
        );
        return AuthFailureResult<AuthUnit>(failure);
      }

      final profile = (profileResult as AuthSuccess<CurrentUserProfile>).data;
      if (!profile.onboardingCompleted) {
        _setResolvedState(
          AuthAuthenticatedOnboardingRequired(
            userId: profile.userId,
            email: profile.email,
          ),
        );
        return const AuthSuccess<AuthUnit>(AuthUnit.value);
      }

      _setResolvedState(
        AuthAuthenticatedReady(userId: profile.userId, email: profile.email),
      );
      return const AuthSuccess<AuthUnit>(AuthUnit.value);
    } catch (error) {
      final failure = _mapUnexpectedError(error);
      final nextState = _safeStateForFailure(
        failure,
        previousStableState: previousStableState,
        latestUserSnapshot: latestUserSnapshot,
      );
      _setResolvedState(nextState);
      _scheduleStartupRetryIfNeeded(
        nextState: nextState,
        trigger: trigger,
        latestUserSnapshot: latestUserSnapshot,
      );
      return AuthFailureResult<AuthUnit>(failure);
    }
  }

  AuthUserSnapshot? _fallbackUserSnapshotForRefreshFailure({
    required _AuthReevaluationTrigger trigger,
    required sb.User? currentAuthUser,
  }) {
    if (trigger != _AuthReevaluationTrigger.manualRefresh ||
        currentAuthUser == null) {
      return null;
    }

    return AuthUserSnapshot(
      userId: currentAuthUser.id,
      email: (currentAuthUser.email ?? '').trim(),
      emailVerified: currentAuthUser.emailConfirmedAt != null,
      pendingEmail: currentAuthUser.newEmail?.trim(),
    );
  }

  void _setResolvedState(AuthState nextState) {
    state = nextState;
    if (nextState is! AuthChecking) {
      _hasPendingStartupRetry = false;
    }
    if (nextState is! AuthChecking) {
      _lastResolvedState = nextState;
    }
  }

  AuthState _safeStateForFailure(
    AuthFailure failure, {
    required AuthState previousStableState,
    required AuthUserSnapshot? latestUserSnapshot,
  }) {
    final currentAuthUser = _readCurrentAuthUser();

    // Failure policy:
    // - definitive failures => resolve to unprivileged state
    // - transient failures => conservative fallback without granting new access
    return switch (failure) {
      UnauthenticatedFailure() => const AuthUnauthenticated(),
      InvalidCredentialsFailure() => const AuthUnauthenticated(),
      EmailAlreadyUsedFailure() => const AuthUnauthenticated(),
      ResetLinkInvalidFailure() => const AuthUnauthenticated(),
      UserProfileMissingFailure() => _profileMissingFallback(
        latestUserSnapshot: latestUserSnapshot,
        currentAuthUser: currentAuthUser,
      ),
      EmailNotVerifiedFailure() => _toUnverifiedOrFallback(
        latestUserSnapshot: latestUserSnapshot,
        currentAuthUser: currentAuthUser,
      ),
      NetworkErrorFailure() ||
      TimeoutFailure() ||
      EmailResendRateLimitedFailure() ||
      EmailDeliveryRestrictedFailure() ||
      UnknownAuthFailure() => _conservativeTransientFallback(
        previousStableState: previousStableState,
        latestUserSnapshot: latestUserSnapshot,
        currentAuthUser: currentAuthUser,
      ),
    };
  }

  AuthState _toUnverifiedOrFallback({
    required AuthUserSnapshot? latestUserSnapshot,
    required sb.User? currentAuthUser,
  }) {
    if (latestUserSnapshot != null) {
      return AuthAuthenticatedUnverified(
        userId: latestUserSnapshot.userId,
        email: latestUserSnapshot.email,
      );
    }
    if (currentAuthUser == null) return const AuthUnauthenticated();
    return AuthAuthenticatedUnverified(
      userId: currentAuthUser.id,
      email: (currentAuthUser.email ?? '').trim(),
    );
  }

  AuthState _profileMissingFallback({
    required AuthUserSnapshot? latestUserSnapshot,
    required sb.User? currentAuthUser,
  }) {
    if (latestUserSnapshot != null && !latestUserSnapshot.emailVerified) {
      return AuthAuthenticatedUnverified(
        userId: latestUserSnapshot.userId,
        email: latestUserSnapshot.email,
      );
    }

    if (currentAuthUser != null && currentAuthUser.emailConfirmedAt == null) {
      return AuthAuthenticatedUnverified(
        userId: currentAuthUser.id,
        email: (currentAuthUser.email ?? '').trim(),
      );
    }

    return const AuthUnauthenticated();
  }

  AuthState _conservativeTransientFallback({
    required AuthState previousStableState,
    required AuthUserSnapshot? latestUserSnapshot,
    required sb.User? currentAuthUser,
  }) {
    if (latestUserSnapshot != null && !latestUserSnapshot.emailVerified) {
      return AuthAuthenticatedUnverified(
        userId: latestUserSnapshot.userId,
        email: latestUserSnapshot.email,
      );
    }

    if (currentAuthUser != null && currentAuthUser.emailConfirmedAt == null) {
      return AuthAuthenticatedUnverified(
        userId: currentAuthUser.id,
        email: (currentAuthUser.email ?? '').trim(),
      );
    }

    if (previousStableState is AuthChecking && currentAuthUser != null) {
      return const AuthChecking();
    }

    return switch (previousStableState) {
      AuthAuthenticatedUnverified() => previousStableState,
      AuthAuthenticatedOnboardingRequired() ||
      AuthAuthenticatedReady() ||
      AuthChecking() ||
      AuthUnauthenticated() => const AuthUnauthenticated(),
    };
  }

  bool _isBootstrapGateComplete(BootstrapState state) {
    return switch (state) {
      BootstrapAuthenticated() || BootstrapUnauthenticated() => true,
      BootstrapInitial() || BootstrapLoading() || BootstrapError() => false,
    };
  }

  AuthFailure _mapUnexpectedError(Object error) {
    if (error is TimeoutException) return const TimeoutFailure();
    if (error is sb.AuthException) {
      final statusCode = int.tryParse((error.statusCode ?? '').trim());
      if (statusCode == 401 || statusCode == 403) {
        return const UnauthenticatedFailure();
      }
      return const UnknownAuthFailure();
    }
    return const UnknownAuthFailure();
  }

  _AuthReevaluationTrigger? _mapAuthEventToTrigger(sb.AuthChangeEvent event) {
    return switch (event) {
      sb.AuthChangeEvent.signedIn => _AuthReevaluationTrigger.signedIn,
      sb.AuthChangeEvent.signedOut => _AuthReevaluationTrigger.signedOut,
      sb.AuthChangeEvent.userUpdated => _AuthReevaluationTrigger.userUpdated,
      sb.AuthChangeEvent.passwordRecovery =>
        _AuthReevaluationTrigger.passwordRecovery,
      sb.AuthChangeEvent.tokenRefreshed =>
        _shouldReevaluateOnTokenRefreshed()
            ? _AuthReevaluationTrigger.tokenRefreshed
            : null,
      _ => null,
    };
  }

  bool _shouldReevaluateOnTokenRefreshed() {
    return true;
  }

  bool _shouldExpireSessionForFailure(
    AuthFailure failure,
    AuthUserSnapshot? latestUserSnapshot,
  ) {
    if (failure is! UserProfileMissingFailure) return false;

    if (latestUserSnapshot != null) {
      return latestUserSnapshot.emailVerified;
    }

    final currentAuthUser = _readCurrentAuthUser();
    return currentAuthUser?.emailConfirmedAt != null;
  }

  void _scheduleStartupRetryIfNeeded({
    required AuthState nextState,
    required _AuthReevaluationTrigger trigger,
    required AuthUserSnapshot? latestUserSnapshot,
  }) {
    if (_hasPendingStartupRetry) return;
    if (nextState is! AuthChecking) return;

    final currentAuthUser = _readCurrentAuthUser();
    final hasAuthenticatedMaterial =
        latestUserSnapshot != null || currentAuthUser != null;
    if (!hasAuthenticatedMaterial) return;

    if (trigger != _AuthReevaluationTrigger.bootstrapHandoff &&
        trigger != _AuthReevaluationTrigger.tokenRefreshed &&
        trigger != _AuthReevaluationTrigger.userUpdated &&
        trigger != _AuthReevaluationTrigger.appResumed) {
      return;
    }

    _hasPendingStartupRetry = true;
    Future.delayed(_startupRetryDelay, () {
      if (_isDisposed) return;
      _hasPendingStartupRetry = false;
      unawaited(_requestAuthEvaluation(_AuthReevaluationTrigger.manualRefresh));
    });
  }

  Future<void> _expireCurrentSession() async {
    final authUser = _readCurrentAuthUser();
    if (authUser == null) return;

    await ref.read(authServiceProvider).signOut();
  }

  sb.User? _readCurrentAuthUser() {
    return ref.read(supabaseClientProvider).auth.currentUser;
  }

  void _disposeInternal() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isInitializationScheduled = false;

    final sub = _authStateSub;
    _authStateSub = null;
    if (sub != null) {
      unawaited(sub.cancel());
    }

    _appLifecycleListener?.dispose();
    _appLifecycleListener = null;

    final disposeResult = const AuthFailureResult<AuthUnit>(
      UnknownAuthFailure(),
    );

    final active = _activeEvaluation;
    if (active != null && !active.completer.isCompleted) {
      active.completer.complete(disposeResult);
    }
    _activeEvaluation = null;

    while (_evaluationQueue.isNotEmpty) {
      final pending = _evaluationQueue.removeFirst();
      if (!pending.completer.isCompleted) {
        pending.completer.complete(disposeResult);
      }
    }
  }
}

class PasswordRecoveryFlowNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void activate() => state = true;

  void clear() => state = false;
}

final class _QueuedAuthEvaluation {
  const _QueuedAuthEvaluation({required this.trigger, required this.completer});

  final _AuthReevaluationTrigger trigger;
  final Completer<AuthResult<AuthUnit>> completer;
}
