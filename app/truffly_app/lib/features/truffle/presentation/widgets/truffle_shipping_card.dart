import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';

class TruffleShippingCard extends StatelessWidget {
  const TruffleShippingCard({
    super.key,
    required this.title,
    required this.italyLabel,
    required this.abroadLabel,
    required this.shippingPriceItaly,
    required this.shippingPriceAbroad,
  });

  final String title;
  final String italyLabel;
  final String abroadLabel;
  final double shippingPriceItaly;
  final double shippingPriceAbroad;

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
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            _ShippingRow(
              label: italyLabel,
              value: formatEuro(shippingPriceItaly),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            _ShippingRow(
              label: abroadLabel,
              value: formatEuro(shippingPriceAbroad),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShippingRow extends StatelessWidget {
  const _ShippingRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacingS),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
