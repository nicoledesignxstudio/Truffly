import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';

class ListingFilterButton extends StatelessWidget {
  const ListingFilterButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
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
