import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/home/application/home_content_provider.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_section.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_listing_card.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/presentation/publish_truffle_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) {
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          backgroundColor: AppColors.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingL),
              child: Text(
                l10n.homeLoadError,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
            ),
          ),
        );
      },
      data: (profile) {
        final isBuyer = profile.role == 'buyer';
        final isSeller = profile.role == 'seller';

        return Scaffold(
          backgroundColor: AppColors.white,
          bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.home),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(currentUserAccountProfileProvider);
                ref.invalidate(seasonalHighlightProvider);
                ref.invalidate(homeLatestTrufflesProvider);
                ref.invalidate(homeTopSellersProvider);
                ref.invalidate(sellerHomeStatsProvider);
                await ref.read(favoriteIdsNotifierProvider.notifier).load();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingL,
                ),
                children: [
                  if (isSeller)
                    _SellerTopBar(profile: profile)
                  else
                    const _BuyerTopBar(),
                  const SizedBox(height: AppSpacing.spacingM),
                  if (isBuyer) ...[
                    _BuyerGreeting(profile: profile),
                    const SizedBox(height: AppSpacing.spacingM),
                    const SeasonalHighlightSection(),
                    const SizedBox(height: AppSpacing.spacingL),
                  ] else if (isSeller) ...[
                    _SellerOverview(profile: profile),
                    const SizedBox(height: AppSpacing.spacingL),
                  ],
                  const _LatestTrufflesSection(),
                  const SizedBox(height: AppSpacing.spacingL),
                  const _TopSellersSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuyerTopBar extends StatelessWidget {
  const _BuyerTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HomeCircleIconButton(
          icon: Icons.person_outline_rounded,
          onPressed: () => context.push(AppRoutes.account),
        ),
        const Spacer(),
        _HomeCircleIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.spacingXS),
        _HomeCircleIconButton(
          icon: Icons.favorite_border_rounded,
          onPressed: () => context.push(AppRoutes.accountFavorites),
        ),
      ],
    );
  }
}

class _SellerTopBar extends StatelessWidget {
  const _SellerTopBar({required this.profile});

  final CurrentUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        _ProfileAvatar(profile: profile, size: 50),
        const SizedBox(width: AppSpacing.spacingXS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${l10n.homeGreetingPrefix},',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 16,
                  color: AppColors.black80,
                ),
              ),
              Text(
                _firstNameOrDisplay(profile),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _HomeCircleIconButton(
          icon: Icons.notifications_none_rounded,
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.spacingXS),
        _HomeCircleIconButton(
          icon: Icons.favorite_border_rounded,
          onPressed: () => context.push(AppRoutes.accountFavorites),
        ),
      ],
    );
  }
}

class _BuyerGreeting extends StatelessWidget {
  const _BuyerGreeting({required this.profile});

