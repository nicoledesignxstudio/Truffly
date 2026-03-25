import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/profile/application/seller_profile_providers.dart';
import 'package:truffly_app/features/profile/domain/seller_profile_detail.dart';
import 'package:truffly_app/features/profile/domain/seller_review_item.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerProfilePage extends ConsumerWidget {
  const SellerProfilePage({
    super.key,
    required this.sellerId,
  });

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(sellerProfileProvider(sellerId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.sellers);
              }
            },
          ),
        ),
      ),
      body: profileAsync.when(
        data: (profile) => _SellerProfileContent(profile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const _ProfileErrorState(),
      ),
    );
  }
}

class _SellerProfileContent extends ConsumerStatefulWidget {
  const _SellerProfileContent({required this.profile});

  final SellerProfileDetail profile;

  @override
  ConsumerState<_SellerProfileContent> createState() => _SellerProfileContentState();
}

enum _SellerSection {
  info,
  truffles,
  reviews,
}

class _SellerProfileContentState extends ConsumerState<_SellerProfileContent> {
  _SellerSection _selectedSection = _SellerSection.info;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final favoriteState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final regionLabel = profile.region == null || profile.region!.isEmpty
        ? (isItalian ? 'Regione non disponibile' : 'Region unavailable')
        : ItalianRegions.localizedLabel(l10n, profile.region!);
    final reviewsAsync = ref.watch(sellerReviewsProvider(profile.id));

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacingL),
      children: [
        const SizedBox(height: AppSpacing.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
          child: _SectionCard(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 6,
                      ),
                      boxShadow: AppShadows.authField,
                    ),
                    child: SellerAvatar(
                      imageUrl: profile.profileImageUrl,
                      initials: profile.initials,
                      size: 128,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        profile.fullName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authScreenTitle.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacingXS),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingS,
                        vertical: 6,
                      ),
                      child: Text(
                        regionLabel,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
          child: Row(
            children: [
              Expanded(
                child: _SectionChip(
                  label: 'Info',
                  selected: _selectedSection == _SellerSection.info,
                  onSelected: () => setState(() => _selectedSection = _SellerSection.info),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingXS),
              Expanded(
                child: _SectionChip(
                  label: isItalian ? 'Tartufi' : 'Truffles',
                  selected: _selectedSection == _SellerSection.truffles,
                  onSelected: () =>
                      setState(() => _selectedSection = _SellerSection.truffles),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingXS),
              Expanded(
                child: _SectionChip(
                  label: isItalian ? 'Recensioni' : 'Reviews',
                  selected: _selectedSection == _SellerSection.reviews,
                  onSelected: () =>
                      setState(() => _selectedSection = _SellerSection.reviews),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacingM),
        if (_selectedSection == _SellerSection.info) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
            child: _StatsKpiStrip(
              ratingValue: profile.reviewCount > 0
                  ? profile.ratingAverage.toStringAsFixed(1)
                  : (isItalian ? 'Nuovo' : 'New'),
              ratingLabel: isItalian ? 'Valutazione' : 'Rating',
              reviewsValue: profile.reviewCount.toString(),
              reviewsLabel: isItalian ? 'Recensioni' : 'Reviews',
              ordersValue: profile.completedOrdersCount.toString(),
              ordersLabel: 'Orders',
            ),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
            child: _SectionCard(
              title: isItalian ? 'Bio' : 'Bio',
              child: Text(
                (profile.bio?.trim().isNotEmpty ?? false)
                    ? profile.bio!.trim()
                    : (isItalian
                        ? 'Questo venditore non ha ancora aggiunto una descrizione.'
                        : 'This seller has not added a description yet.'),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black80,
                ),
              ),
            ),
          ),
        ],
        if (_selectedSection == _SellerSection.reviews) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
            child: _SectionCard(
              title: isItalian ? 'Recensioni' : 'Reviews',
              child: reviewsAsync.when(
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return _EmptyInfoBox(
                      message: isItalian
                          ? 'Nessuna recensione per questo venditore.'
                          : 'No reviews for this seller yet.',
                    );
                  }

                  return Column(
                    children: [
                      for (var index = 0; index < reviews.length; index++) ...[
                        if (index > 0) const SizedBox(height: AppSpacing.spacingS),
                        _ReviewCard(review: reviews[index]),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _EmptyInfoBox(
                  message: isItalian
                      ? 'Impossibile caricare le recensioni.'
                      : 'Unable to load reviews right now.',
                ),
              ),
            ),
          ),
        ],
        if (_selectedSection == _SellerSection.truffles) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingM),
            child: _SectionCard(
              title: isItalian ? 'I miei tartufi' : 'My truffles',
              child: profile.activeTruffles.isEmpty
                  ? _EmptyInfoBox(
                      message: isItalian
                          ? 'Questo venditore non ha tartufi attivi al momento.'
                          : 'This seller has no active truffles right now.',
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: profile.activeTruffles.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppSpacing.spacingXS,
                        crossAxisSpacing: AppSpacing.spacingXS,
                        childAspectRatio: 0.58,
                      ),
                      itemBuilder: (context, index) {
                        final item = profile.activeTruffles[index];
                        return TruffleListingCard(
                          item: item,
                          isFavorite: favoriteState.ids.contains(item.id),
                          isFavoritePending: favoriteState.pendingIds.contains(item.id),
                          onTap: () => context.push(AppRoutes.truffleDetailPath(item.id)),
                          onFavoriteTap: () => favoriteNotifier.toggleFavorite(item.id),
                        );
                      },
                    ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.black : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(
          color: selected ? AppColors.black : AppColors.black10,
        ),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: AppRadii.authBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingS,
              vertical: AppSpacing.spacingS,
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected ? AppColors.white : AppColors.black80,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsKpiStrip extends StatelessWidget {
  const _StatsKpiStrip({
    required this.ratingValue,
    required this.ratingLabel,
    required this.reviewsValue,
    required this.reviewsLabel,
    required this.ordersValue,
    required this.ordersLabel,
  });

  final String ratingValue;
  final String ratingLabel;
  final String reviewsValue;
  final String reviewsLabel;
  final String ordersValue;
  final String ordersLabel;

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
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingM),
        child: Row(
          children: [
            Expanded(
              child: _KpiItem(
                value: ratingValue,
                label: ratingLabel,
              ),
            ),
            _KpiDivider(),
            Expanded(
              child: _KpiItem(
                value: reviewsValue,
                label: reviewsLabel,
              ),
            ),
            _KpiDivider(),
            Expanded(
              child: _KpiItem(
                value: ordersValue,
                label: ordersLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  const _KpiItem({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.black,
            fontSize: 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.black80,
          ),
        ),
      ],
    );
  }
}

class _KpiDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.black10,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.title,
    this.trailing,
  });

  final String? title;
  final Widget child;
  final Widget? trailing;

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
            if (title != null || trailing != null) ...[
              Row(
                children: [
                  if (title != null)
                    Expanded(
                      child: Text(
                        title!,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.spacingM),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SellerReviewItem review;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  review.rating.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 16,
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  formatShortDate(context, review.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 16,
                    color: AppColors.black80,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (review.hasComment) ...[
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                review.comment!.trim(),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16,
                  color: AppColors.black80,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyInfoBox extends StatelessWidget {
  const _EmptyInfoBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 16,
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState();

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Text(
          isItalian
              ? 'Impossibile caricare questo profilo venditore.'
              : 'Unable to load this seller profile right now.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 16,
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
