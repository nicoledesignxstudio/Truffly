import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_guide_entry_card.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_quality_badge.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_shipping_card.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_seller_preview_card.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_sticky_buy_bar.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleDetailPage extends ConsumerWidget {
  const TruffleDetailPage({super.key, required this.truffleId});

  final String truffleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(truffleDetailProvider(truffleId));
    final favoriteState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);
    final heroHeight = MediaQuery.sizeOf(context).height * 0.5;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: detailAsync.when(
        data: (detail) {
          final isFavorite = favoriteState.ids.contains(detail.id);
          final isPending = favoriteState.pendingIds.contains(detail.id);

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(bottom: 96 + bottomInset),
                children: [
                  _DetailImagesHero(
                    height: heroHeight,
                    imageUrls: detail.imageUrls,
                    fallbackAssetPath: detail.type.guideAssetImagePath,
                    isFavorite: isFavorite,
                    isFavoritePending: isPending,
                    onBackPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    onFavoritePressed: () =>
                        favoriteNotifier.toggleFavorite(detail.id),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.spacingM,
                      AppSpacing.spacingM,
                      AppSpacing.spacingM,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TruffleQualityBadge(
                          quality: detail.quality,
                          backgroundColor: const Color(0xFFFFD3C5),
                          textColor: AppColors.accent,
                        ),
                        const SizedBox(height: AppSpacing.spacingXS),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                detail.type.localizedName(l10n),
                                style: AppTextStyles.authScreenTitle.copyWith(
                                  fontSize: 27,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.spacingXS),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                formatEuro(detail.priceTotal),
                                textAlign: TextAlign.right,
                                style: AppTextStyles.cardPrice.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 0),
                        Text(
                          detail.type.latinName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black80,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacingM),
                        TruffleSellerPreviewCard(
                          seller: detail.seller,
                          reviewCountLabel: _reviewCountLabel(
                            context,
                            reviewCount: detail.seller.reviewCount,
                          ),
                          onTap: () => context.push(
                            AppRoutes.sellerProfilePath(detail.seller.id),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacingS),
                        _DetailMetaCard(
                          title: _productDetailsTitle(context),
                          rows: [
                            _MetaRowData(
                              label: l10n.truffleDetailPricePerKg,
                              value: formatEuro(detail.pricePerKg),
                            ),
                            _MetaRowData(
                              label: l10n.truffleFilterWeight,
                              value: formatWeightGrams(detail.weightGrams),
                            ),
                            _MetaRowData(
                              label: l10n.truffleFilterRegion,
                              value: ItalianRegions.localizedLabel(
                                l10n,
                                detail.region,
                              ),
                            ),
                            _MetaRowData(
                              label: l10n.truffleFilterHarvestDate,
                              value: formatShortDate(
                                context,
                                detail.harvestDate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spacingS),
                        TruffleGuideEntryCard(
                          title: _guideTitle(context),
                          description: _guideDescription(
                            context,
                            truffleName: detail.type.localizedName(l10n),
                          ),
                          onTap: () => context.push(
                            AppRoutes.truffleGuidePath(detail.type.dbValue),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.spacingS),
                        TruffleShippingCard(
                          title: _shippingTitle(context),
                          italyLabel: _shippingItalyLabel(context),
                          abroadLabel: _shippingAbroadLabel(context),
                          shippingPriceItaly: detail.shippingPriceItaly,
                          shippingPriceAbroad: detail.shippingPriceAbroad,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TruffleStickyBuyBar(
                  buttonLabel: _buyCtaLabel(context),
                  onPressed: () =>
                      context.push(AppRoutes.checkoutPath(detail.id)),
                ),
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

  String _reviewCountLabel(BuildContext context, {required int reviewCount}) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    if (isItalian) {
      return reviewCount == 1 ? '1 recensione' : '$reviewCount recensioni';
    }
    return reviewCount == 1 ? '1 review' : '$reviewCount reviews';
  }

  String _guideTitle(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian
        ? 'Conosci questo tartufo?'
        : 'Do you know this truffle?';
  }

  String _guideDescription(
    BuildContext context, {
    required String truffleName,
  }) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian
        ? 'Scopri di pi\u00f9 su $truffleName, le sue caratteristiche principali e cosa lo rende cos\u00ec speciale.'
        : 'Learn more about $truffleName, its key characteristics, and what makes it so distinctive.';
  }

  String _productDetailsTitle(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian ? 'Dettagli prodotto' : 'Product details';
  }

  String _shippingTitle(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian ? 'Spedizione' : 'Shipping';
  }

  String _shippingItalyLabel(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian ? 'Spedizione in Italia' : 'Shipping in Italy';
  }

  String _shippingAbroadLabel(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian ? 'Spedizione estero' : 'Shipping abroad';
  }

  String _buyCtaLabel(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return isItalian ? 'Acquista' : 'Buy now';
  }
}

class _DetailImagesHero extends StatefulWidget {
  const _DetailImagesHero({
    required this.height,
    required this.imageUrls,
    required this.fallbackAssetPath,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.onBackPressed,
    required this.onFavoritePressed,
  });

  final double height;
  final List<String> imageUrls;
  final String fallbackAssetPath;
  final bool isFavorite;
  final bool isFavoritePending;
  final VoidCallback onBackPressed;
  final VoidCallback onFavoritePressed;

  @override
  State<_DetailImagesHero> createState() => _DetailImagesHeroState();
}

class _DetailImagesHeroState extends State<_DetailImagesHero> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.imageUrls.isNotEmpty;
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            Positioned.fill(
              child: hasImages
                    ? PageView.builder(
                      controller: _pageController,
                      pageSnapping: true,
                      physics: const PageScrollPhysics(),
                      dragStartBehavior: DragStartBehavior.down,
                      itemCount: widget.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return ColoredBox(
                          color: AppColors.softGrey,
                          child: Image.network(
                            widget.imageUrls[index],
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) {
                              return _FallbackHeroImage(
                                assetPath: widget.fallbackAssetPath,
                              );
                            },
                          ),
                        );
                      },
                    )
                  : _FallbackHeroImage(assetPath: widget.fallbackAssetPath),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33000000),
                        Color(0x00000000),
                        Color(0x12000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: topInset + AppSpacing.spacingM,
              left: AppSpacing.spacingM,
              child: _OverlayCircleButton(
                icon: Icons.arrow_back_rounded,
                onPressed: widget.onBackPressed,
              ),
            ),
            Positioned(
              top: topInset + AppSpacing.spacingM,
              right: AppSpacing.spacingM,
              child: _OverlayCircleButton(
                icon: widget.isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                iconColor: widget.isFavorite
                    ? AppColors.accent
                    : AppColors.black,
                onPressed: widget.isFavoritePending
                    ? null
                    : widget.onFavoritePressed,
              ),
            ),
            if (widget.imageUrls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: AppSpacing.spacingM,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (
                      var index = 0;
                      index < widget.imageUrls.length;
                      index++
                    ) ...[
                      if (index > 0) const SizedBox(width: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: index == _currentPage ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OverlayCircleButton extends StatelessWidget {
  const _OverlayCircleButton({
    required this.icon,
    required this.onPressed,
    this.iconColor = AppColors.black,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: AppSpacing.circularIconButtonSize,
        height: AppSpacing.circularIconButtonSize,
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: Icon(icon, size: AppSpacing.circularIconSize, color: iconColor),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.softGrey,
      child: Center(child: Icon(icon, size: 40, color: AppColors.black50)),
    );
  }
}

class _FallbackHeroImage extends StatelessWidget {
  const _FallbackHeroImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.softGrey,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        errorBuilder: (_, _, _) =>
            const _ImagePlaceholder(icon: Icons.image_outlined),
      ),
    );
  }
}

class _DetailMetaCard extends StatelessWidget {
  const _DetailMetaCard({required this.title, required this.rows});

  final String title;
  final List<_MetaRowData> rows;

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
        padding: const EdgeInsets.all(AppSpacing.spacingS),
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
            const SizedBox(height: AppSpacing.spacingS),
            for (var index = 0; index < rows.length; index++) ...[
              if (index > 0) const SizedBox(height: AppSpacing.spacingS),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      rows[index].label,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
                  Flexible(
                    child: Text(
                      rows[index].value,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 14,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRowData {
  const _MetaRowData({required this.label, required this.value});

  final String label;
  final String value;
}