  final CurrentUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.homeGreetingPrefix},',
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w400,
            color: AppColors.black80,
            height: 1.05,
          ),
        ),
        Text(
          _firstNameOrDisplay(profile),
          style: AppTextStyles.authScreenTitle.copyWith(
            fontSize: 34,
            fontWeight: FontWeight.w500,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _SellerOverview extends ConsumerWidget {
  const _SellerOverview({required this.profile});

  final CurrentUserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(sellerHomeStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PublishTruffleCard(
          label: l10n.publishTruffleTitle,
          onTap: () {
            Navigator.of(context).push(
              buildPublishTruffleRoute(initialRegion: profile.region),
            );
          },
        ),
        const SizedBox(height: AppSpacing.spacingS),
        Row(
          children: [
            Expanded(
              child: _SellerStatCard(
                title: l10n.homeSellerOrdersInProgress,
                valueAsync: statsAsync.whenData((value) => value.inProgressOrdersCount),
                onTap: () => context.push(AppRoutes.accountOrders),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: _SellerStatCard(
                title: l10n.homeSellerActiveTruffles,
                valueAsync: statsAsync.whenData((value) => value.activeTrufflesCount),
                onTap: () => context.push(AppRoutes.accountMyTruffles),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PublishTruffleCard extends StatelessWidget {
  const _PublishTruffleCard({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.authField,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingL),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.black,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(
              label,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerStatCard extends StatelessWidget {
  const _SellerStatCard({
    required this.title,
    required this.valueAsync,
    required this.onTap,
  });

  final String title;
  final AsyncValue<int> valueAsync;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final valueText = valueAsync.when(
      data: (value) => value.toString(),
      loading: () => '--',
      error: (_, __) => '--',
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.black10),
          boxShadow: AppShadows.authField,
        ),
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    valueText,
                    style: AppTextStyles.authScreenTitle.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.north_east_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestTrufflesSection extends ConsumerWidget {
  const _LatestTrufflesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final trufflesAsync = ref.watch(homeLatestTrufflesProvider);
    final favoritesState = ref.watch(favoriteIdsNotifierProvider);
    final favoritesNotifier = ref.read(favoriteIdsNotifierProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionHeader(
          title: l10n.homeLatestNewsTitle,
          actionLabel: l10n.homeSeeAll,
          onActionTap: () => context.push(AppRoutes.truffles),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        trufflesAsync.when(
          loading: () => const _HorizontalSkeletonList(itemCount: 2, itemWidth: 214),
          error: (_, __) => _CompactSectionFallback(
            message: l10n.homeSectionErrorText,
            retryLabel: l10n.homeSeasonalRetryLabel,
            onRetry: () => ref.invalidate(homeLatestTrufflesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _CompactSectionFallback(message: l10n.homeLatestNewsEmpty);
            }

            return SizedBox(
              height: 322,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.spacingS),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SizedBox(
                    width: 214,
                    child: TruffleListingCard(
                      item: item,
                      isFavorite: favoritesState.ids.contains(item.id),
                      isFavoritePending: favoritesState.pendingIds.contains(item.id),
                      onTap: () => context.push(AppRoutes.truffleDetailPath(item.id)),
                      onFavoriteTap: () => favoritesNotifier.toggleFavorite(item.id),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TopSellersSection extends ConsumerWidget {
  const _TopSellersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final sellersAsync = ref.watch(homeTopSellersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HomeSectionHeader(
          title: l10n.homeTopSellersTitle,
          actionLabel: l10n.homeSeeAll,
          onActionTap: () => context.push(AppRoutes.sellers),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        sellersAsync.when(
          loading: () => const _HorizontalSkeletonList(itemCount: 3, itemWidth: 172, itemHeight: 248),
          error: (_, __) => _CompactSectionFallback(
            message: l10n.homeSectionErrorText,
            retryLabel: l10n.homeSeasonalRetryLabel,
            onRetry: () => ref.invalidate(homeTopSellersProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _CompactSectionFallback(message: l10n.homeTopSellersEmpty);
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < items.length; index++) ...[
                    SizedBox(
                      width: 172,
                      child: SellerListingCard(
                        item: items[index],
                        onTap: () => context.push(AppRoutes.sellerProfilePath(items[index].id)),
                      ),
                    ),
                    if (index != items.length - 1) const SizedBox(width: AppSpacing.spacingS),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 14,
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactSectionFallback extends StatelessWidget {
  const _CompactSectionFallback({
    required this.message,
    this.retryLabel,
    this.onRetry,
  });

  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ),
          if (retryLabel != null && onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel!),
            ),
        ],
      ),
    );
  }
}

class _HorizontalSkeletonList extends StatelessWidget {
  const _HorizontalSkeletonList({
    required this.itemCount,
    required this.itemWidth,
    this.itemHeight = 220,
  });

  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.spacingS),
        itemBuilder: (context, index) {
          return Container(
            width: itemWidth,
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppShadows.authField,
            ),
          );
        },
      ),
    );
  }
}

class _HomeCircleIconButton extends StatelessWidget {
  const _HomeCircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.softGrey,
          shape: BoxShape.circle,
          boxShadow: AppShadows.authField,
        ),
        child: IconButton(
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          icon: Icon(
            icon,
            size: 24,
            color: AppColors.black,
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.profile,
    required this.size,
  });

  final CurrentUserProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = profile.profileImageUrl?.trim();
    final canUseImage = url != null && url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true;

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
        shape: BoxShape.circle,
        boxShadow: AppShadows.authField,
      ),
      child: canUseImage
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _AvatarFallback(initials: profile.initials),
            )
          : _AvatarFallback(initials: profile.initials),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _firstNameOrDisplay(CurrentUserProfile profile) {
  final firstName = profile.firstName?.trim() ?? '';
  if (firstName.isNotEmpty) return firstName;
  return profile.displayName;
}
