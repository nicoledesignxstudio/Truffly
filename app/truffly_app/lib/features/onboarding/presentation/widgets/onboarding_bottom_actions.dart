import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';

class OnboardingBottomActions extends StatelessWidget {
  const OnboardingBottomActions({
    super.key,
    required this.backLabel,
    required this.primaryLabel,
    required this.onPrimaryPressed,
    this.onBackPressed,
    this.isLoading = false,
    this.isPrimaryEnabled = true,
    this.isBackEnabled = true,
    this.isBackVisible = true,
  });

  final String backLabel;
  final String primaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onBackPressed;
  final bool isLoading;
  final bool isPrimaryEnabled;
  final bool isBackEnabled;
  final bool isBackVisible;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthPrimaryButton(
          label: primaryLabel,
          onPressed: onPrimaryPressed,
          isLoading: isLoading,
          enabled: isPrimaryEnabled,
        ),
        if (isBackVisible) ...[
          const SizedBox(height: AppSpacing.authFieldGap),
          AuthSecondaryButton(
            label: backLabel,
            onPressed: onBackPressed,
            enabled: !isLoading && isBackEnabled,
          ),
        ],
      ],
    );
  }
}
