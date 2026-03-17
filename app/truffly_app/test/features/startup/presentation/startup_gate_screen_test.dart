import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/data/auth_session_service.dart';
import 'package:truffly_app/core/bootstrap/data/backend_health_service.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/startup/presentation/startup_gate_screen.dart';

class FakeBackendHealthService extends BackendHealthService {
  int callCount = 0;

  @override
  Future<BackendHealthResult> checkHealth() async {
    callCount += 1;
    return const BackendHealthy();
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
  testWidgets(
    'StartupGateScreen starts bootstrap after the first frame without provider build exception',
    (tester) async {
      final backendHealthService = FakeBackendHealthService();
      final container = ProviderContainer(
        overrides: [
          backendHealthServiceProvider.overrideWithValue(
            backendHealthService,
          ),
          authSessionServiceProvider.overrideWithValue(
            FakeAuthSessionService(const UnauthenticatedSession()),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: StartupGateScreen(),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      await tester.pump();
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        container.read(bootstrapNotifierProvider),
        isA<BootstrapUnauthenticated>(),
      );
      expect(backendHealthService.callCount, 1);
    },
  );

  testWidgets(
    'StartupGateScreen remount with same ProviderContainer does not restart automatic bootstrap',
    (tester) async {
      final backendHealthService = FakeBackendHealthService();
      final container = ProviderContainer(
        overrides: [
          backendHealthServiceProvider.overrideWithValue(
            backendHealthService,
          ),
          authSessionServiceProvider.overrideWithValue(
            FakeAuthSessionService(const UnauthenticatedSession()),
          ),
        ],
      );
      addTearDown(container.dispose);

      Future<void> pumpGate() {
        return tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: StartupGateScreen(),
            ),
          ),
        );
      }

      await pumpGate();
      await tester.pump();
      await tester.pump();

      expect(
        container.read(bootstrapNotifierProvider),
        isA<BootstrapUnauthenticated>(),
      );
      expect(backendHealthService.callCount, 1);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      await pumpGate();
      await tester.pump();
      await tester.pump();

      expect(
        container.read(bootstrapNotifierProvider),
        isA<BootstrapUnauthenticated>(),
      );
      expect(backendHealthService.callCount, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
