import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/guides/application/truffle_guides_providers.dart';
import 'package:truffly_app/features/guides/domain/harvest_period_formatter.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleGuideDetailPage extends ConsumerWidget {
  const TruffleGuideDetailPage({super.key, required this.truffleType});

  final TruffleType truffleType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode == 'en'
        ? 'en'
        : 'it';
    final guideAsync = ref.watch(truffleGuideDetailProvider(truffleType));

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.guide),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.guides);
              }
            },
          ),
        ),
        title: Text(
          l10n.guidesPageTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: guideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _DetailMessage(text: l10n.guidesLoadError),
        data: (guide) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              AppSpacing.spacingS,
              AppSpacing.spacingM,
              AppSpacing.spacingL,
            ),
            children: [
              _GuideHeroImage(
                imageAssetPath: guide.truffleType.guideAssetImagePath,
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _RarityStars(rarity: guide.rarity),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                guide.titleForLocale(localeCode),
                style: AppTextStyles.authScreenTitle.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXXS),
              Text(guide.latinName, style: AppTextStyles.cardSubtitle),
              const SizedBox(height: AppSpacing.spacingL),
              Row(
                children: [
                  Expanded(
                    child: _GuideMetricBox(
                      icon: Icons.star_outline_rounded,
                      value: '${guide.rarity}',
                      label: l10n.guidesTruffleQualityMetric,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingXS),
                  Expanded(
                    flex: 2,
                    child: _GuideMetricBox(
                      icon: Icons.balance_rounded,
                      value:
                          '${guide.priceMinEur} - ${guide.priceMaxEur} EUR/Kg',
                      label: l10n.guidesPriceRangeMetric,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _ActionCard(
                title: l10n.guidesDescription,
                onTap: () => _showContentSheet(
                  context,
                  title: l10n.guidesDescription,
                  child: Text(
                    guide.descriptionForLocale(localeCode),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _ActionCard(
                title: l10n.guidesAroma,
                onTap: () => _showContentSheet(
                  context,
                  title: l10n.guidesAroma,
                  child: Text(
                    guide.aromaForLocale(localeCode),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black80,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _SectionCard(
                title: l10n.guidesSymbioticPlants,
                child: Wrap(
                  spacing: AppSpacing.spacingXS,
                  runSpacing: AppSpacing.spacingXS,
                  children: [
                    for (final plant in guide.symbioticPlantsForLocale(
                      localeCode,
                    ))
                      _Chip(text: plant),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _SectionCard(
                title: l10n.guidesHarvestPeriod,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: AppColors.black80,
                    ),
                    const SizedBox(width: AppSpacing.spacingXS),
                    Expanded(
                      child: Text(
                        formatHarvestPeriod(
                          startMonth: guide.harvestStartMonth,
                          endMonth: guide.harvestEndMonth,
                          localeCode: localeCode,
                        ),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _ActionCard(
                title: l10n.guidesSoil,
                subtitle: l10n.guidesSoilHelper,
                onTap: () => _showContentSheet(
                  context,
                  title: l10n.guidesSoil,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BottomSheetSection(
                        title: l10n.guidesSoilComposition,
                        child: Text(
                          guide.soilCompositionForLocale(localeCode),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ),
                      _BottomSheetSection(
                        title: l10n.guidesSoilStructure,
                        child: Text(
                          guide.soilStructureForLocale(localeCode),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ),
                      _BottomSheetSection(
                        title: l10n.guidesSoilPh,
                        child: Text(
                          guide.soilPhForLocale(localeCode),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ),
                      _BottomSheetSection(
                        title: l10n.guidesSoilAltitude,
                        child: Text(
                          guide.soilAltitudeForLocale(localeCode),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ),
                      _BottomSheetSection(
                        title: l10n.guidesSoilHumidity,
                        child: Text(
                          guide.soilHumidityForLocale(localeCode),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showContentSheet(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingM + 20,
            AppSpacing.spacingM,
            AppSpacing.spacingL + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacingS),
                child,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

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
            Text(title, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.spacingXS),
            child,
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingXXS,
        ),
        child: Text(text, style: AppTextStyles.micro),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.onTap, this.subtitle});

  final String title;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.cardTitle),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.spacingXXS),
                        Text(
                          subtitle!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.black80,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingS),
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.black50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomSheetSection extends StatelessWidget {
  const _BottomSheetSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
          const SizedBox(height: AppSpacing.spacingXS),
          child,
        ],
      ),
    );
  }
}

class _GuideHeroImage extends StatelessWidget {
  const _GuideHeroImage({required this.imageAssetPath});

  final String imageAssetPath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 300,
        width: double.infinity,
        child: Image.asset(
          imageAssetPath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.softGrey,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.black50,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RarityStars extends StatelessWidget {
  const _RarityStars({required this.rarity});

  final int rarity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < 5; index++) ...[
          Icon(
            index < rarity ? Icons.star_rounded : Icons.star_border_rounded,
            size: 22,
            color: AppColors.accent,
          ),
          if (index < 4) const SizedBox(width: 2),
        ],
      ],
    );
  }
}

class _GuideMetricBox extends StatelessWidget {
  const _GuideMetricBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.white),
            const SizedBox(height: 20),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardPrice.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXXS),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.86),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
