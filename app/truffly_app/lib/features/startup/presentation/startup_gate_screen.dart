import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/bootstrap/application/bootstrap_notifier.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_state.dart';
import 'package:truffly_app/features/startup/presentation/startup_error_screen.dart';
import 'package:truffly_app/features/startup/presentation/startup_loading_screen.dart';

class StartupGateScreen extends ConsumerStatefulWidget {
  const StartupGateScreen({super.key});

  @override
  ConsumerState<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends ConsumerState<StartupGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(bootstrapNotifierProvider.notifier).startBootstrap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bootstrapNotifierProvider);

    return switch (state) {
      BootstrapError(:final failure) => StartupErrorScreen(
          failure: failure,
          onRetry: () {
            ref.read(bootstrapNotifierProvider.notifier).retryBootstrap();
          },
        ),
      _ => const StartupLoadingScreen(),
    };
  }
}
