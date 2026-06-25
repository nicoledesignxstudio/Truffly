import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';

class DestructiveConfirmationDialog extends StatelessWidget {
  const DestructiveConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(AppSpacing.spacingM),
      titlePadding: const EdgeInsets.fromLTRB(
        AppSpacing.spacingM,
        30,
        AppSpacing.spacingM,
        8,
      ),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.spacingM,
        0,
        AppSpacing.spacingM,
        20,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.spacingM,
        0,
        AppSpacing.spacingM,
        30,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTextStyles.cardTitle.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.black80,
        ),
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthPrimaryButton(
              label: confirmLabel,
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            AuthSecondaryButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    );
  }
}
