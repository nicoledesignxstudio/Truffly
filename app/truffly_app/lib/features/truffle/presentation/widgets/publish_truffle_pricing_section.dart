import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';

class PublishTrufflePricingSection extends StatelessWidget {
  const PublishTrufflePricingSection({
    super.key,
    required this.weightController,
    required this.totalPriceController,
    required this.shippingItalyController,
    required this.shippingAbroadController,
    required this.weightLabel,
    required this.totalPriceLabel,
    required this.shippingItalyLabel,
    required this.shippingAbroadLabel,
    required this.shippingTitle,
    required this.previewLabel,
    required this.previewValue,
    required this.onWeightChanged,
    required this.onTotalPriceChanged,
    required this.onShippingItalyChanged,
    required this.onShippingAbroadChanged,
    this.weightErrorText,
    this.totalPriceErrorText,
    this.shippingItalyErrorText,
    this.shippingAbroadErrorText,
  });

  final TextEditingController weightController;
  final TextEditingController totalPriceController;
  final TextEditingController shippingItalyController;
  final TextEditingController shippingAbroadController;
  final String weightLabel;
  final String totalPriceLabel;
  final String shippingItalyLabel;
  final String shippingAbroadLabel;
  final String shippingTitle;
  final String previewLabel;
  final String previewValue;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onTotalPriceChanged;
  final ValueChanged<String> onShippingItalyChanged;
  final ValueChanged<String> onShippingAbroadChanged;
  final String? weightErrorText;
  final String? totalPriceErrorText;
  final String? shippingItalyErrorText;
  final String? shippingAbroadErrorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthTextField(
          controller: weightController,
          labelText: weightLabel,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: onWeightChanged,
          errorText: weightErrorText,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        AuthTextField(
          controller: totalPriceController,
          labelText: totalPriceLabel,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: onTotalPriceChanged,
          errorText: totalPriceErrorText,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.softGrey,
            borderRadius: BorderRadius.circular(AppRadii.dialog),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    previewLabel,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
                Text(
                  previewValue,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingL),
        Text(
          shippingTitle,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.spacingS),
        AuthTextField(
          controller: shippingItalyController,
          labelText: shippingItalyLabel,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: onShippingItalyChanged,
          errorText: shippingItalyErrorText,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        AuthTextField(
          controller: shippingAbroadController,
          labelText: shippingAbroadLabel,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: onShippingAbroadChanged,
          errorText: shippingAbroadErrorText,
        ),
      ],
    );
  }
}
