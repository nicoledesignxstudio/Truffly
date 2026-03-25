import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_quality_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleListingCard extends StatelessWidget {
  const TruffleListingCard({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.onTap,
    required this.onFavoriteTap,
  });

  static const double _cardRadius = 10;
  static const double _favoriteButtonSize = 43;

  final TruffleListItem item;
  final bool isFavorite;
  final bool isFavoritePending;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 300, maxHeight: 330),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(_cardRadius),
              border: Border.all(color: AppColors.black10),
              boxShadow: AppShadows.truffleCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _CardImage(imageUrl: item.primaryImageUrl),
                      ),
                      Positioned(
                        top: AppSpacing.spacingS,
                        left: AppSpacing.spacingS,
                        child: TruffleQualityBadge(quality: item.quality),
                      ),
                      Positioned(
                        right: AppSpacing.spacingS,
                        bottom: AppSpacing.spacingS,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: AppRadii.circularBorderRadius,
                            boxShadow: AppShadows.authField,
                          ),
                          child: SizedBox(
                            height: _favoriteButtonSize,
                            width: _favoriteButtonSize,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              onPressed: isFavoritePending ? null : onFavoriteTap,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite ? AppColors.accent : AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.type.localizedName(l10n),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.type.latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${formatEuro(item.priceTotal)} - ${formatWeightGrams(item.weightGrams)}',
                          style: AppTextStyles.cardPrice.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${l10n.truffleShippingPlus} - ${ItalianRegions.localizedLabel(l10n, item.region)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TruffleListingCard._cardRadius),
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            color: AppColors.black50,
            size: 30,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TruffleListingCard._cardRadius),
      ),
      child: Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.softGrey,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.black50,
              ),
            ),
          );
        },
      ),
    );
  }
}
