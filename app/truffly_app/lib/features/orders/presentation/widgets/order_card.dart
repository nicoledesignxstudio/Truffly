import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/orders/domain/order_summary.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.isSalesScope,
    required this.onTap,
  });

  final OrderSummary order;
  final bool isSalesScope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
          child: SizedBox(
            height: 136,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderImage(imageUrl: order.primaryImageUrl),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                order.type.localizedName(l10n),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spacingS),
                            OrderStatusBadge(
                              status: order.status,
                              sellerTone: isSalesScope,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.type.latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${formatEuro(order.totalPrice)} - ${formatWeightGrams(order.weightGrams)}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatShortDate(context, order.createdAt)} - ${order.shortReference()}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.micro.copyWith(
                            color: AppColors.black50,
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

class _OrderImage extends StatelessWidget {
  const _OrderImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl == null
        ? const ColoredBox(
            color: AppColors.softGrey,
            child: Center(
              child: Icon(Icons.image_outlined, color: AppColors.black50),
            ),
          )
        : Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: AppColors.softGrey,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.black50,
                  ),
                ),
              );
            },
          );

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
      child: SizedBox(
        width: 122,
        child: child,
      ),
    );
  }
}
