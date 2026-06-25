import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
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
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: AppColors.black50,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              isItalian
                  ? 'Nessun venditore corrispondente'
                  : 'No matching sellers',
              textAlign: TextAlign.center,
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              showResetAction
                  ? (isItalian
                        ? 'Prova a modificare i filtri per ampliare la ricerca.'
                        : 'Try adjusting the filters to broaden the search.')
                  : (isItalian
                        ? 'I venditori disponibili appariranno qui quando saranno presenti.'
                        : 'Available sellers will appear here when there are any.'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            if (showResetAction) ...[
              const SizedBox(height: AppSpacing.spacingM),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(42),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.spacingS,
                    ),
                  ),
                  onPressed: onReset,
                  child: Text(
                    l10n.sellerResetFilters,
                    style: AppTextStyles.buttonText.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
