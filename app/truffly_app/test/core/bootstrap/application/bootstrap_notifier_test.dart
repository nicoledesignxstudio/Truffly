import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/data/auth_session_service.dart';
import 'package:truffly_app/core/bootstrap/data/backend_health_service.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';

class CountingBackendHealthService extends BackendHealthService {
  CountingBackendHealthService({
    required this.resultFutureFactory,
  });

  int callCount = 0;
  final Future<BackendHealthResult> Function() resultFutureFactory;

  @override
  Future<BackendHealthResult> checkHealth() {
    callCount += 1;
    return resultFutureFactory();
  }
}

class FakeAuthSessionService extends AuthSessionService {
  FakeAuthSessionService(this.result)
    : super(
        sb.SupabaseClient(
          'https://example.supabase.co',
          'public-anon-key',
          authOptions: const sb.AuthClientOptions(autoRefreshToken: false),
        ),
      );

  final AuthSessionResult result;

  @override
  AuthSessionResult getSessionStatus() => result;
}

void main() {
  ProviderContainer createContainer({
    required BackendHealthService backendHealthService,
    required AuthSessionService authSessionService,
  }) {
    return ProviderContainer(
      overrides: [
        backendHealthServiceProvider.overrideWithValue(backendHealthService),
        authSessionServiceProvider.overrideWithValue(authSessionService),
      ],
    );
  }

  test('startBootstrap ignores overlapping bootstrap start requests', () async {
    final healthCheckCompleter = Completer<BackendHealthResult>();
    final backendHealthService = CountingBackendHealthService(
      resultFutureFactory: () => healthCheckCompleter.future,
    );
    final authSessionService = FakeAuthSessionService(
      const UnauthenticatedSession(),
    );
    final container = createContainer(
      backendHealthService: backendHealthService,
      authSessionService: authSessionService,
    );
    addTearDown(container.dispose);

    final notifier = container.read(bootstrapNotifierProvider.notifier);

    final firstStart = notifier.startBootstrap();
    final secondStart = notifier.startBootstrap();

    expect(container.read(bootstrapNotifierProvider), isA<BootstrapLoading>());
    expect(backendHealthService.callCount, 1);

    healthCheckCompleter.complete(const BackendHealthy());

    await Future.wait<void>([firstStart, secondStart]);

    expect(
      container.read(bootstrapNotifierProvider),
      isA<BootstrapUnauthenticated>(),
    );
    expect(backendHealthService.callCount, 1);
  });

  test('retryBootstrap reruns bootstrap after an error', () async {
    final results = <BackendHealthResult>[
      const BackendUnhealthy(BackendHealthIssue.backendUnavailable),
      const BackendHealthy(),
    ];
    final backendHealthService = CountingBackendHealthService(
      resultFutureFactory: () async => results.removeAt(0),
    );
    final authSessionService = FakeAuthSessionService(
      const UnauthenticatedSession(),
    );
    final container = createContainer(
      backendHealthService: backendHealthService,
      authSessionService: authSessionService,
    );
    addTearDown(container.dispose);

    final notifier = container.read(bootstrapNotifierProvider.notifier);

    await notifier.startBootstrap();

    expect(container.read(bootstrapNotifierProvider), isA<BootstrapError>());
    expect(backendHealthService.callCount, 1);

    await notifier.retryBootstrap();

    expect(
      container.read(bootstrapNotifierProvider),
      isA<BootstrapUnauthenticated>(),
    );
    expect(backendHealthService.callCount, 2);
  });

  test('retryBootstrap is ignored when bootstrap is not in error state', () async {
    final backendHealthService = CountingBackendHealthService(
      resultFutureFactory: () async => const BackendHealthy(),
    );
    final authSessionService = FakeAuthSessionService(
      const UnauthenticatedSession(),
    );
    final container = createContainer(
      backendHealthService: backendHealthService,
      authSessionService: authSessionService,
    );
    addTearDown(container.dispose);

    final notifier = container.read(bootstrapNotifierProvider.notifier);

    await notifier.startBootstrap();
    expect(
      container.read(bootstrapNotifierProvider),
      isA<BootstrapUnauthenticated>(),
    );
    expect(backendHealthService.callCount, 1);

    await notifier.retryBootstrap();

    expect(
      container.read(bootstrapNotifierProvider),
      isA<BootstrapUnauthenticated>(),
    );
    expect(backendHealthService.callCount, 1);
  });
}
