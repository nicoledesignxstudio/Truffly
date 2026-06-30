import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/data/seller_stripe_onboarding_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/home/application/home_content_provider.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_section.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/notifications/application/notifications_providers.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';
import 'package:truffly_app/features/orders/domain/orders_scope.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_listing_card.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/presentation/publish_truffle_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _stripeRefreshScheduled = false;
  bool _stripeRefreshInFlight = false;
  bool _welcomeNotificationCheckScheduled = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);

    return profileAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) {
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
        final sellerStripeStatusAsync = ref.watch(
          currentSellerStripeStatusProvider,
        );
        final unreadNotificationCount =
            ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
        final sellerStripeStatus = sellerStripeStatusAsync.valueOrNull;
        final showSellerChrome = profile.isSellerRequestApproved;
        final showSellerDashboard =
            showSellerChrome && sellerStripeStatus?.isReady == true;
        final showSellerJourneyCard =
            showSellerChrome &&
            !profile.isSellerRequestPending &&
            !showSellerDashboard;
        final showStripeLoadingPlaceholder =
            showSellerJourneyCard &&
            (_stripeRefreshInFlight ||
                (sellerStripeStatusAsync.isLoading &&
                    sellerStripeStatus == null));

        _maybeScheduleStripeRefresh(
          profile: profile,
          stripeStatus: sellerStripeStatus,
        );
        _maybeEnsureBuyerWelcomeNotification(profile);

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
                ref.invalidate(currentSellerStripeStatusProvider);
                try {
                  await Future.wait([
                    ref.read(favoriteIdsNotifierProvider.notifier).load(),
                    ref.read(currentSellerStripeStatusProvider.future),
                  ]);
                } catch (_) {
                  // Refresh is best-effort; stale cards will update on the next successful fetch.
                }
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingL,
                ),
                children: [
                  if (showSellerChrome)
                    _SellerTopBar(
                      profile: profile,
                      unreadNotificationCount: unreadNotificationCount,
                    )
                  else
                    _BuyerTopBar(
                      unreadNotificationCount: unreadNotificationCount,
                    ),
                  const SizedBox(height: AppSpacing.spacingM),
                  if (showSellerChrome) ...[
                    if (profile.isSellerRequestPending)
                      const _SellerRequestPendingCard()
                    else if (showSellerDashboard) ...[
                      _SellerOverview(profile: profile),
                      const SizedBox(height: AppSpacing.spacingXS),
                    ] else if (showStripeLoadingPlaceholder)
                      const _SellerStripeStatusLoadingCard()
                    else if (showSellerJourneyCard)
                      _ApprovedSellerStripeCard(
                        hasStripeAccount:
                            sellerStripeStatus?.accountId?.trim().isNotEmpty ==
                            true,
                        isLoading:
                            sellerStripeStatusAsync.isLoading &&
                            sellerStripeStatusAsync.valueOrNull == null,
                        onOpenStripe: () =>
                            context.push(AppRoutes.accountBecomeSeller),
                      )
                    else
                      const SeasonalHighlightSection(),
                    const SizedBox(height: AppSpacing.spacingM),
                  ] else ...[
                    _BuyerGreeting(profile: profile),
                    const SizedBox(height: AppSpacing.spacingM),
                    if (profile.isSellerRequestPending)
                      const _SellerRequestPendingCard()
                    else if (showStripeLoadingPlaceholder)
                      const _SellerStripeStatusLoadingCard()
                    else if (showSellerJourneyCard)
                      _ApprovedSellerStripeCard(
                        hasStripeAccount:
                            sellerStripeStatus?.accountId?.trim().isNotEmpty ==
                            true,
                        isLoading:
                            sellerStripeStatusAsync.isLoading &&
                            sellerStripeStatusAsync.valueOrNull == null,
                        onOpenStripe: () =>
                            context.push(AppRoutes.accountBecomeSeller),
                      )
                    else
                      const SeasonalHighlightSection(),
                    const SizedBox(height: AppSpacing.spacingM),
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

  void _maybeScheduleStripeRefresh({
    required CurrentUserProfile profile,
    required SellerStripeStatusSnapshot? stripeStatus,
  }) {
    if (_stripeRefreshScheduled) return;
    if (!profile.isSellerRequestApproved) return;
    if (stripeStatus?.isReady == true) return;

    _stripeRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _stripeRefreshInFlight = true;
      });
    });
    unawaited(() async {
      try {
        await ref
            .read(sellerStripeOnboardingServiceProvider)
            .refreshSellerStripeStatus();
        ref.invalidate(currentSellerStripeStatusProvider);
      } catch (_) {
        // Best effort: the cached state is still usable while Stripe catches up.
      } finally {
        if (mounted) {
          setState(() {
            _stripeRefreshInFlight = false;
          });
        }
      }
    }());
  }

  void _maybeEnsureBuyerWelcomeNotification(CurrentUserProfile profile) {
    if (_welcomeNotificationCheckScheduled) return;
    if (!profile.onboardingCompleted) return;
    if (profile.role != 'buyer') return;

    _welcomeNotificationCheckScheduled = true;
    unawaited(() async {
      final created = await ref
          .read(localNotificationsServiceProvider)
          .ensureBuyerWelcomeNotification(userId: profile.userId);
      if (created) {
        ref.invalidate(notificationsInboxProvider);
      }
    }());
  }
}

