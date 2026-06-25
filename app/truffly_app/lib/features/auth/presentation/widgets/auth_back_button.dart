import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.circularIconButtonSize,
      width: AppSpacing.circularIconButtonSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.softGrey,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: AppSpacing.circularIconSize,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
