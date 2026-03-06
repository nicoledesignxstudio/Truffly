import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/auth/presentation/login_screen.dart';
import 'package:truffly_app/features/home/presentation/home_screen.dart';
import 'package:truffly_app/features/startup/presentation/startup_gate_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable();
  ref.onDispose(refreshListenable.dispose);

  ref.listen<BootstrapState>(bootstrapNotifierProvider, (previous, next) {
    refreshListenable.refresh();
  });

  return GoRouter(
    initialLocation: AppRoutes.startup,
    refreshListenable: refreshListenable,
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    redirect: (_, state) {
      final bootstrapState = ref.read(bootstrapNotifierProvider);
      final location = state.matchedLocation;

      final isStartup = location == AppRoutes.startup;
      final isLogin = location == AppRoutes.login;
      final isHome = location == AppRoutes.home;

      return switch (bootstrapState) {
        BootstrapInitial() || BootstrapLoading() || BootstrapError() =>
          isStartup ? null : AppRoutes.startup,
        BootstrapAuthenticated() => isHome ? null : AppRoutes.home,
        BootstrapUnauthenticated() => isLogin ? null : AppRoutes.login,
      };
    },
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}
