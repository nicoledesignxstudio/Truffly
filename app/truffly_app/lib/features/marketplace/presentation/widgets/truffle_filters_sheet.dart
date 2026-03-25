import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/marketplace/domain/truffle_listing_filters.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleFiltersSheet extends StatefulWidget {
  const TruffleFiltersSheet({
    super.key,
    required this.initialFilters,
  });

  final TruffleListingFilters initialFilters;

  @override
  State<TruffleFiltersSheet> createState() => _TruffleFiltersSheetState();
}

class _TruffleFiltersSheetState extends State<TruffleFiltersSheet> {
  late TruffleListingFilters _draft;

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
                        _draft = TruffleListingFilters.defaults().copyWith(
                          selectedType: widget.initialFilters.selectedType,
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
              _SectionTitle(title: l10n.truffleFilterQuality),
              _HorizontalChipList(
                children: [
                  _StyledSheetChip(
                    label: l10n.truffleFilterAll,
                    selected: _draft.qualities.isEmpty,
                    onTap: () => setState(() {
                      _draft = _draft.copyWith(qualities: <TruffleQuality>{});
                    }),
                  ),
                  for (final quality in TruffleQuality.values)
                    _StyledSheetChip(
                      label: quality.choiceLabel(l10n),
                      selected: _draft.qualities.contains(quality),
                      onTap: () => _toggleQuality(quality),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterPriceRange),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.black,
                  inactiveTrackColor: AppColors.softGrey,
                  thumbColor: AppColors.black,
                  overlayColor: AppColors.black10,
                  activeTickMarkColor: AppColors.black,
                  inactiveTickMarkColor: AppColors.softGrey,
                ),
                child: RangeSlider(
                  values: RangeValues(_draft.minPrice, _draft.maxPrice),
                  min: TruffleListingFilterBounds.minPriceEuro,
                  max: TruffleListingFilterBounds.maxPriceEuro,
                  divisions: TruffleListingFilterBounds.priceDivisions,
                  labels: RangeLabels(
                    _draft.minPrice.round().toString(),
                    _draft.maxPrice.round().toString(),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _draft = _draft.copyWith(
                        minPrice: values.start,
                        maxPrice: values.end,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterWeight),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.black,
                  inactiveTrackColor: AppColors.softGrey,
                  thumbColor: AppColors.black,
                  overlayColor: AppColors.black10,
                  activeTickMarkColor: AppColors.black,
                  inactiveTickMarkColor: AppColors.softGrey,
                ),
                child: RangeSlider(
                  values: RangeValues(_draft.minWeight, _draft.maxWeight),
                  min: TruffleListingFilterBounds.minWeightGrams,
                  max: TruffleListingFilterBounds.maxWeightGrams,
                  divisions: TruffleListingFilterBounds.weightDivisions,
                  labels: RangeLabels(
                    _draft.minWeight.round().toString(),
                    _draft.maxWeight.round().toString(),
                  ),
                  onChanged: (values) {
                    setState(() {
                      _draft = _draft.copyWith(
                        minWeight: values.start,
                        maxWeight: values.end,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterHarvestDate),
              _HorizontalChipList(
                children: [
                  for (final preset in HarvestDatePreset.values)
                    _StyledSheetChip(
                      label: _harvestLabel(l10n, preset),
                      selected: _draft.harvestDatePreset == preset,
                      onTap: () {
                        setState(() {
                          _draft = _draft.copyWith(harvestDatePreset: preset);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterRegion),
              _HorizontalChipList(
                children: [
                  _StyledSheetChip(
                    label: l10n.truffleFilterAll,
                    selected: _draft.regions.isEmpty,
                    onTap: () => setState(() {
                      _draft = _draft.copyWith(regions: <String>{});
                    }),
                  ),
                  for (final region in ItalianRegions.values)
                    _StyledSheetChip(
                      label: ItalianRegions.localizedLabel(l10n, region),
                      selected: _draft.regions.contains(region),
                      onTap: () => _toggleRegion(region),
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

  void _toggleQuality(TruffleQuality quality) {
    final next = Set<TruffleQuality>.from(_draft.qualities);
    if (!next.add(quality)) {
      next.remove(quality);
    }

    setState(() {
      _draft = _draft.copyWith(qualities: next);
    });
  }

  void _toggleRegion(String region) {
    final next = Set<String>.from(_draft.regions);
    if (!next.add(region)) {
      next.remove(region);
    }

    setState(() {
      _draft = _draft.copyWith(regions: next);
    });
  }

  String _harvestLabel(AppLocalizations l10n, HarvestDatePreset preset) {
    return switch (preset) {
      HarvestDatePreset.all => l10n.truffleFilterAll,
      HarvestDatePreset.today => l10n.truffleHarvestToday,
      HarvestDatePreset.last2Days => l10n.truffleHarvestLast2Days,
      HarvestDatePreset.last3Days => l10n.truffleHarvestLast3Days,
      HarvestDatePreset.last5Days => l10n.truffleHarvestLast5Days,
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
