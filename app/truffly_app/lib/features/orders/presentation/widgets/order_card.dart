import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.fallbackAssetPath,
    required this.status,
    required this.totalPrice,
    required this.weightGrams,
    required this.createdAt,
    required this.shortReference,
    required this.isSalesScope,
    this.onTap,
  });

  final String title;
  final String? imageUrl;
  final String fallbackAssetPath;
  final OrderStatus status;
  final double totalPrice;
  final int weightGrams;
  final DateTime createdAt;
  final String shortReference;
  final bool isSalesScope;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 136,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _OrderImage(
            imageUrl: imageUrl,
            fallbackAssetPath: fallbackAssetPath,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OrderStatusBadge(
                      status: status,
                      sellerTone: isSalesScope,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${formatEuro(totalPrice)} - ${formatWeightGrams(weightGrams)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatShortDate(context, createdAt)} - $shortReference',
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
    );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: content,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
  }
}

class _OrderImage extends StatelessWidget {
  const _OrderImage({
    required this.imageUrl,
    required this.fallbackAssetPath,
  });

  final String? imageUrl;
  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl == null
        ? _OrderFallbackImage(fallbackAssetPath: fallbackAssetPath)
        : Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _OrderFallbackImage(fallbackAssetPath: fallbackAssetPath);
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

class _OrderFallbackImage extends StatelessWidget {
  const _OrderFallbackImage({required this.fallbackAssetPath});

  final String fallbackAssetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      fallbackAssetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.softGrey,
        child: Center(
          child: Icon(Icons.image_outlined, color: AppColors.black50),
        ),
      ),
    );
  }
}
