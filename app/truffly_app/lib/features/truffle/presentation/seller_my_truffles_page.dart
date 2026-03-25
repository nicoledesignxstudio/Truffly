import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_skeleton.dart';
import 'package:truffly_app/features/truffle/application/seller_managed_truffle_providers.dart';
import 'package:truffly_app/features/truffle/data/seller_managed_truffle_service.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_item.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/seller_managed_truffle_card.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerMyTrufflesPage extends ConsumerStatefulWidget {
  const SellerMyTrufflesPage({super.key});

  @override
  ConsumerState<SellerMyTrufflesPage> createState() => _SellerMyTrufflesPageState();
}

class _SellerMyTrufflesPageState extends ConsumerState<SellerMyTrufflesPage> {
  final Set<String> _optimisticallyRemovedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedTab = ref.watch(sellerManagedTruffleTabProvider);
    final trufflesAsync = ref.watch(sellerManagedTrufflesProvider);
    final allItems = trufflesAsync.valueOrNull ?? const <SellerManagedTruffleItem>[];
    final filteredItems = allItems
        .where(
          (item) =>
              item.status == selectedTab && !_optimisticallyRemovedIds.contains(item.id),
        )
        .toList(growable: false);
    final isInitialLoading = trufflesAsync.isLoading && trufflesAsync.valueOrNull == null;

    return Scaffold(
      backgroundColor: AppColors.white,
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
                context.go(AppRoutes.account);
              }
            },
          ),
        ),
        title: Text(
          l10n.sellerMyTrufflesTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sellerManagedTrufflesProvider);
          await ref.read(sellerManagedTrufflesProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingL,
          ),
          children: [
            _StatusTabs(
              selectedTab: selectedTab,
              onSelected: (value) {
                ref.read(sellerManagedTruffleTabProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: AppSpacing.spacingM),
            if (isInitialLoading)
              const TruffleListingSkeletonGrid()
            else if (trufflesAsync.hasError && trufflesAsync.valueOrNull == null)
              _ErrorState(
                onRetry: () {
                  ref.invalidate(sellerManagedTrufflesProvider);
                },
              )
            else if (filteredItems.isEmpty)
              _EmptyState(status: selectedTab)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.spacingXS,
                  crossAxisSpacing: AppSpacing.spacingXS,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return _SellerManagedTruffleGridCard(
                    item: item,
                    onDeleteTap: item.status == SellerManagedTruffleStatus.active
                        ? () => _confirmDelete(context, ref, item)
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SellerManagedTruffleItem item,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.sellerMyTrufflesDeleteTitle),
          content: Text(l10n.sellerMyTrufflesDeleteMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.sellerMyTrufflesDeleteCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.sellerMyTrufflesDeleteConfirm),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) return;

    try {
      await ref.read(sellerManagedTruffleDeleteProvider.notifier).deleteTruffle(
        item.id,
      );
      if (mounted) {
        setState(() {
          _optimisticallyRemovedIds.add(item.id);
        });
      }
      unawaited(_silentRefresh());
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.sellerMyTrufflesDeleteSuccess)),
      );
    } on SellerManagedTruffleDeleteException catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_deleteErrorText(l10n, error))),
      );
    }
  }

  Future<void> _silentRefresh() async {
    ref.invalidate(sellerManagedTrufflesProvider);
    try {
      await ref.read(sellerManagedTrufflesProvider.future);
      if (!mounted) return;
      final freshIds = (ref.read(sellerManagedTrufflesProvider).valueOrNull ?? const <SellerManagedTruffleItem>[])
          .map((item) => item.id)
          .toSet();
      setState(() {
        _optimisticallyRemovedIds.removeWhere(freshIds.contains);
      });
    } catch (_) {
      // Keep optimistic UI state; user can still pull-to-refresh.
    }
  }

  String _deleteErrorText(
    AppLocalizations l10n,
    SellerManagedTruffleDeleteException error,
  ) {
    if (error.code == 'truffle_has_orders' || error.code == 'truffle_not_active') {
      return l10n.sellerMyTrufflesDeleteForbidden;
    }

    return switch (error.failure) {
      SellerManagedTruffleFailure.network => l10n.sellerMyTrufflesDeleteNetwork,
      SellerManagedTruffleFailure.unauthenticated =>
        l10n.sellerMyTrufflesDeleteUnauthenticated,
      SellerManagedTruffleFailure.forbidden =>
        l10n.sellerMyTrufflesDeleteForbidden,
      SellerManagedTruffleFailure.unknown =>
        l10n.sellerMyTrufflesDeleteUnknown,
    };
  }
}

class _SellerManagedTruffleGridCard extends ConsumerWidget {
  const _SellerManagedTruffleGridCard({
    required this.item,
    required this.onDeleteTap,
  });

  final SellerManagedTruffleItem item;
  final VoidCallback? onDeleteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeletePending = ref.watch(
      sellerManagedTruffleDeleteProvider.select((pending) => pending.contains(item.id)),
    );

    return SellerManagedTruffleCard(
      item: item,
      onTap: item.status == SellerManagedTruffleStatus.active
          ? () => context.push(AppRoutes.truffleDetailPath(item.id))
          : null,
      isDeletePending: isDeletePending,
      onDeleteTap: onDeleteTap,
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({
    required this.selectedTab,
    required this.onSelected,
  });

  final SellerManagedTruffleStatus selectedTab;
  final ValueChanged<SellerManagedTruffleStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < SellerManagedTruffleStatus.values.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.spacingXS),
            _StatusChip(
              label: switch (SellerManagedTruffleStatus.values[index]) {
                SellerManagedTruffleStatus.active => l10n.sellerMyTrufflesTabActive,
                SellerManagedTruffleStatus.sold => l10n.sellerMyTrufflesTabSold,
                SellerManagedTruffleStatus.expired => l10n.sellerMyTrufflesTabExpired,
              },
              selected: selectedTab == SellerManagedTruffleStatus.values[index],
              onTap: () => onSelected(SellerManagedTruffleStatus.values[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.black : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(
          color: selected ? AppColors.black : AppColors.black10,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black10,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.authBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM + 2,
              vertical: AppSpacing.spacingS,
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.black80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.status});

  final SellerManagedTruffleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (title, subtitle) = switch (status) {
      SellerManagedTruffleStatus.active => (
          l10n.sellerMyTrufflesEmptyActiveTitle,
          l10n.sellerMyTrufflesEmptyActiveSubtitle,
        ),
      SellerManagedTruffleStatus.sold => (
          l10n.sellerMyTrufflesEmptySoldTitle,
          l10n.sellerMyTrufflesEmptySoldSubtitle,
        ),
      SellerManagedTruffleStatus.expired => (
          l10n.sellerMyTrufflesEmptyExpiredTitle,
          l10n.sellerMyTrufflesEmptyExpiredSubtitle,
        ),
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacingXL),
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: AppColors.black50,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.spacingXL),
          Text(
            l10n.sellerMyTrufflesLoadError,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AuthPrimaryButton(
            label: l10n.sellerMyTrufflesRetry,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
