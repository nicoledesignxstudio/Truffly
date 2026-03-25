import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_item.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_quality_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerManagedTruffleCard extends StatelessWidget {
  const SellerManagedTruffleCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onDeleteTap,
    this.isDeletePending = false,
  });

  final SellerManagedTruffleItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteTap;
  final bool isDeletePending;

  bool get _isActive => item.status == SellerManagedTruffleStatus.active;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 300, maxHeight: 330),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.black10),
              boxShadow: AppShadows.authField,
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
                        child: _isActive
                            ? DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: AppRadii.circularBorderRadius,
                                  boxShadow: AppShadows.authField,
                                ),
                                child: SizedBox(
                                  height: 43,
                                  width: 43,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: isDeletePending ? null : onDeleteTap,
                                    icon: isDeletePending
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.delete_outline_rounded,
                                            color: AppColors.error,
                                          ),
                                  ),
                                ),
                              )
                            : _StatusPill(status: item.status),
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
                          '${formatShortDate(context, item.harvestDate)} - ${ItalianRegions.localizedLabel(l10n, item.region)}',
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SellerManagedTruffleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, backgroundColor, textColor) = switch (status) {
      SellerManagedTruffleStatus.active => (
          l10n.sellerMyTrufflesTabActive,
          const Color(0xFFFFEEE8),
          AppColors.accent,
        ),
      SellerManagedTruffleStatus.sold => (
          l10n.sellerMyTrufflesTabSold,
          AppColors.black,
          AppColors.white,
        ),
      SellerManagedTruffleStatus.expired => (
          l10n.sellerMyTrufflesTabExpired,
          AppColors.softGrey,
          AppColors.black80,
        ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingXS,
        ),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
