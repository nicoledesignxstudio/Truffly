import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';

class TruffleStickyBuyBar extends StatelessWidget {
  const TruffleStickyBuyBar({
    super.key,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: AppShadows.authField,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingM,
          ),
          child: AuthPrimaryButton(
            label: buttonLabel,
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
