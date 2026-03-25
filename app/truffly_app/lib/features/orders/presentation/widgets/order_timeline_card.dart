import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_section_card.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_status_badge.dart';

class OrderTimelineCard extends StatelessWidget {
  const OrderTimelineCard({
    super.key,
    required this.status,
    required this.isSellerView,
  });

  final OrderStatus status;
  final bool isSellerView;

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return OrderSectionCard(
        title: timelineTitle(context),
        trailing: const OrderStatusBadge(status: OrderStatus.cancelled),
        child: Text(
          orderStatusDescription(context, status, isSellerView: isSellerView),
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final currentIndex = switch (status) {
      OrderStatus.paid => 0,
      OrderStatus.shipped => 1,
      OrderStatus.completed => 2,
      OrderStatus.cancelled => 0,
    };

    final steps = [
      (timelineStepConfirmed(context), Icons.check_circle_outline_rounded),
      (timelineStepShipped(context), Icons.local_shipping_outlined),
      (timelineStepCompleted(context), Icons.inventory_2_outlined),
    ];

    return OrderSectionCard(
      title: timelineTitle(context),
      trailing: OrderStatusBadge(
        status: status,
        sellerTone: isSellerView,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderStatusDescription(context, status, isSellerView: isSellerView),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColors.black80,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          for (var index = 0; index < steps.length; index++)
            _TimelineRow(
              label: steps[index].$1,
              icon: steps[index].$2,
              isReached: index < currentIndex,
              isCurrent: index == currentIndex,
              showLine: index != steps.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.icon,
    required this.isReached,
    required this.isCurrent,
    required this.showLine,
  });

  final String label;
  final IconData icon;
  final bool isReached;
  final bool isCurrent;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final lineColor = (isReached || isCurrent)
        ? AppColors.accent
        : AppColors.black20;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isReached
                        ? AppColors.accent
                        : isCurrent
                        ? const Color(0xFFFFEEE8)
                        : AppColors.softGrey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isReached
                          ? AppColors.accent
                          : isCurrent
                          ? AppColors.accent
                          : AppColors.black20,
                    ),
                  ),
                  child: Icon(
                    isReached ? Icons.check_rounded : icon,
                    size: 20,
                    color: isReached
                        ? AppColors.white
                        : isCurrent
                        ? AppColors.accent
                        : AppColors.black50,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 7,
                bottom: AppSpacing.spacingM,
              ),
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isCurrent || isReached
                      ? AppColors.black
                      : AppColors.black50,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
