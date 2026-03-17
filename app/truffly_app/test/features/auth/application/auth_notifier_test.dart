import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';

class TestBootstrapNotifier extends BootstrapNotifier {
  TestBootstrapNotifier(this._initialState);

  final BootstrapState _initialState;

  @override
  BootstrapState build() => _initialState;

  @override
  Future<void> startBootstrap() async {}

  @override
  Future<void> retryBootstrap() async {}

  void emit(BootstrapState nextState) {
    state = nextState;
  }
}

void main() {
  ProviderContainer createContainer({
    TestBootstrapNotifier? bootstrapNotifier,
  }) {
    return ProviderContainer(
      overrides: [
        if (bootstrapNotifier != null)
          bootstrapNotifierProvider.overrideWith(() => bootstrapNotifier),
        supabaseClientProvider.overrideWithValue(
          sb.SupabaseClient(
            'https://example.supabase.co',
            'public-anon-key',
          ),
        ),
      ],
    );
  }

  Future<AuthState> waitForResolvedState(ProviderContainer container) async {
    final completer = Completer<AuthState>();

    final subscription = container.listen<AuthState>(
      authNotifierProvider,
      (_, next) {
        if (next is! AuthChecking && !completer.isCompleted) {
          completer.complete(next);
        }
      },
      fireImmediately: true,
    );

    final state = await completer.future;
    subscription.close();
    return state;
  }

  test(
    'bootstrap handoff resolves when bootstrap is already complete before auth creation',
    () async {
      final bootstrapNotifier = TestBootstrapNotifier(
        const BootstrapUnauthenticated(),
      );
      final container = createContainer(bootstrapNotifier: bootstrapNotifier);
      addTearDown(container.dispose);

      final resolvedState = await waitForResolvedState(container);
      expect(resolvedState, isA<AuthUnauthenticated>());
    },
  );

  test('bootstrap handoff resolves when bootstrap completes after auth creation', () async {
    final bootstrapNotifier = TestBootstrapNotifier(const BootstrapInitial());
    final container = createContainer(bootstrapNotifier: bootstrapNotifier);
    addTearDown(container.dispose);

    final resolvedStateFuture = waitForResolvedState(container);

    bootstrapNotifier.emit(const BootstrapUnauthenticated());

    final resolvedState = await resolvedStateFuture;
    expect(resolvedState, isA<AuthUnauthenticated>());
  });

  test('bootstrap completion signals do not trigger duplicate auth initialization', () async {
    final bootstrapNotifier = TestBootstrapNotifier(
      const BootstrapUnauthenticated(),
    );
    final container = createContainer(bootstrapNotifier: bootstrapNotifier);
    addTearDown(container.dispose);

    final resolvedStates = <AuthState>[];
    final subscription = container.listen<AuthState>(
      authNotifierProvider,
      (_, next) {
        if (next is! AuthChecking) {
          resolvedStates.add(next);
        }
      },
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await Future<void>.microtask(() {});
    await Future<void>.microtask(() {});

    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    expect(resolvedStates, hasLength(1));

    bootstrapNotifier.emit(const BootstrapAuthenticated());
    await Future<void>.microtask(() {});
    await Future<void>.microtask(() {});

    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
    expect(resolvedStates, hasLength(1));
  });

  test('startup resolves to unauthenticated when no session is available', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authNotifierProvider.notifier);
    notifier.ensureInitialized();

    final resolvedState = await waitForResolvedState(container);
    expect(resolvedState, isA<AuthUnauthenticated>());
  });

  test('manual recheck returns unauthenticated failure with no session', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authNotifierProvider.notifier);
    final result = await notifier.recheckVerificationStatus();

    expect(result, isA<AuthFailureResult<AuthUnit>>());
    expect(result.failureOrNull, const UnauthenticatedFailure());
    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
  });

  test('queued rechecks are processed and complete without timing waits', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final notifier = container.read(authNotifierProvider.notifier);
    final results = await Future.wait<AuthResult<AuthUnit>>([
      notifier.recheckVerificationStatus(),
      notifier.recheckVerificationStatus(),
      notifier.recheckVerificationStatus(),
    ]);

    for (final result in results) {
      expect(result, isA<AuthFailureResult<AuthUnit>>());
      expect(result.failureOrNull, const UnauthenticatedFailure());
    }
    expect(container.read(authNotifierProvider), isA<AuthUnauthenticated>());
  });
}
