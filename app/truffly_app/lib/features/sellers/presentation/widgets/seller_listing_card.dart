import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/sellers/domain/seller_list_item.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerListingCard extends StatelessWidget {
  const SellerListingCard({
    super.key,
    required this.item,
    required this.onTap,
    this.layout = SellerListingCardLayout.vertical,
  });

  final SellerListItem item;
  final VoidCallback onTap;
  final SellerListingCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final region = item.region?.trim();
    final regionLabel = region == null || region.isEmpty
        ? l10n.sellerRegionUnavailable
        : ItalianRegions.localizedLabel(l10n, region);
    final ratingLabel = item.hasReviews
        ? item.ratingAverage.toStringAsFixed(1)
        : l10n.sellerRatingNew;

    if (layout == SellerListingCardLayout.horizontal) {
      return _HorizontalSellerListingCard(
        item: item,
        onTap: onTap,
        regionLabel: regionLabel,
        ratingLabel: ratingLabel,
      );
    }

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Column(
              children: [
                _SellerAvatar(
                  imageUrl: item.profileImageUrl,
                  initials: item.initials,
                  size: 76,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                Text(
                  item.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  regionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _SellerStatPill(
                        icon: Icons.star_rounded,
                        label: ratingLabel,
                        iconColor: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacingXS),
                    Expanded(
                      child: _SellerStatPill(
                        icon: Icons.inventory_2_rounded,
                        label: item.completedOrdersCount.toString(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum SellerListingCardLayout { vertical, horizontal }

class _HorizontalSellerListingCard extends StatelessWidget {
  const _HorizontalSellerListingCard({
    required this.item,
    required this.onTap,
    required this.regionLabel,
    required this.ratingLabel,
  });

  final SellerListItem item;
  final VoidCallback onTap;
  final String regionLabel;
  final String ratingLabel;

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
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              children: [
                _SellerAvatar(
                  imageUrl: item.profileImageUrl,
                  initials: item.initials,
                  size: 68,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        regionLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      Row(
                        children: [
                          Expanded(
                            child: _SellerStatPill(
                              icon: Icons.star_rounded,
                              label: ratingLabel,
                              iconColor: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingXS),
                          Expanded(
                            child: _SellerStatPill(
                              icon: Icons.inventory_2_rounded,
                              label: item.completedOrdersCount.toString(),
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _SellerAvatar extends StatelessWidget {
  const _SellerAvatar({
    required this.imageUrl,
    required this.initials,
    required this.size,
  });

  final String? imageUrl;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = imageUrl?.trim();
    final url = normalizedImageUrl;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null ||
              url.isEmpty ||
              Uri.tryParse(url)?.hasScheme != true
          ? _SellerAvatarFallback(initials: initials)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _SellerAvatarFallback(initials: initials);
              },
            ),
    );
  }
}

class _SellerAvatarFallback extends StatelessWidget {
  const _SellerAvatarFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.sectionTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SellerStatPill extends StatelessWidget {
  const _SellerStatPill({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.black80,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingXS,
          vertical: AppSpacing.spacingXS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
