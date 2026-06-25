import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/profile/application/seller_profile_providers.dart';
import 'package:truffly_app/features/profile/domain/seller_profile_detail.dart';
import 'package:truffly_app/features/profile/domain/seller_review_item.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/features/reviews/presentation/review_text.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/truffle_list_item.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerProfilePage extends ConsumerWidget {
  const SellerProfilePage({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(sellerProfileProvider(sellerId));
    final profile = profileAsync.valueOrNull;
    final currentUserAsync = ref.watch(currentUserAccountProfileProvider);
    final isOwner = currentUserAsync.maybeWhen(
      data: (currentProfile) => currentProfile.userId == sellerId,
      orElse: () => false,
    );

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
        actions: [
          if (isOwner)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.spacingM),
              child: IconButton(
                tooltip: AppLocalizations.of(context)!.accountDetailsTitle,
                onPressed: () => context.push(AppRoutes.accountDetails),
                icon: const Icon(Icons.edit_rounded),
              ),
            ),
        ],
      ),
      body: profile != null
          ? RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sellerProfileProvider(sellerId));
                ref.invalidate(sellerReviewsProvider(sellerId));
                try {
                  await Future.wait([
                    ref.read(sellerProfileProvider(sellerId).future),
                    ref.read(sellerReviewsProvider(sellerId).future),
                  ]);
                } catch (_) {
                  // Keep the current content visible.
                  // The user can retry by pulling again.
                }
              },
              child: _SellerProfileContent(profile: profile),
            )
          : profileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const _ProfileErrorState(),
    );
  }
}

class _SellerProfileContent extends ConsumerStatefulWidget {
  const _SellerProfileContent({required this.profile});

  final SellerProfileDetail profile;

  @override
  ConsumerState<_SellerProfileContent> createState() =>
      _SellerProfileContentState();
}

enum _SellerSection { info, truffles, reviews }

class _SellerProfileContentState extends ConsumerState<_SellerProfileContent> {
  _SellerSection _selectedSection = _SellerSection.info;
  bool _isAvatarPreviewOpen = false;

  void _selectSection(_SellerSection section) {
    if (_selectedSection == section) return;
    setState(() => _selectedSection = section);
  }

  void _openAvatarPreview() {
    if (_isAvatarPreviewOpen) return;
    setState(() => _isAvatarPreviewOpen = true);
  }

