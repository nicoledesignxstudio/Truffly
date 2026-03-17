import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_quality_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleDetailPage extends ConsumerWidget {
  const TruffleDetailPage({
    super.key,
    required this.truffleId,
  });

  final String truffleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(truffleDetailProvider(truffleId));
    final favoriteState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: Text(
          l10n.truffleDetailTitle,
          style: AppTextStyles.sectionTitle,
        ),
      ),
      body: detailAsync.when(
        data: (detail) {
          final isFavorite = favoriteState.ids.contains(detail.id);
          final isPending = favoriteState.pendingIds.contains(detail.id);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              AppSpacing.spacingS,
              AppSpacing.spacingM,
              AppSpacing.spacingL,
            ),
            children: [
              SizedBox(
                height: 280,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _DetailImages(imageUrls: detail.imageUrls),
                    ),
                    Positioned(
                      top: AppSpacing.spacingM,
                      left: AppSpacing.spacingM,
                      child: TruffleQualityBadge(quality: detail.quality),
                    ),
                    Positioned(
                      right: AppSpacing.spacingM,
                      top: AppSpacing.spacingM,
                      child: IconButton.filledTonal(
                        onPressed: isPending
                            ? null
                            : () => favoriteNotifier.toggleFavorite(detail.id),
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite ? AppColors.accent : AppColors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingL),
              Text(
                detail.type.localizedName(l10n),
                style: AppTextStyles.authScreenTitle.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                detail.type.latinName,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.spacingL),
              Text(
                '${formatEuro(detail.priceTotal)} | ${formatWeightGrams(detail.weightGrams)}',
                style: AppTextStyles.cardPrice.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                '${l10n.truffleShippingPlus} | ${formatEuro(detail.shippingPriceItaly)} ${l10n.truffleShippingItaly}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.spacingL),
              _InfoRow(
                label: l10n.truffleDetailPricePerKg,
                value: formatEuro(detail.pricePerKg),
              ),
              _InfoRow(
                label: l10n.truffleFilterRegion,
                value: ItalianRegions.localizedLabel(l10n, detail.region),
              ),
              _InfoRow(
                label: l10n.truffleFilterHarvestDate,
                value: formatShortDate(context, detail.harvestDate),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Text(
              l10n.truffleDetailError,
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailImages extends StatelessWidget {
  const _DetailImages({required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.softGrey,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 40, color: AppColors.black50),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: PageView.builder(
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.softGrey,
                child: const Center(
                  child: Icon(Icons.broken_image_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.cardTitle,
          ),
        ],
      ),
    );
  }
}
