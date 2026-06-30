import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
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
  const SellerProfilePage({
    super.key,
    required this.sellerId,
    this.initialSection,
  });

  final String sellerId;
  final String? initialSection;

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
              child: _SellerProfileContent(
                profile: profile,
                initialSection: initialSection,
              ),
            )
          : profileAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : const _ProfileErrorState(),
    );
  }
}

class _SellerProfileContent extends ConsumerStatefulWidget {
  const _SellerProfileContent({
    required this.profile,
    required this.initialSection,
  });

  final SellerProfileDetail profile;
  final String? initialSection;

  @override
  ConsumerState<_SellerProfileContent> createState() =>
      _SellerProfileContentState();
}

enum _SellerSection { truffles, reviews }

class _SellerProfileContentState extends ConsumerState<_SellerProfileContent> {
  late _SellerSection _selectedSection = _initialSection();
  bool _isAvatarPreviewOpen = false;

  _SellerSection _initialSection() {
    return widget.initialSection == 'truffles'
        ? _SellerSection.truffles
        : _SellerSection.reviews;
  }

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
    final bioText = (profile.bio?.trim().isNotEmpty ?? false)
        ? profile.bio!.trim()
        : l10n.sellerProfileBioFallback;
    final regionText = _capitalizedRegion(profile.region);

    return Stack(
      children: [
        ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingL,
          ),
          children: [
            _SellerProfileHeader(
              profile: profile,
              ratingValue: ratingValue,
              regionText: regionText,
              bioText: bioText,
              onAvatarTap: _openAvatarPreview,
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _SellerStatsPanel(
              soldCount: profile.completedOrdersCount,
              reviewCount: profile.reviewCount,
              joinedAt: profile.joinedAt,
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _SectionTabs(
              selectedSection: _selectedSection,
              onSelected: _selectSection,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_selectedSection) {
                _SellerSection.reviews => _ReviewsTabContent(
                  key: const ValueKey('reviews'),
                  profile: profile,
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
                          size: 160,
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

class _SellerProfileHeader extends StatelessWidget {
  const _SellerProfileHeader({
    required this.profile,
    required this.ratingValue,
    required this.regionText,
    required this.bioText,
    required this.onAvatarTap,
  });

  final SellerProfileDetail profile;
  final String ratingValue;
  final String regionText;
  final String bioText;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAvatarTap,
                customBorder: const CircleBorder(),
                child: SellerAvatar(
                  imageUrl: profile.profileImageUrl,
                  initials: profile.initials,
                  size: 88,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXS),
                  Wrap(
                    spacing: AppSpacing.spacingM,
                    runSpacing: AppSpacing.spacingXXS,
                    children: [
                      _InlineMeta(
                        icon: Icons.location_on_rounded,
                        label: '$regionText, Italia',
                        iconColor: AppColors.black,
                      ),
                      _InlineMeta(
                        icon: Icons.star_rounded,
                        label:
                            '$ratingValue (${l10n.sellerReviewsCount(profile.reviewCount)})',
                        iconColor: AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingM),
        Text(
          bioText,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 14,
            height: 1.34,
            color: AppColors.black80,
          ),
        ),
      ],
    );
  }
}

class _InlineMeta extends StatelessWidget {
  const _InlineMeta({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.spacingXXS),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 14,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}

class _SellerStatsPanel extends StatelessWidget {
  const _SellerStatsPanel({
    required this.soldCount,
    required this.reviewCount,
    required this.joinedAt,
  });

  final int soldCount;
  final int reviewCount;
  final DateTime? joinedAt;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
        child: Row(
          children: [
            Expanded(
              child: _ProfileStat(
                icon: Icons.inventory_2_outlined,
                value: soldCount.toString(),
                label: 'Vendite',
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _ProfileStat(
                icon: Icons.group_rounded,
                value: reviewCount.toString(),
                label: 'Recensioni',
              ),
            ),
            const _VerticalDivider(),
            Expanded(
              child: _ProfileStat(
                icon: Icons.schedule_rounded,
                value: _sellerTenureLabel(joinedAt),
                label: 'Su Truffly',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.black),
            const SizedBox(width: AppSpacing.spacingXS),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.black80,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.black10);
  }
}

class _ReviewsTabContent extends StatelessWidget {
  const _ReviewsTabContent({
    super.key,
    required this.profile,
    required this.reviewsAsync,
  });

  final SellerProfileDetail profile;
  final AsyncValue<List<SellerReviewItem>> reviewsAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return _EmptyInfoBox(message: l10n.sellerProfileNoReviews);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReviewsSummary(
                  ratingAverage: profile.ratingAverage,
                  reviewCount: profile.reviewCount,
                  reviews: reviews,
                ),
                const SizedBox(height: AppSpacing.spacingM),
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
      ],
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

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.selectedSection, required this.onSelected});

  final _SellerSection selectedSection;
  final ValueChanged<_SellerSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softGrey.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Row(
          children: [
            Expanded(
              child: _SectionTab(
                label: 'Tartufi',
                selected: selectedSection == _SellerSection.truffles,
                onTap: () => onSelected(_SellerSection.truffles),
              ),
            ),
            Expanded(
              child: _SectionTab(
                label: AppLocalizations.of(context)!.sellerProfileReviewsTab,
                selected: selectedSection == _SellerSection.reviews,
                onTap: () => onSelected(_SellerSection.reviews),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTab extends StatelessWidget {
  const _SectionTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      decoration: BoxDecoration(
        color: selected ? AppColors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 34,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? AppColors.white : AppColors.black,
                ),
              ),
            ),
          ),
        ),
      ),
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

class _ReviewsSummary extends StatelessWidget {
  const _ReviewsSummary({
    required this.ratingAverage,
    required this.reviewCount,
    required this.reviews,
  });

  final double ratingAverage;
  final int reviewCount;
  final List<SellerReviewItem> reviews;

  @override
  Widget build(BuildContext context) {
    final counts = <int, int>{
      for (var rating = 1; rating <= 5; rating++) rating: 0,
    };
    for (final review in reviews) {
      counts[review.rating] = (counts[review.rating] ?? 0) + 1;
    }
    final maxCount = counts.values.fold<int>(
      0,
      (max, value) => value > max ? value : max,
    );
    final ratingText = reviewCount > 0 ? ratingAverage.toStringAsFixed(1) : '0';

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final ratingBlock = _RatingBlock(
          ratingText: ratingText,
          ratingAverage: ratingAverage,
          reviewCount: reviewCount,
        );
        final bars = _RatingBars(counts: counts, maxCount: maxCount);

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ratingBlock,
              const SizedBox(height: AppSpacing.spacingL),
              bars,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 96, child: ratingBlock),
            const SizedBox(width: AppSpacing.spacingL),
            Expanded(child: bars),
          ],
        );
      },
    );
  }
}

class _RatingBlock extends StatelessWidget {
  const _RatingBlock({
    required this.ratingText,
    required this.ratingAverage,
    required this.reviewCount,
  });

