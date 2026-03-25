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
  });

  final SellerListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final regionLabel = item.region == null || item.region!.isEmpty
        ? l10n.sellerRegionUnavailable
        : ItalianRegions.localizedLabel(l10n, item.region!);
    final ratingLabel = item.hasReviews
        ? item.ratingAverage.toStringAsFixed(1)
        : l10n.sellerRatingNew;

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
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  regionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.black80,
                  ),
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
    final canUseImage = normalizedImageUrl != null &&
        normalizedImageUrl.isNotEmpty &&
        Uri.tryParse(normalizedImageUrl)?.hasScheme == true;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: canUseImage
          ? Image.network(
              normalizedImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _SellerAvatarFallback(initials: initials);
              },
            )
          : _SellerAvatarFallback(initials: initials),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
