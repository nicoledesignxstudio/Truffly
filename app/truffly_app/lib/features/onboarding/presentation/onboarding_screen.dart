import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_notifier.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_flow_screen.dart';
import 'package:truffly_app/features/onboarding/presentation/onboarding_role_selection_screen.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  bool _allowExitOnce = false;

  @override
  void initState() {
    super.initState();
    _resetFlowForFreshOnboarding(ref.read(authNotifierProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return PopScope(
      canPop: _allowExitOnce && !onboardingState.hasSelectedPath,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation(
          onboardingState: onboardingState,
          notifier: notifier,
          l10n: l10n,
        );
      },
      child: Scaffold(
        body: SafeArea(
          child: onboardingState.hasSelectedPath
              ? OnboardingFlowScreen(
                  key: ValueKey(onboardingState.path),
                )
              : const OnboardingRoleSelectionScreen(),
        ),
      ),
    );
  }

  Future<void> _handleBackNavigation({
    required OnboardingState onboardingState,
    required OnboardingNotifier notifier,
    required AppLocalizations l10n,
  }) async {
    if (_allowExitOnce) return;

    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
      return;
    }

    if (onboardingState.hasSelectedPath) {
      if (onboardingState.currentStepIndex > 0) {
        notifier.previousStep();
      } else {
        notifier.resetFlow();
      }
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.onboardingExitTitle),
          content: Text(l10n.onboardingExitMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.onboardingExitStayButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.onboardingExitLeaveButton),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldExit != true) return;

    setState(() {
      _allowExitOnce = true;
    });

    Navigator.of(context).maybePop();
  }

  void _resetFlowForFreshOnboarding(AuthState authState) {
    if (authState is! AuthAuthenticatedOnboardingRequired) {
      return;
    }

    final onboardingState = ref.read(onboardingNotifierProvider);
    if (!onboardingState.hasSelectedPath &&
        onboardingState.currentStepIndex == 0 &&
        !onboardingState.hasSteps) {
      return;
    }

    ref.read(onboardingNotifierProvider.notifier).resetFlow();
  }
}