  void _closeAvatarPreview() {
    if (!_isAvatarPreviewOpen) return;
    setState(() => _isAvatarPreviewOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final favoriteState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);
    final reviewsAsync = ref.watch(sellerReviewsProvider(profile.id));
    final l10n = AppLocalizations.of(context)!;
    final ratingValue = profile.reviewCount > 0
        ? profile.ratingAverage.toStringAsFixed(1)
        : '0';
    final ordersValue = profile.completedOrdersCount.toString();
    final bioText = (profile.bio?.trim().isNotEmpty ?? false)
        ? profile.bio!.trim()
        : l10n.sellerProfileBioFallback;
    final regionText = _capitalizedRegion(profile.region);

    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingS,
            AppSpacing.spacingS,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
          ),
          children: [
            _SellerHeroCard(
              profile: profile,
              ratingValue: ratingValue,
              ordersValue: ordersValue,
              bioText: bioText,
              onAvatarTap: _openAvatarPreview,
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Row(
              children: [
                Expanded(
                  child: _SectionChip(
                    label: l10n.sellerProfileInfoTab,
                    selected: _selectedSection == _SellerSection.info,
                    onSelected: () => _selectSection(_SellerSection.info),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SectionChip(
                    label: l10n.sellerProfileReviewsTab,
                    selected: _selectedSection == _SellerSection.reviews,
                    onSelected: () => _selectSection(_SellerSection.reviews),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SectionChip(
                    label: l10n.sellerProfileTrufflesTab,
                    selected: _selectedSection == _SellerSection.truffles,
                    onSelected: () => _selectSection(_SellerSection.truffles),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingS),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_selectedSection) {
                _SellerSection.info => _InfoTabContent(
                  key: const ValueKey('info'),
                  profile: profile,
                  regionText: regionText,
                  reviews: profile.latestReviews,
                  activeTruffles: profile.activeTruffles,
                  onShowReviews: () => _selectSection(_SellerSection.reviews),
                  onShowTruffles: () => _selectSection(_SellerSection.truffles),
                  onOpenTruffle: (item) =>
                      context.push(AppRoutes.truffleDetailPath(item.id)),
                  onFavoriteTap: (item) =>
                      favoriteNotifier.toggleFavorite(item.id),
                  isFavorite: (id) => favoriteState.ids.contains(id),
                  isFavoritePending: (id) =>
                      favoriteState.pendingIds.contains(id),
                ),
                _SellerSection.reviews => _ReviewsTabContent(
                  key: const ValueKey('reviews'),
                  reviewsAsync: reviewsAsync,
                ),
                _SellerSection.truffles => _TrufflesTabContent(
                  key: const ValueKey('truffles'),
                  activeTruffles: profile.activeTruffles,
                  onOpenTruffle: (item) =>
                      context.push(AppRoutes.truffleDetailPath(item.id)),
                  onFavoriteTap: (item) =>
                      favoriteNotifier.toggleFavorite(item.id),
                  isFavorite: (id) => favoriteState.ids.contains(id),
                  isFavoritePending: (id) =>
                      favoriteState.pendingIds.contains(id),
                ),
              },
            ),
          ],
        ),
        if (_isAvatarPreviewOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeAvatarPreview,
              child: Container(
                color: Colors.black.withValues(alpha: 0.56),
                child: Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 180),
                      tween: Tween<double>(begin: 0.94, end: 1),
                      curve: Curves.easeOutCubic,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: SellerAvatar(
                          imageUrl: profile.profileImageUrl,
                          initials: profile.initials,
                          size: 180,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SellerHeroCard extends StatelessWidget {
  const _SellerHeroCard({
    required this.profile,
    required this.ratingValue,
    required this.ordersValue,
    required this.bioText,
    required this.onAvatarTap,
  });

  final SellerProfileDetail profile;
  final String ratingValue;
  final String ordersValue;
  final String bioText;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAvatarTap,
                    customBorder: const CircleBorder(),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 1.5),
                      ),
                      child: SellerAvatar(
                        imageUrl: profile.profileImageUrl,
                        initials: profile.initials,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: _StatsKpiStrip(
                    ratingValue: ratingValue,
                    ratingLabel: l10n.sellerProfileRatingStarsLabel,
                    reviewsValue: ordersValue,
                    reviewsLabel: l10n.sellerProfileOrdersLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Row(
              children: [
                Expanded(
                  child: Text(
                    profile.fullName,
                    style: AppTextStyles.authScreenTitle.copyWith(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              bioText,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTabContent extends StatelessWidget {
  const _InfoTabContent({
    super.key,
    required this.profile,
    required this.regionText,
    required this.reviews,
    required this.activeTruffles,
    required this.onShowReviews,
    required this.onShowTruffles,
    required this.onOpenTruffle,
    required this.onFavoriteTap,
    required this.isFavorite,
    required this.isFavoritePending,
  });

  final SellerProfileDetail profile;
  final String regionText;
  final List<SellerReviewItem> reviews;
  final List<TruffleListItem> activeTruffles;
  final VoidCallback onShowReviews;
  final VoidCallback onShowTruffles;
  final ValueChanged<TruffleListItem> onOpenTruffle;
  final ValueChanged<TruffleListItem> onFavoriteTap;
  final bool Function(String id) isFavorite;
  final bool Function(String id) isFavoritePending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ratingText = profile.reviewCount > 0
        ? profile.ratingAverage.toStringAsFixed(1)
        : l10n.sellerRatingNew;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: l10n.sellerProfileSummaryTitle,
          child: Column(
            children: [
              _InfoRow(label: l10n.sellerProfileRegionLabel, value: regionText),
              const SizedBox(height: AppSpacing.spacingS),
              _InfoRow(
                label: l10n.sellerProfileRatingStarsLabel,
                value: ratingText,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _InfoRow(
                label: l10n.sellerProfileOrdersLabel,
                value: profile.completedOrdersCount.toString(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        _PreviewSection(
          title: l10n.sellerProfileRecentReviewsTitle,
          actionLabel: l10n.sellerProfileReadAll,
          onActionTap: onShowReviews,
          child: reviews.isEmpty
              ? _EmptyInfoBox(message: l10n.sellerProfileNoReviews)
              : Column(
                  children: [
                    for (
                      var index = 0;
                      index < reviews.take(2).length;
                      index++
                    ) ...[
                      if (index > 0)
                        const SizedBox(height: AppSpacing.spacingS),
                      _ReviewCard(review: reviews[index]),
                    ],
                  ],
                ),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        _PreviewSection(
          title: l10n.sellerProfileActiveTrufflesTitle,
          actionLabel: l10n.sellerProfileReadAll,
          onActionTap: onShowTruffles,
          child: activeTruffles.isEmpty
              ? _EmptyInfoBox(message: l10n.sellerProfileNoActiveTruffles)
              : _TruffleCardsWrap(
                  items: activeTruffles.take(2).toList(growable: false),
                  isFavorite: isFavorite,
                  isFavoritePending: isFavoritePending,
                  onOpenTruffle: onOpenTruffle,
                  onFavoriteTap: onFavoriteTap,
                ),
        ),
      ],
    );
  }
}

class _ReviewsTabContent extends StatelessWidget {
  const _ReviewsTabContent({super.key, required this.reviewsAsync});

  final AsyncValue<List<SellerReviewItem>> reviewsAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.sellerProfileReviewsTab,
      child: reviewsAsync.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return _EmptyInfoBox(message: l10n.sellerProfileNoReviews);
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
          padding: EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) =>
            _EmptyInfoBox(message: l10n.sellerProfileUnableToLoadReviews),
      ),
    );
  }
}

class _TrufflesTabContent extends StatelessWidget {
  const _TrufflesTabContent({
    super.key,
    required this.activeTruffles,
    required this.onOpenTruffle,
    required this.onFavoriteTap,
    required this.isFavorite,
    required this.isFavoritePending,
  });

  final List<TruffleListItem> activeTruffles;
  final ValueChanged<TruffleListItem> onOpenTruffle;
  final ValueChanged<TruffleListItem> onFavoriteTap;
  final bool Function(String id) isFavorite;
  final bool Function(String id) isFavoritePending;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.sellerProfileTrufflesTab,
      child: activeTruffles.isEmpty
          ? _EmptyInfoBox(message: l10n.sellerProfileNoActiveTruffles)
          : _TruffleCardsWrap(
              items: activeTruffles,
              isFavorite: isFavorite,
              isFavoritePending: isFavoritePending,
              onOpenTruffle: onOpenTruffle,
              onFavoriteTap: onFavoriteTap,
            ),
    );
  }
}

class _TruffleCardsWrap extends StatelessWidget {
  const _TruffleCardsWrap({
    required this.items,
    required this.isFavorite,
    required this.isFavoritePending,
    required this.onOpenTruffle,
    required this.onFavoriteTap,
  });

  final List<TruffleListItem> items;
  final bool Function(String id) isFavorite;
  final bool Function(String id) isFavoritePending;
  final ValueChanged<TruffleListItem> onOpenTruffle;
  final ValueChanged<TruffleListItem> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - AppSpacing.spacingXS) / 2;
        return Wrap(
          spacing: AppSpacing.spacingXS,
          runSpacing: AppSpacing.spacingXS,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: TruffleListingCard(
                  item: item,
                  isFavorite: isFavorite(item.id),
                  isFavoritePending: isFavoritePending(item.id),
                  onTap: () => onOpenTruffle(item),
                  onFavoriteTap: () => onFavoriteTap(item),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
    required this.child,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;
  final Widget child;

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
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onActionTap,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    actionLabel,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.black80,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
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
                  fontSize: 13,
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
  });

  final String ratingValue;
  final String ratingLabel;
  final String reviewsValue;
  final String reviewsLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
      child: Row(
        children: [
          Expanded(
            child: _KpiItem(value: ratingValue, label: ratingLabel),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Container(
            width: 1,
            height: 34,
            color: Colors.white.withValues(alpha: 0.24),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: _KpiItem(value: reviewsValue, label: reviewsLabel),
          ),
        ],
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  const _KpiItem({required this.value, required this.label});

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
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, required this.title});

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingS),
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
                  size: 16,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 4),
                Text(
                  review.rating.toString(),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  formatShortDate(context, review.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: AppColors.black80,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            if (review.hasComment) ...[
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                review.isAuto
                    ? localizedAutoReviewComment(
                        context,
                        rating: review.rating,
                        fallbackComment: review.comment,
                      )
                    : review.comment!.trim(),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
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
            fontSize: 13,
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

String _capitalizedRegion(String? region) {
  final value = region?.trim();
  if (value == null || value.isEmpty) {
    return 'Non disponibile';
  }

  final lower = value.toLowerCase();
  return '${lower[0].toUpperCase()}${lower.substring(1)}';
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Text(
          l10n.sellerProfileLoadError,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13,
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
