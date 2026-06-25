import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';

class TruffleQualityBadge extends StatelessWidget {
  const TruffleQualityBadge({
    super.key,
    required this.quality,
    this.backgroundColor = AppColors.black,
    this.textColor = AppColors.white,
  });

  final TruffleQuality quality;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingXS,
          vertical: AppSpacing.spacingXXS + 1,
        ),
        child: Text(
          quality.badgeLabel,
          style: AppTextStyles.micro.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
