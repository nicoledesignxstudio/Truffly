import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/listing_filter_button.dart';
import 'package:truffly_app/features/sellers/application/seller_listing_providers.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_filters.dart';
import 'package:truffly_app/features/sellers/domain/seller_listing_state.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_filters_sheet.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_listing_card.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_listing_empty_state.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_listing_skeleton.dart';
import 'package:truffly_app/features/sellers/presentation/widgets/seller_region_chips.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellersPage extends ConsumerStatefulWidget {
  const SellersPage({super.key});

  @override
  ConsumerState<SellersPage> createState() => _SellersPageState();
}

class _SellersPageState extends ConsumerState<SellersPage> {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sellerListingNotifierProvider);
    final notifier = ref.read(sellerListingNotifierProvider.notifier);

    if (_searchController.text != state.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

    final activeFilters = _buildActiveFilters(l10n, state);

    return Scaffold(
      bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.sellers),
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
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: Text(
          l10n.sellerPageTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              AppSpacing.spacingS,
              AppSpacing.spacingM,
              AppSpacing.spacingL,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthTextField(
                      controller: _searchController,
                      labelText: l10n.sellerSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) {
                        notifier.updateSearchQuery(_searchController.text.trim());
                      },
                      onChanged: (value) {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(const Duration(milliseconds: 350), () {
                          notifier.updateSearchQuery(value.trim());
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingXS),
                  ListingFilterButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      final draft = await showModalBottomSheet(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) {
                          return SellerFiltersSheet(
                            initialFilters: state.appliedFilters,
                          );
                        },
                      );

                      if (!mounted || draft == null) return;
                      await notifier.applyFilters(draft);
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingM),
              SellerRegionChips(
                selectedRegion: state.appliedFilters.selectedRegion,
                onSelected: (region) {
                  notifier.selectRegion(region);
                },
              ),
              if (activeFilters.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.spacingM),
                Wrap(
                  spacing: AppSpacing.spacingXS,
                  runSpacing: AppSpacing.spacingXS,
                  children: activeFilters,
                ),
              ],
              const SizedBox(height: AppSpacing.spacingM),
              if (state.isInitialLoading)
                const SellerListingSkeletonList()
              else if (state.failure != null && !state.hasItems)
                _FullPageError(onRetry: notifier.refresh)
              else if (state.isEmpty)
                SellerListingEmptyState(
                  showResetAction: state.hasActiveFilters,
                  onReset: () {
                    notifier.clearAllFilters();
                  },
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth =
                        (constraints.maxWidth - AppSpacing.spacingXS) / 2;

                    return Wrap(
                      spacing: AppSpacing.spacingXS,
                      runSpacing: AppSpacing.spacingXS,
                      children: [
                        for (final item in state.items)
                          SizedBox(
                            width: cardWidth,
                            child: SellerListingCard(
                              item: item,
                              onTap: () => context.push(
                                AppRoutes.sellerProfilePath(item.id),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              if (state.isLoadingMore) ...[
                const SizedBox(height: AppSpacing.spacingM),
                const Center(child: CircularProgressIndicator()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildActiveFilters(
    AppLocalizations l10n,
    SellerListingState state,
  ) {
    final notifier = ref.read(sellerListingNotifierProvider.notifier);
    final filters = state.appliedFilters;
    final widgets = <Widget>[];

    if (state.searchQuery.isNotEmpty) {
      widgets.add(
        _ActiveFilterChip(
          label: l10n.sellerActiveSearchFilter(state.searchQuery),
          onRemoved: () {
            notifier.clearSearch();
          },
        ),
      );
    }

    if (filters.rating != SellerRatingFilter.any) {
      widgets.add(
        _ActiveFilterChip(
          label: switch (filters.rating) {
            SellerRatingFilter.threePlus => l10n.sellerFilterRatingThreePlus,
            SellerRatingFilter.fourPlus => l10n.sellerFilterRatingFourPlus,
            SellerRatingFilter.five => l10n.sellerFilterRatingFive,
            SellerRatingFilter.any => '',
          },
          onRemoved: () {
            notifier.removeRatingFilter();
          },
        ),
      );
    }

    if (filters.completedOrders != SellerCompletedOrdersFilter.any) {
      widgets.add(
        _ActiveFilterChip(
          label: switch (filters.completedOrders) {
            SellerCompletedOrdersFilter.fivePlus =>
              l10n.sellerFilterCompletedOrdersFivePlus,
            SellerCompletedOrdersFilter.twentyPlus =>
              l10n.sellerFilterCompletedOrdersTwentyPlus,
            SellerCompletedOrdersFilter.fiftyPlus =>
              l10n.sellerFilterCompletedOrdersFiftyPlus,
            SellerCompletedOrdersFilter.any => '',
          },
          onRemoved: () {
            notifier.removeCompletedOrdersFilter();
          },
        ),
      );
    }

    return widgets;
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(sellerListingNotifierProvider.notifier).loadMore();
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemoved,
  });

  final String label;
  final VoidCallback onRemoved;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.spacingS,
          top: AppSpacing.spacingXS,
          right: 4,
          bottom: AppSpacing.spacingXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              height: 24,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onRemoved,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullPageError extends StatelessWidget {
  const _FullPageError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        children: [
          Text(
            l10n.sellerLoadError,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AuthPrimaryButton(
            label: l10n.truffleRetry,
            onPressed: () => onRetry(),
          ),
        ],
      ),
    );
  }
}