  final String ratingText;
  final double ratingAverage;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ratingText,
          style: AppTextStyles.sectionTitle.copyWith(
            fontSize: 20,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        _StarRow(rating: ratingAverage, size: 20),
        const SizedBox(height: AppSpacing.spacingXS),
        Text(
          l10n.sellerReviewsCount(reviewCount),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black80,
          ),
        ),
      ],
    );
  }
}

class _RatingBars extends StatelessWidget {
  const _RatingBars({required this.counts, required this.maxCount});

  final Map<int, int> counts;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var rating = 5; rating >= 1; rating--)
          Padding(
            padding: EdgeInsets.only(bottom: rating == 1 ? 0 : 10),
            child: _RatingBarRow(
              rating: rating,
              count: counts[rating] ?? 0,
              fraction: maxCount == 0 ? 0 : (counts[rating] ?? 0) / maxCount,
            ),
          ),
      ],
    );
  }
}

class _RatingBarRow extends StatelessWidget {
  const _RatingBarRow({
    required this.rating,
    required this.count,
    required this.fraction,
  });

  final int rating;
  final int count;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final label = rating == 1 ? '1 stella' : '$rating stelle';
    return Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.black80,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacingS),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: fraction.clamp(0, 1),
                backgroundColor: AppColors.softGrey,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.spacingS),
        SizedBox(
          width: 28,
          child: Text(
            count.toString(),
            textAlign: TextAlign.right,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.black80,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final SellerReviewItem review;

  @override
  Widget build(BuildContext context) {
    final comment = review.isAuto
        ? localizedAutoReviewComment(
            context,
            rating: review.rating,
            fallbackComment: review.comment,
          )
        : review.comment?.trim();
    final reviewerName = review.isAuto
        ? 'Truffly'
        : _shortReviewerNameOrFallback(review.reviewerName);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _StarRow(rating: review.rating.toDouble(), size: 18),
                ),
                Text(
                  formatShortDate(context, review.createdAt),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.black80,
                  ),
                ),
              ],
            ),
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                comment,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 14,
                  color: AppColors.black80,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              reviewerName,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.black50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.size});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedRating = rating.clamp(0, 5).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 1; index <= 5; index++)
          _RatingStar(
            fill: (normalizedRating - (index - 1)).clamp(0, 1).toDouble(),
            size: size,
          ),
      ],
    );
  }
}

class _RatingStar extends StatelessWidget {
  const _RatingStar({required this.fill, required this.size});

  final double fill;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (fill >= 0.95) {
      return Icon(Icons.star_rounded, size: size, color: AppColors.accent);
    }
    if (fill <= 0.05) {
      return Icon(
        Icons.star_rounded,
        size: size,
        color: AppColors.black20.withValues(alpha: 0.45),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(
            Icons.star_rounded,
            size: size,
            color: AppColors.black20.withValues(alpha: 0.45),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: Icon(
                Icons.star_rounded,
                size: size,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
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
            fontSize: 14,
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

String _sellerTenureLabel(DateTime? joinedAt) {
  if (joinedAt == null) return '-';

  final now = DateTime.now();
  final yearDelta = now.year - joinedAt.year;
  final hasHadAnniversary =
      now.month > joinedAt.month ||
      (now.month == joinedAt.month && now.day >= joinedAt.day);
  final years = hasHadAnniversary ? yearDelta : yearDelta - 1;
  if (years >= 1) return years == 1 ? '1 anno' : '$years anni';

  final monthDelta =
      (now.year - joinedAt.year) * 12 + now.month - joinedAt.month;
  final months = now.day >= joinedAt.day ? monthDelta : monthDelta - 1;
  if (months >= 1) return months == 1 ? '1 mese' : '$months mesi';

  return 'Nuovo';
}

String _shortReviewerNameOrFallback(String? name) {
  final normalized = name?.trim();
  if (normalized == null || normalized.isEmpty) return 'Acquirente';
  final parts = normalized
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList(growable: false);
  if (parts.length < 2) return parts.first;
  return '${parts.first} ${parts[1][0].toUpperCase()}.';
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
            fontSize: 14,
            color: AppColors.black80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
