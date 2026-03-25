import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/orders/data/orders_service.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_summary.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';
import 'package:truffly_app/features/orders/domain/orders_scope.dart';

final ordersServiceProvider = Provider<OrdersService>((ref) {
  return OrdersService(ref.read(supabaseClientProvider));
});

final currentUserOrdersProvider = FutureProvider<List<OrderSummary>>((ref) {
  return ref.read(ordersServiceProvider).fetchCurrentUserOrders();
});

final orderDetailProvider = FutureProvider.family<OrderDetail, String>((
  ref,
  orderId,
) {
  return ref.read(ordersServiceProvider).fetchOrderDetail(orderId);
});

final ordersFilterProvider = StateProvider<OrdersFilter>((ref) {
  return OrdersFilter.all;
});

final ordersScopeProvider = StateProvider<OrdersScope>((ref) {
  return OrdersScope.purchases;
});

final orderMutationProvider =
    NotifierProvider<OrderMutationNotifier, Set<String>>(
      OrderMutationNotifier.new,
    );

final class OrderMutationNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  Future<void> confirmReceipt(String orderId) async {
    await _run(orderId, () {
      return ref.read(ordersServiceProvider).confirmReceipt(orderId);
    });
  }

  Future<void> markAsShipped(String orderId, String trackingCode) async {
    await _run(orderId, () {
      return ref
          .read(ordersServiceProvider)
          .markAsShipped(orderId, trackingCode);
    });
  }

  Future<void> cancelOrder(String orderId) async {
    await _run(orderId, () {
      return ref.read(ordersServiceProvider).cancelOrder(orderId);
    });
  }

  Future<void> _run(String orderId, Future<void> Function() task) async {
    if (state.contains(orderId)) return;
    state = {...state, orderId};
    try {
      await task();
      ref.invalidate(currentUserOrdersProvider);
      ref.invalidate(orderDetailProvider(orderId));
    } finally {
      final next = Set<String>.from(state)..remove(orderId);
      state = next;
    }
  }
}
