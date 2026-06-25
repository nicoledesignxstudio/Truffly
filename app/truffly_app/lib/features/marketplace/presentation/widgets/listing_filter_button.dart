import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class ListingFilterButton extends StatelessWidget {
  const ListingFilterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.authControlHeight,
      width: AppSpacing.authControlHeight,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.authBorderRadius,
          border: Border.fromBorderSide(BorderSide(color: AppColors.black10)),
          boxShadow: AppShadows.authField,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.tune_rounded),
        ),
      ),
    );
  }
}
