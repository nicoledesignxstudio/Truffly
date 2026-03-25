import 'package:truffly_app/features/account/domain/shipping_address.dart';

enum ShippingAddressesStatus { loading, ready }

final class ShippingAddressesState {
  const ShippingAddressesState({
    required this.status,
    required this.items,
    required this.errorMessage,
    required this.pendingDeleteId,
  });

  const ShippingAddressesState.loading()
      : status = ShippingAddressesStatus.loading,
        items = const <ShippingAddress>[],
        errorMessage = null,
        pendingDeleteId = null;

  final ShippingAddressesStatus status;
  final List<ShippingAddress> items;
  final String? errorMessage;
  final String? pendingDeleteId;

  bool get isLoading => status == ShippingAddressesStatus.loading;

  ShippingAddressesState copyWith({
    ShippingAddressesStatus? status,
    List<ShippingAddress>? items,
    Object? errorMessage = _sentinel,
    Object? pendingDeleteId = _sentinel,
  }) {
    return ShippingAddressesState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      pendingDeleteId: identical(pendingDeleteId, _sentinel)
          ? this.pendingDeleteId
          : pendingDeleteId as String?,
    );
  }
}

const _sentinel = Object();
