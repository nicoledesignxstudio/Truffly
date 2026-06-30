import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_notifier.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/features/push/application/push_token_service_provider.dart';
import 'package:truffly_app/features/push/data/push_token_service.dart';
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
    final copy = _NotificationCopy.fromState(l10n, onboardingState);
    final isBusy = onboardingState.isSubmitting || _isRequestingPermission;
    final languageCode = Localizations.localeOf(context).languageCode;
    final imageAsset = languageCode == 'it'
        ? 'assets/images/onboarding/notification_it.webp'
        : 'assets/images/onboarding/notification_en.webp';

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NotificationIllustration(assetPath: imageAsset),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Text(
                      copy.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.authScreenTitle,
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    Text(
                      copy.subtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.black80,
                      ),
                    ),
                    const Spacer(),
                    if (_localPermissionError != null) ...[
                      AuthErrorMessage(message: _localPermissionError),
                      const SizedBox(height: AppSpacing.authFieldGap),
                    ],
                    if (onboardingState
                            .draft
                            .hasRequestedNotificationPermission ||
                        _localPermissionError != null) ...[
                      _NotificationStatusBanner(state: onboardingState),
                      const SizedBox(height: AppSpacing.authFieldGap),
                    ],
                    AuthPrimaryButton(
                      label: l10n.onboardingNotificationsEnableButton,
                      isLoading: _isRequestingPermission,
                      enabled: !isBusy,
                      onPressed: () =>
                          _handleEnableNotifications(notifier, l10n),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: isBusy
                            ? null
                            : () => _handleSkipNotifications(notifier),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.black80,
                          disabledForegroundColor: AppColors.black50,
                          textStyle: AppTextStyles.micro.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        child: Text(
                          l10n.onboardingNotificationsContinueWithoutButton,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    final enableResult = await ref
        .read(pushTokenServiceProvider)
        .enableCurrentDeviceNotifications();
    if (!mounted) return;

    final status = enableResult.isEnabled
        ? OnboardingNotificationPermissionStatus.granted
        : OnboardingNotificationPermissionStatus.denied;
    notifier.setNotificationPermissionStatus(status);

    setState(() {
      _isRequestingPermission = false;
      _localPermissionError = _messageForEnableResult(enableResult, l10n);
    });

    if (enableResult.isEnabled) {
      notifier.nextStep();
    }
  }

  String? _messageForEnableResult(
    NotificationEnableResult result,
    AppLocalizations l10n,
  ) {
    return switch (result.status) {
      NotificationEnableStatus.enabled => null,
      NotificationEnableStatus.systemNotificationsDisabled =>
        l10n.notificationsOpenSystemSettingsMessage,
      NotificationEnableStatus.noActiveUser ||
      NotificationEnableStatus.tokenMissing ||
      NotificationEnableStatus.unsupportedPlatform ||
      NotificationEnableStatus.failed =>
        l10n.onboardingNotificationsPermissionError,
    };
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

final class _NotificationCopy {
  const _NotificationCopy({required this.title, required this.subtitle});

  factory _NotificationCopy.fromState(
    AppLocalizations l10n,
    OnboardingState state,
  ) {
    if (state.isSellerFlow) {
      return _NotificationCopy(
        title: l10n.onboardingNotificationsSellerTitle,
        subtitle: l10n.onboardingNotificationsSellerSubtitle,
      );
    }

    return _NotificationCopy(
      title: l10n.onboardingNotificationsBuyerTitle,
      subtitle: l10n.onboardingNotificationsBuyerSubtitle,
    );
  }

  final String title;
  final String subtitle;
}

class _NotificationIllustration extends StatelessWidget {
  const _NotificationIllustration({required this.assetPath});

  final String assetPath;
  static const BorderRadius _borderRadius = BorderRadius.all(
    Radius.circular(22),
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: _borderRadius,
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: Image.asset(
          assetPath,
          width: double.infinity,
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: AppColors.softGrey,
              child: SizedBox(
                height: 220,
                child: Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 72,
                    color: AppColors.accent,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationStatusBanner extends StatelessWidget {
  const _NotificationStatusBanner({required this.state});

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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
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
      return (l10n.onboardingNotificationsStatusGranted, colorScheme.primary);
    }

    if (permissionStatus ==
        OnboardingNotificationPermissionStatus.provisional) {
      return (
        l10n.onboardingNotificationsStatusProvisional,
        colorScheme.primary,
      );
    }

    if (permissionStatus ==
        OnboardingNotificationPermissionStatus.notDetermined) {
      return (
        l10n.onboardingNotificationsStatusNotDetermined,
        colorScheme.secondary,
      );
    }

    if (permissionStatus == OnboardingNotificationPermissionStatus.denied) {
      return (l10n.onboardingNotificationsStatusDenied, colorScheme.error);
    }

    if (choice == OnboardingNotificationChoice.skipped) {
      return (l10n.onboardingNotificationsStatusSkipped, colorScheme.secondary);
    }

    if (choice == OnboardingNotificationChoice.enabled) {
      return (l10n.onboardingNotificationsStatusPending, colorScheme.primary);
    }

    return (l10n.onboardingNotificationsStatusIdle, colorScheme.secondary);
  }
}
