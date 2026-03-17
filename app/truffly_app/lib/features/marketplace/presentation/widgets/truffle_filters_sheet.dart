import 'package:flutter/material.dart';
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.spacingM,
          right: AppSpacing.spacingM,
          top: AppSpacing.spacingS,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.spacingM,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _draft = TruffleListingFilters.defaults().copyWith(
                          selectedType: widget.initialFilters.selectedType,
                        );
                      });
                    },
                    child: Text(l10n.truffleFiltersReset),
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
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _SectionTitle(title: l10n.truffleFilterQuality),
              _buildAllToggle(
                label: l10n.truffleFilterAll,
                selected: _draft.qualities.isEmpty,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(qualities: <TruffleQuality>{});
                }),
              ),
              Wrap(
                spacing: AppSpacing.spacingXS,
                runSpacing: AppSpacing.spacingXS,
                children: [
                  for (final quality in TruffleQuality.values)
                    FilterChip(
                      label: Text(quality.localizedLabel(l10n)),
                      selected: _draft.qualities.contains(quality),
                      onSelected: (_) => _toggleQuality(quality),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterPriceRange),
              RangeSlider(
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
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterWeight),
              RangeSlider(
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
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterHarvestDate),
              Wrap(
                spacing: AppSpacing.spacingXS,
                runSpacing: AppSpacing.spacingXS,
                children: [
                  for (final preset in HarvestDatePreset.values)
                    ChoiceChip(
                      label: Text(_harvestLabel(l10n, preset)),
                      selected: _draft.harvestDatePreset == preset,
                      onSelected: (_) {
                        setState(() {
                          _draft = _draft.copyWith(harvestDatePreset: preset);
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _SectionTitle(title: l10n.truffleFilterRegion),
              _buildAllToggle(
                label: l10n.truffleFilterAll,
                selected: _draft.regions.isEmpty,
                onTap: () => setState(() {
                  _draft = _draft.copyWith(regions: <String>{});
                }),
              ),
              Wrap(
                spacing: AppSpacing.spacingXS,
                runSpacing: AppSpacing.spacingXS,
                children: [
                  for (final region in ItalianRegions.values)
                    FilterChip(
                      label: Text(ItalianRegions.localizedLabel(l10n, region)),
                      selected: _draft.regions.contains(region),
                      onSelected: (_) => _toggleRegion(region),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
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

  Widget _buildAllToggle({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingS),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
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
        style: AppTextStyles.cardTitle,
      ),
    );
  }
}