class _BuyerTopBar extends StatelessWidget {
  const _BuyerTopBar({required this.unreadNotificationCount});

  final int unreadNotificationCount;

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
          badgeCount: unreadNotificationCount,
          onPressed: () => context.push(AppRoutes.notifications),
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
  const _SellerTopBar({
    required this.profile,
    required this.unreadNotificationCount,
  });

  final CurrentUserProfile profile;
  final int unreadNotificationCount;

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
          badgeCount: unreadNotificationCount,
          onPressed: () => context.push(AppRoutes.notifications),
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
    final titleStyle =
        Theme.of(context).textTheme.displayLarge ??
        AppTextStyles.authScreenTitle;
    final greetingStyle = titleStyle.copyWith(
      fontWeight: FontWeight.w400,
      color: AppColors.black80,
    );
    final nameStyle = titleStyle.copyWith(fontWeight: FontWeight.w500);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l10n.homeGreetingPrefix}, ', style: greetingStyle),
          TextSpan(text: _firstNameOrDisplay(profile), style: nameStyle),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SellerOverview extends ConsumerWidget {
  const _SellerOverview({required this.profile});

  final CurrentUserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final statsAsync = ref.watch(sellerHomeStatsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PublishTruffleCard(
          label: l10n.publishTruffleTitle,
          subtitle: isItalian
              ? 'Condividi i tuoi tartufi freschi'
              : 'Share your fresh truffles',
          onTap: () {
            Navigator.of(
              context,
            ).push(buildPublishTruffleRoute(initialRegion: profile.region));
          },
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        Row(
          children: [
            Expanded(
              child: _SellerStatCard(
                title: l10n.homeSellerOrdersInProgress,
                valueAsync: statsAsync.whenData(
                  (value) => value.inProgressOrdersCount,
                ),
                onTap: () {
                  ref.read(ordersScopeProvider.notifier).state =
                      OrdersScope.sales;
                  ref.read(ordersFilterProvider.notifier).state =
                      OrdersFilter.inProgress;
                  context.push(AppRoutes.accountOrders);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.spacingXS),
            Expanded(
              child: _SellerStatCard(
                title: l10n.homeSellerActiveTruffles,
                valueAsync: statsAsync.whenData(
                  (value) => value.activeTrufflesCount,
                ),
                onTap: () => context.push(AppRoutes.accountMyTruffles),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SellerRequestPendingCard extends StatelessWidget {
  const _SellerRequestPendingCard();

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return _StatusNoticeCard(
      icon: Icons.hourglass_bottom_rounded,
      title: isItalian ? 'Richiesta in revisione' : 'Request under review',
      titleFontSize: 15,
      body: isItalian
          ? 'Stiamo verificando il tuo profilo per permetterti di iniziare a vendere su Truffly. Ti aggiorneremo il prima possibile.'
          : 'We are reviewing your profile so you can start selling on Truffly. We will update you as soon as possible.',
    );
  }
}

class _ApprovedSellerStripeCard extends StatelessWidget {
  const _ApprovedSellerStripeCard({
    required this.hasStripeAccount,
    required this.isLoading,
    required this.onOpenStripe,
  });

  final bool hasStripeAccount;
  final bool isLoading;
  final VoidCallback onOpenStripe;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return _StripeSetupCard(
      title: isItalian ? 'Richiesta approvata!' : 'Request approved!',
      body: isItalian
          ? (hasStripeAccount
                ? 'Stripe sta ancora verificando il tuo account. Puoi gestire la verifica da Stripe.'
                : 'Come ultimo passaggio, completa la registrazione Stripe per attivare pagamenti, incassi e trasferimenti.')
          : (hasStripeAccount
                ? 'Stripe is still verifying your account. You can manage verification directly in Stripe.'
                : 'As a final step, complete your Stripe registration to activate payments, payouts, and transfers.'),
      actionLabel: isLoading
          ? (isItalian ? 'Verifica in corso...' : 'Checking...')
          : hasStripeAccount
          ? (isItalian
                ? 'Gestisci verifica Stripe'
                : 'Manage Stripe verification')
          : (isItalian ? 'Registrati' : 'Register'),
      onActionTap: isLoading ? null : onOpenStripe,
      isBusy: isLoading,
    );
  }
}

class _SellerStripeStatusLoadingCard extends StatelessWidget {
  const _SellerStripeStatusLoadingCard();

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return _StatusNoticeCard(
      icon: Icons.hourglass_top_rounded,
      title: isItalian ? 'Controllo Stripe...' : 'Checking Stripe...',
      body: isItalian
          ? 'Stiamo verificando lo stato del tuo account. Tra poco vedrai il layout corretto.'
          : 'We are checking your account status. The correct layout will appear shortly.',
    );
  }
}

class _PublishTruffleCard extends StatelessWidget {
  const _PublishTruffleCard({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXXS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.78),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusNoticeCard extends StatelessWidget {
  const _StatusNoticeCard({
    required this.icon,
    required this.title,
    required this.body,
    this.titleFontSize = 16,
  });

  final IconData icon;
  final String title;
  final String body;
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.black, size: 21),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    maxLines: 2,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXXS),
                  Text(
                    body,
                    softWrap: true,
                    maxLines: 4,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.spacingXS),
          ],
        ),
      ),
    );
  }
}

class _StripeSetupCard extends StatelessWidget {
  const _StripeSetupCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onActionTap,
    required this.isBusy,
  });

  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.black,
                size: 21,
              ),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXXS),
                  Text(
                    body,
                    softWrap: true,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: onActionTap,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacingM,
                          vertical: 14,
                        ),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        actionLabel,
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isBusy) ...[
              const SizedBox(width: AppSpacing.spacingXS),
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              ),
            ],
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
      error: (_, _) => '--',
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.softGrey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    title ==
                            AppLocalizations.of(
                              context,
                            )!.homeSellerOrdersInProgress
                        ? Icons.local_mall_outlined
                        : Icons.inventory_2_outlined,
                    size: 22,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingXS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: AppColors.black80,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valueText,
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
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
          loading: () =>
              const _HorizontalSkeletonList(itemCount: 2, itemWidth: 202),
          error: (_, _) => _CompactSectionFallback(
            message: l10n.homeSectionErrorText,
            retryLabel: l10n.homeSeasonalRetryLabel,
            onRetry: () => ref.invalidate(homeLatestTrufflesProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _CompactSectionFallback(message: l10n.homeLatestNewsEmpty);
            }

            return SizedBox(
              height: 288,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.spacingS),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return SizedBox(
                    width: 204,
                    child: TruffleListingCard(
                      variant: TruffleListingCardVariant.home,
                      item: item,
                      isFavorite: favoritesState.ids.contains(item.id),
                      isFavoritePending: favoritesState.pendingIds.contains(
                        item.id,
                      ),
                      onTap: () =>
                          context.push(AppRoutes.truffleDetailPath(item.id)),
                      onFavoriteTap: () =>
                          favoritesNotifier.toggleFavorite(item.id),
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
          loading: () => const _HorizontalSkeletonList(
            itemCount: 3,
            itemWidth: 172,
            itemHeight: 248,
          ),
          error: (_, _) => _CompactSectionFallback(
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
                        onTap: () => context.push(
                          AppRoutes.sellerProfilePath(items[index].id),
                        ),
                      ),
                    ),
                    if (index != items.length - 1)
                      const SizedBox(width: AppSpacing.spacingS),
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
              fontSize: 16,
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
              fontSize: 13,
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
            TextButton(onPressed: onRetry, child: Text(retryLabel!)),
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
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.spacingS),
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
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppSpacing.circularIconButtonSize,
      height: AppSpacing.circularIconButtonSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.softGrey,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onPressed,
              padding: EdgeInsets.zero,
              icon: Icon(
                icon,
                size: AppSpacing.circularIconSize,
                color: AppColors.black,
              ),
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile, required this.size});

  final CurrentUserProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = profile.profileImageUrl?.trim();
    final canUseImage =
        url != null && url.isNotEmpty && Uri.tryParse(url)?.hasScheme == true;

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
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  _AvatarFallback(initials: profile.initials),
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
