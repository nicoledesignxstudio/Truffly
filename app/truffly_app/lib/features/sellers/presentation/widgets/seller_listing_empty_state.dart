import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerListingEmptyState extends StatelessWidget {
  const SellerListingEmptyState({
    super.key,
    required this.showResetAction,
    required this.onReset,
  });

  final bool showResetAction;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_alt_outlined,
              size: 48,
              color: AppColors.black50,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              showResetAction
                  ? l10n.sellerEmptyFilteredTitle
                  : l10n.sellerEmptyTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              showResetAction
                  ? l10n.sellerEmptyFilteredSubtitle
                  : l10n.sellerEmptySubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            if (showResetAction) ...[
              const SizedBox(height: AppSpacing.spacingM),
              AuthPrimaryButton(
                label: l10n.sellerResetFilters,
                onPressed: onReset,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
