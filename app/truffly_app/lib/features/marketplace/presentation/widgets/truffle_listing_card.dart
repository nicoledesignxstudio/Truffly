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

enum TruffleListingCardVariant { marketplace, home }

class TruffleListingCard extends StatelessWidget {
  const TruffleListingCard({
    super.key,
    this.variant = TruffleListingCardVariant.marketplace,
    required this.item,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.onTap,
    required this.onFavoriteTap,
  });

  static const double _cardRadius = 10;

  final TruffleListingCardVariant variant;
  final TruffleListItem item;
  final bool isFavorite;
  final bool isFavoritePending;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isHome = variant == TruffleListingCardVariant.home;
    final contentPadding = isHome
        ? AppSpacing.spacingXS + 2
        : AppSpacing.spacingXS + 1;
    final favoriteButtonSize = isHome ? 36.0 : 32.0;
    final favoriteIconSize = isHome ? 18.0 : 17.0;
    final titleSize = isHome ? 14.5 : 14.0;
    final metaSize = isHome ? 13.0 : 12.0;
    final priceSize = isHome ? 14.5 : 14.0;
    final titlePriceGap = isHome ? 14.0 : 10.0;
    final imageAspectRatio = isHome ? 1.20 : 1.22;

    return Material(
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
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _CardImage(
                        imageUrl: item.primaryImageUrl,
                        fallbackAssetPath: item.type.guideAssetImagePath,
                      ),
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
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: AppRadii.circularBorderRadius,
                        ),
                        child: SizedBox(
                          height: favoriteButtonSize,
                          width: favoriteButtonSize,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: favoriteIconSize,
                            onPressed: isFavoritePending ? null : onFavoriteTap,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isFavorite
                                  ? AppColors.accent
                                  : AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.type.localizedName(l10n),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.type.latinName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black80,
                        fontSize: metaSize,
                      ),
                    ),
                    SizedBox(height: titlePriceGap),
                    Text(
                      '${formatEuro(item.priceTotal)} - ${formatWeightGrams(item.weightGrams)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardPrice.copyWith(
                        fontSize: priceSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.truffleShippingPlus} - ${ItalianRegions.localizedLabel(l10n, item.region)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black80,
                        fontSize: metaSize,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({required this.imageUrl, required this.fallbackAssetPath});

  final String? imageUrl;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return _FallbackAssetImage(fallbackAssetPath: fallbackAssetPath);
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TruffleListingCard._cardRadius),
      ),
      child: ColoredBox(
        color: AppColors.softGrey,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (context, error, stackTrace) {
            return _FallbackAssetImage(fallbackAssetPath: fallbackAssetPath);
          },
        ),
      ),
    );
  }
}

class _FallbackAssetImage extends StatelessWidget {
  const _FallbackAssetImage({required this.fallbackAssetPath});

  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(TruffleListingCard._cardRadius),
      ),
      child: ColoredBox(
        color: AppColors.softGrey,
        child: Image.asset(
          fallbackAssetPath,
          fit: BoxFit.contain,
          alignment: Alignment.center,
          errorBuilder: (_, _, _) {
            return const Center(
              child: Icon(Icons.image_outlined, color: AppColors.black50),
            );
          },
        ),
      ),
    );
  }
}
