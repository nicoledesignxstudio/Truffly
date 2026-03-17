import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: AppRadii.circularBorderRadius,
          boxShadow: AppShadows.authField,
        ),
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 24,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}
