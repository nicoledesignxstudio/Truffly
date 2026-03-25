import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_filters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerFiltersSheet extends StatefulWidget {
  const SellerFiltersSheet({
    super.key,
    required this.initialFilters,
  });

  final SellerListingFilters initialFilters;

  @override
  State<SellerFiltersSheet> createState() => _SellerFiltersSheetState();
}

class _SellerFiltersSheetState extends State<SellerFiltersSheet> {
  late SellerListingFilters _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.auth)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.spacingM,
            right: AppSpacing.spacingM,
            top: AppSpacing.spacingM,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spacingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _draft = SellerListingFilters.defaults().copyWith(
                          selectedRegion: widget.initialFilters.selectedRegion,
                        );
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.black80,
                  ),
                  Expanded(
                    child: Text(
                      l10n.truffleFiltersTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.sectionTitle,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.black,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _SectionTitle(title: l10n.sellerFilterRatingTitle),
              _HorizontalChipList(
                children: [
                  for (final option in SellerRatingFilter.values)
                    _StyledSheetChip(
                      label: _ratingLabel(l10n, option),
                      selected: _draft.rating == option,
                      onTap: () {
                        setState(() {
                          _draft = _draft.copyWith(rating: option);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.sellerFilterCompletedOrdersTitle),
              _HorizontalChipList(
                children: [
                  for (final option in SellerCompletedOrdersFilter.values)
                    _StyledSheetChip(
                      label: _completedOrdersLabel(l10n, option),
                      selected: _draft.completedOrders == option,
                      onTap: () {
                        setState(() {
                          _draft = _draft.copyWith(completedOrders: option);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 30),
              AuthPrimaryButton(
                label: l10n.truffleFiltersApply,
                onPressed: () => Navigator.of(context).pop(_draft),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ratingLabel(AppLocalizations l10n, SellerRatingFilter filter) {
    return switch (filter) {
      SellerRatingFilter.any => l10n.truffleFilterAll,
      SellerRatingFilter.threePlus => l10n.sellerFilterRatingThreePlus,
      SellerRatingFilter.fourPlus => l10n.sellerFilterRatingFourPlus,
      SellerRatingFilter.five => l10n.sellerFilterRatingFive,
    };
  }

  String _completedOrdersLabel(
    AppLocalizations l10n,
    SellerCompletedOrdersFilter filter,
  ) {
    return switch (filter) {
      SellerCompletedOrdersFilter.any => l10n.truffleFilterAll,
      SellerCompletedOrdersFilter.fivePlus => l10n.sellerFilterCompletedOrdersFivePlus,
      SellerCompletedOrdersFilter.twentyPlus =>
        l10n.sellerFilterCompletedOrdersTwentyPlus,
      SellerCompletedOrdersFilter.fiftyPlus =>
        l10n.sellerFilterCompletedOrdersFiftyPlus,
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.black,
        ),
      ),
    );
  }
}

class _HorizontalChipList extends StatelessWidget {
  const _HorizontalChipList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.spacingXS),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _StyledSheetChip extends StatelessWidget {
  const _StyledSheetChip({
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
        color: selected ? AppColors.accent : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.black10,
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
