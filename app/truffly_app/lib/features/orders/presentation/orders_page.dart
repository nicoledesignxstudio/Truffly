import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/domain/order_summary.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';
import 'package:truffly_app/features/orders/domain/orders_scope.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_card.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_filter_chip_group.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);

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
          orderPageTitle(context),
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          final isSeller = profile.isSeller;
          final scope = ref.watch(ordersScopeProvider);
          final filter = ref.watch(ordersFilterProvider);
          final ordersAsync = ref.watch(currentUserOrdersProvider);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentUserOrdersProvider);
              await ref.read(currentUserOrdersProvider.future);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacingM,
                AppSpacing.spacingS,
                AppSpacing.spacingM,
                AppSpacing.spacingL,
              ),
              children: [
                if (isSeller) ...[
                  _ScopeTabs(
                    selectedScope: scope,
                    onSelected: (value) {
                      ref.read(ordersScopeProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                ],
                OrderFilterChipGroup(
                  selectedFilter: filter,
                  onSelected: (value) {
                    ref.read(ordersFilterProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: AppSpacing.spacingM),
                ordersAsync.when(
                  data: (orders) {
                    final visible = _filterOrders(
                      orders: orders,
                      userId: profile.userId,
                      isSeller: isSeller,
                      scope: scope,
                      filter: filter,
                    );

                    if (visible.isEmpty) {
                      return _EmptyState(
                        filter: filter,
                        isSalesScope: isSeller && scope == OrdersScope.sales,
                      );
                    }

                    return Column(
                      children: [
                        for (
                          var index = 0;
                          index < visible.length;
                          index++
                        ) ...[
                          OrderCard(
                            key: ValueKey('order-card-${visible[index].id}'),
                            order: visible[index],
                            isSalesScope:
                                isSeller && scope == OrdersScope.sales,
                            onTap: () {
                              context.push(
                                AppRoutes.accountOrderDetailPath(
                                  visible[index].id,
                                ),
                              );
                            },
                          ),
                          if (index != visible.length - 1)
                            const SizedBox(height: AppSpacing.spacingS),
                        ],
                      ],
                    );
                  },
                  loading: () => const _LoadingState(),
                  error: (_, _) => _ErrorState(
                    onRetry: () {
                      ref.invalidate(currentUserOrdersProvider);
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Text(
              ordersLoadError(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }

  List<OrderSummary> _filterOrders({
    required List<OrderSummary> orders,
    required String userId,
    required bool isSeller,
    required OrdersScope scope,
    required OrdersFilter filter,
  }) {
    final scoped = orders.where((order) {
      if (!isSeller) return order.buyerId == userId;
      return scope == OrdersScope.sales
          ? order.sellerId == userId
          : order.buyerId == userId;
    });

    return scoped
        .where((order) => filter.matches(order.status))
        .toList(growable: false);
  }
}

class _ScopeTabs extends StatelessWidget {
  const _ScopeTabs({required this.selectedScope, required this.onSelected});

  final OrdersScope selectedScope;
  final ValueChanged<OrdersScope> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ScopeTab(
            label: ordersScopeLabel(context, false),
            selected: selectedScope == OrdersScope.purchases,
            onTap: () => onSelected(OrdersScope.purchases),
          ),
        ),
        const SizedBox(width: AppSpacing.spacingXS),
        Expanded(
          child: _ScopeTab(
            label: ordersScopeLabel(context, true),
            selected: selectedScope == OrdersScope.sales,
            onTap: () => onSelected(OrdersScope.sales),
          ),
        ),
      ],
    );
  }
}

class _ScopeTab extends StatelessWidget {
  const _ScopeTab({
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? AppColors.black : AppColors.black10,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacingS),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? AppColors.white : AppColors.black80,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == 3 ? 0 : AppSpacing.spacingS,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const SizedBox(height: 124),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter, required this.isSalesScope});

  final OrdersFilter filter;
  final bool isSalesScope;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingL,
        vertical: AppSpacing.spacingXXL,
      ),
      child: Column(
        children: [
          Icon(
            isSalesScope
                ? Icons.inventory_2_outlined
                : Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.black50,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            ordersEmptyTitle(
              context,
              filter: filter,
              isSalesScope: isSalesScope,
            ),
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            ordersEmptySubtitle(
              context,
              filter: filter,
              isSalesScope: isSalesScope,
            ),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      child: Column(
        children: [
          Text(
            ordersLoadError(context),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AuthPrimaryButton(label: retryLabel(context), onPressed: onRetry),
        ],
      ),
    );
  }
}
