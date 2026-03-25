import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/presentation/supporting/shipping_address_localizations.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ShippingAddressCard extends StatelessWidget {
  const ShippingAddressCard({
    super.key,
    required this.address,
    required this.onTap,
  });

  final ShippingAddress address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.black10,
              width: 1.2,
            ),
            boxShadow: AppShadows.authField,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.fullName,
                              style: AppTextStyles.sectionTitle.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (address.isDefault) _DefaultBadge(label: l10n.shippingAddressesDefaultBadge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(address.street, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 2),
                      Text(address.cityLine, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 2),
                      Text(
                        shippingCountryLabel(l10n, address.countryCode),
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        address.phone,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.black80,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingS),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.black50,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingS,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEE8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
