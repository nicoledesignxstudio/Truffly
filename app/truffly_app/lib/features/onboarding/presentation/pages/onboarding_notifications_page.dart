import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_notifier.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingNotificationsPage extends ConsumerStatefulWidget {
  const OnboardingNotificationsPage({super.key});

  @override
  ConsumerState<OnboardingNotificationsPage> createState() =>
      _OnboardingNotificationsPageState();
}

class _OnboardingNotificationsPageState
    extends ConsumerState<OnboardingNotificationsPage> {
  bool _isRequestingPermission = false;
  String? _localPermissionError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final isBusy = onboardingState.isSubmitting || _isRequestingPermission;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextBlock(
                      alignment: Alignment.center,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingNotificationsTitle,
                        style: AppTextStyles.authScreenTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.center,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingNotificationsSubtitle,
                        style: AppTextStyles.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    _NotificationBenefitCard(
                      items: [
                        l10n.onboardingNotificationsBenefitOrderUpdates,
                        l10n.onboardingNotificationsBenefitShippingUpdates,
                        l10n.onboardingNotificationsBenefitSellerApproval,
                        l10n.onboardingNotificationsBenefitPayments,
                      ],
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    _NotificationStatusBanner(state: onboardingState),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthErrorMessage(message: _localPermissionError),
                    if (_localPermissionError != null)
                      const SizedBox(height: AppSpacing.authFieldGap),
                    AuthPrimaryButton(
                      label: l10n.onboardingNotificationsEnableButton,
                      isLoading: _isRequestingPermission,
                      enabled: !isBusy,
                      onPressed: () => _handleEnableNotifications(
                        notifier,
                        l10n,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthSecondaryButton(
                      label: l10n.onboardingNotificationsContinueWithoutButton,
                      enabled: !isBusy,
                      onPressed: () => _handleSkipNotifications(notifier),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.center,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingNotificationsFooter,
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEnableNotifications(
    OnboardingNotifier notifier,
    AppLocalizations l10n,
  ) async {
    if (_isRequestingPermission) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isRequestingPermission = true;
      _localPermissionError = null;
    });

    notifier.setNotificationChoice(OnboardingNotificationChoice.enabled);
    final status = await notifier.requestNotificationPermission();
    if (!mounted) return;

    setState(() {
      _isRequestingPermission = false;
      _localPermissionError = status == null
          ? l10n.onboardingNotificationsPermissionError
          : null;
    });

    if (status != null) {
      notifier.nextStep();
    }
  }

  void _handleSkipNotifications(OnboardingNotifier notifier) {
    if (_isRequestingPermission) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _localPermissionError = null;
    });
    notifier.setNotificationChoice(OnboardingNotificationChoice.skipped);
    notifier.setNotificationPermissionStatus(
      OnboardingNotificationPermissionStatus.denied,
    );
    notifier.nextStep();
  }
}

class _NotificationBenefitCard extends StatelessWidget {
  const _NotificationBenefitCard({
    required this.items,
  });

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (item != items.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationStatusBanner extends StatelessWidget {
  const _NotificationStatusBanner({
    required this.state,
  });

  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final (message, color) = _statusPresentation(
      state.draft.notificationChoice,
      state.draft.notificationPermissionStatus,
      l10n,
      colorScheme,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        textAlign: TextAlign.center,
      ),
    );
  }

  (String, Color) _statusPresentation(
    OnboardingNotificationChoice choice,
    OnboardingNotificationPermissionStatus permissionStatus,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    if (permissionStatus == OnboardingNotificationPermissionStatus.granted) {
      return (
        l10n.onboardingNotificationsStatusGranted,
        colorScheme.primary,
      );
    }

    if (permissionStatus == OnboardingNotificationPermissionStatus.denied) {
      return (
        l10n.onboardingNotificationsStatusDenied,
        colorScheme.error,
      );
    }

    if (choice == OnboardingNotificationChoice.skipped) {
      return (
        l10n.onboardingNotificationsStatusSkipped,
        colorScheme.secondary,
      );
    }

    if (choice == OnboardingNotificationChoice.enabled) {
      return (
        l10n.onboardingNotificationsStatusPending,
        colorScheme.primary,
      );
    }

    return (
      l10n.onboardingNotificationsStatusIdle,
      colorScheme.secondary,
    );
  }
}
