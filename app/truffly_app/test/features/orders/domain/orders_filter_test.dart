import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';

void main() {
  group('OrdersFilter.matches', () {
    test('all matches every status', () {
      for (final status in OrderStatus.values) {
        expect(OrdersFilter.all.matches(status), isTrue);
      }
    });

    test('inProgress matches paid and shipped only', () {
      expect(OrdersFilter.inProgress.matches(OrderStatus.paid), isTrue);
      expect(OrdersFilter.inProgress.matches(OrderStatus.shipped), isTrue);
      expect(OrdersFilter.inProgress.matches(OrderStatus.completed), isFalse);
      expect(OrdersFilter.inProgress.matches(OrderStatus.cancelled), isFalse);
    });

    test('completed and cancelled match only their status', () {
      expect(OrdersFilter.completed.matches(OrderStatus.completed), isTrue);
      expect(OrdersFilter.completed.matches(OrderStatus.paid), isFalse);
      expect(OrdersFilter.cancelled.matches(OrderStatus.cancelled), isTrue);
      expect(OrdersFilter.cancelled.matches(OrderStatus.shipped), isFalse);
    });
  });
}
