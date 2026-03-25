import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.sellerTone = false,
    this.showConfirmationIcon = true,
  });

  final OrderStatus status;
  final bool sellerTone;
  final bool showConfirmationIcon;

  @override
  Widget build(BuildContext context) {
    final palette = switch (status) {
      OrderStatus.paid => (const Color(0xFFFFEEE8), AppColors.accent),
      OrderStatus.shipped => (const Color(0xFFF3F4F6), AppColors.black),
      OrderStatus.completed => (
        const Color(0xFFEAF7EF),
        const Color(0xFF216E39),
      ),
      OrderStatus.cancelled => (const Color(0xFFFCEBEC), AppColors.error),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == OrderStatus.completed && showConfirmationIcon) ...[
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: palette.$2,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              orderStatusLabel(context, status, sellerTone: sellerTone),
              style: AppTextStyles.micro.copyWith(
                color: palette.$2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
