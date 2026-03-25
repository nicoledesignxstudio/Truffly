import 'package:truffly_app/features/orders/domain/order_status.dart';

enum OrdersFilter {
  all,
  inProgress,
  completed,
  cancelled;

  bool matches(OrderStatus status) {
    return switch (this) {
      OrdersFilter.all => true,
      OrdersFilter.inProgress =>
        status == OrderStatus.paid || status == OrderStatus.shipped,
      OrdersFilter.completed => status == OrderStatus.completed,
      OrdersFilter.cancelled => status == OrderStatus.cancelled,
    };
  }
}
