import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/bootstrap/data/auth_session_service.dart';
import 'package:truffly_app/core/bootstrap/data/backend_health_service.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_failure.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';

final bootstrapNotifierProvider =
    NotifierProvider<BootstrapNotifier, BootstrapState>(
  BootstrapNotifier.new,
);

class BootstrapNotifier extends Notifier<BootstrapState> {
  @override
  BootstrapState build() {
    return const BootstrapInitial();
  }

  Future<void> startBootstrap() async {
    if (state is BootstrapLoading) return;
    if (state is! BootstrapInitial) return;
    await _runBootstrapChecks();
  }

  Future<void> retryBootstrap() async {
    if (state is BootstrapLoading) return;
    await _runBootstrapChecks();
  }

  Future<void> _runBootstrapChecks() async {
    state = const BootstrapLoading();
    debugPrint('[BOOTSTRAP] Starting checks');

    try {
      final healthResult = await ref.read(backendHealthServiceProvider).checkHealth();
      switch (healthResult) {
        case BackendHealthy():
          debugPrint('[BOOTSTRAP] Backend reachable');
          break;
        case BackendUnhealthy(:final issue):
          debugPrint('[BOOTSTRAP] Health check failed: $issue');
          state = BootstrapError(_mapHealthIssueToFailure(issue));
          return;
      }

      final sessionResult = ref.read(authSessionServiceProvider).getSessionStatus();
      switch (sessionResult) {
        case AuthenticatedSession():
          debugPrint('[BOOTSTRAP] Session found');
          state = const BootstrapAuthenticated();
        case UnauthenticatedSession():
          debugPrint('[BOOTSTRAP] No active session');
          state = const BootstrapUnauthenticated();
        case InvalidSession():
          debugPrint('[BOOTSTRAP] Invalid session');
          state = const BootstrapError(InvalidSessionFailure());
      }
    } catch (error) {
      debugPrint('[BOOTSTRAP] Health check failed: $error');
      state = const BootstrapError(UnknownBootstrapFailure());
    }
  }

  BootstrapFailure _mapHealthIssueToFailure(BackendHealthIssue issue) {
    return switch (issue) {
      BackendHealthIssue.backendUnavailable => const BackendUnavailableFailure(),
      BackendHealthIssue.timeout => const NetworkTimeoutFailure(),
      BackendHealthIssue.network => const NetworkFailure(),
      BackendHealthIssue.config => const ConfigFailure(),
      BackendHealthIssue.unknown => const UnknownBootstrapFailure(),
    };
  }
}
