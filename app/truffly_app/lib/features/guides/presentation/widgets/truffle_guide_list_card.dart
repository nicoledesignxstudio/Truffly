import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/guides/domain/truffle_guide.dart';

class TruffleGuideListCard extends StatelessWidget {
  const TruffleGuideListCard({
    super.key,
    required this.guide,
    required this.localeCode,
    required this.imageAssetPath,
    required this.onTap,
  });

  final TruffleGuide guide;
  final String localeCode;
  final String imageAssetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingS),
            child: SizedBox(
              height: 112,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 104,
                      child: Image.asset(
                        imageAssetPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, _, _) => const DecoratedBox(
                          decoration: BoxDecoration(color: AppColors.softGrey),
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          guide.titleForLocale(localeCode),
                          style: AppTextStyles.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.latinName,
                          style: AppTextStyles.cardSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.spacingXS),
                        _RarityStars(rarity: guide.rarity),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingXS),
                  const Center(
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.black50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RarityStars extends StatelessWidget {
  const _RarityStars({required this.rarity});

  final int rarity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < 5; index++) ...[
          Icon(
            index < rarity ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: index < rarity ? AppColors.accent : AppColors.black20,
          ),
          if (index < 4) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
