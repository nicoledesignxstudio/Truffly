import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';

class AuthSuccessDialog extends StatelessWidget {
  const AuthSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black38,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AuthSuccessDialog(
            title: title,
            message: message,
            buttonLabel: buttonLabel,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onPressed();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.spacingL),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadii.dialogBorderRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: AppRadii.circularBorderRadius,
                border: Border.fromBorderSide(
                  BorderSide(color: AppColors.black20),
                ),
                boxShadow: AppShadows.authField,
              ),
              child: const SizedBox(
                height: 40,
                width: 40,
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.authScreenTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            AuthPrimaryButton(
              label: buttonLabel,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
