import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';

class OrderFilterChipGroup extends StatelessWidget {
  const OrderFilterChipGroup({
    super.key,
    required this.selectedFilter,
    required this.onSelected,
  });

  final OrdersFilter selectedFilter;
  final ValueChanged<OrdersFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < OrdersFilter.values.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.spacingXS),
            _FilterChip(
              label: ordersFilterLabel(context, OrdersFilter.values[index]),
              selected: selectedFilter == OrdersFilter.values[index],
              onTap: () => onSelected(OrdersFilter.values[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.black : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(
          color: selected ? AppColors.black : AppColors.black10,
        ),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.authBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM + 2,
              vertical: AppSpacing.spacingS,
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.black80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
