import 'dart:async';

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
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/marketplace/application/marketplace_providers.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_filters_sheet.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_empty_state.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_skeleton.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_type_chips.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_providers.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/seller_publish_gate_state.dart';
import 'package:truffly_app/features/truffle/presentation/publish_truffle_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TrufflesPage extends ConsumerStatefulWidget {
  const TrufflesPage({super.key});

  @override
  ConsumerState<TrufflesPage> createState() => _TrufflesPageState();
}

class _TrufflesPageState extends ConsumerState<TrufflesPage> {
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
    final state = ref.watch(truffleListingNotifierProvider);
    final notifier = ref.read(truffleListingNotifierProvider.notifier);
    final favoriteState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);
    final publishGateState = ref.watch(currentSellerPublishGateStateProvider);
    final sellerRegion = publishGateState.region;

    if (_searchController.text != state.searchQuery) {
      _searchController.value = _searchController.value.copyWith(
        text: state.searchQuery,
        selection: TextSelection.collapsed(offset: state.searchQuery.length),
      );
    }

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
          l10n.trufflePageTitle,
          style: AppTextStyles.sectionTitle,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentSellerPublishAccessProvider);
          await notifier.refresh();
        },
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
                    labelText: l10n.truffleSearchHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: (_) => notifier.updateSearchQuery(_searchController.text),
                    onChanged: (value) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(const Duration(milliseconds: 350), () {
                        notifier.updateSearchQuery(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingXS),
                _FilterButton(
                  onPressed: () async {
                    final draft = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppRadii.auth),
                        ),
                      ),
                      builder: (context) {
                        return TruffleFiltersSheet(
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
            if (publishGateState.isError) ...[
              _PublishAccessErrorBanner(
                message: l10n.publishTruffleAccessError,
                retryLabel: l10n.truffleRetry,
                onRetry: _retryPublishGateCheck,
              ),
              const SizedBox(height: AppSpacing.spacingM),
            ],
            TruffleTypeChips(
              selectedType: state.appliedFilters.selectedType,
              onSelected: notifier.selectTypeChip,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            if (state.isInitialLoading)
              const TruffleListingSkeletonGrid()
            else if (state.failure != null && !state.hasItems)
              _FullPageError(onRetry: notifier.refresh)
            else if (state.isEmpty)
              const TruffleListingEmptyState()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.spacingXS,
                  crossAxisSpacing: AppSpacing.spacingXS,
                  childAspectRatio: 0.66,
                ),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return TruffleListingCard(
                    item: item,
                    isFavorite: favoriteState.ids.contains(item.id),
                    isFavoritePending: favoriteState.pendingIds.contains(item.id),
                    onTap: () => context.push(AppRoutes.truffleDetailPath(item.id)),
                    onFavoriteTap: () => favoriteNotifier.toggleFavorite(item.id),
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
      floatingActionButton: _buildPublishFloatingActionButton(
        publishGateState: publishGateState,
        sellerRegion: sellerRegion,
        notifier: notifier,
      ),
    );
  }

  Widget? _buildPublishFloatingActionButton({
    required SellerPublishGateState publishGateState,
    required String? sellerRegion,
    required dynamic notifier,
  }) {
    switch (publishGateState.status) {
      case SellerPublishGateStatus.loading:
        return FloatingActionButton.small(
          heroTag: 'publish_truffle_loading_fab',
          onPressed: null,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        );
      case SellerPublishGateStatus.notAllowed:
        return null;
      case SellerPublishGateStatus.error:
        return FloatingActionButton.small(
          heroTag: 'publish_truffle_retry_fab',
          onPressed: _retryPublishGateCheck,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.black,
          child: const Icon(Icons.refresh_rounded),
        );
      case SellerPublishGateStatus.allowed:
        return FloatingActionButton(
          onPressed: () async {
            final didPublish = await Navigator.of(context).push<bool>(
              buildPublishTruffleRoute(initialRegion: sellerRegion),
            );

            if (!mounted || didPublish != true) return;
            ref.invalidate(currentSellerPublishAccessProvider);
            await notifier.refresh();
          },
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.white,
          child: const Icon(Icons.add_rounded),
        );
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(truffleListingNotifierProvider.notifier).loadMore();
    }
  }

  void _retryPublishGateCheck() {
    ref.invalidate(currentSellerPublishAccessProvider);
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: 56,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: AppRadii.authBorderRadius,
          boxShadow: AppShadows.authField,
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.tune_rounded),
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
            l10n.truffleLoadError,
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

class _PublishAccessErrorBanner extends StatelessWidget {
  const _PublishAccessErrorBanner({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}
