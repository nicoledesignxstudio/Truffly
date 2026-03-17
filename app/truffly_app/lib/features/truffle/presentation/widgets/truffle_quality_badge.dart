import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleQualityBadge extends StatelessWidget {
  const TruffleQualityBadge({
    super.key,
    required this.quality,
  });

  final TruffleQuality quality;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadii.auth),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: 6,
        ),
        child: Text(
          quality.localizedLabel(l10n),
          style: AppTextStyles.micro.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
