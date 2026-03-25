import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/features/truffle/domain/truffle_seller_preview.dart';

class TruffleSellerPreviewCard extends StatelessWidget {
  const TruffleSellerPreviewCard({
    super.key,
    required this.seller,
    required this.reviewCountLabel,
    required this.onTap,
  });

  final TruffleSellerPreview seller;
  final String reviewCountLabel;
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
              child: Row(
                children: [
                SellerAvatar(
                  imageUrl: seller.profileImageUrl,
                  initials: seller.initials,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seller.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            seller.ratingAverage.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 14,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingXS),
                          Flexible(
                            child: Text(
                              reviewCountLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingS),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.black50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
