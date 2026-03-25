import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_addresses_state.dart';

final shippingAddressesNotifierProvider = AutoDisposeNotifierProvider<
  ShippingAddressesNotifier,
  ShippingAddressesState
>(ShippingAddressesNotifier.new);

final class ShippingAddressesNotifier
    extends AutoDisposeNotifier<ShippingAddressesState> {
  @override
  ShippingAddressesState build() {
    Future.microtask(load);
    return const ShippingAddressesState.loading();
  }

  Future<void> load() async {
    final previousItems = state.items;
    state = state.copyWith(
      status: ShippingAddressesStatus.loading,
      items: previousItems,
      errorMessage: null,
      pendingDeleteId: null,
    );

    try {
      final items = await ref.read(shippingAddressesServiceProvider).fetchAddresses();
      state = ShippingAddressesState(
        status: ShippingAddressesStatus.ready,
        items: items,
        errorMessage: null,
        pendingDeleteId: null,
      );
    } on ShippingAddressesException catch (error) {
      state = ShippingAddressesState(
        status: ShippingAddressesStatus.ready,
        items: previousItems,
        errorMessage: _mapFailureToMessage(error.failure),
        pendingDeleteId: null,
      );
    }
  }

  Future<bool> deleteAddress(String addressId) async {
    state = state.copyWith(
      pendingDeleteId: addressId,
      errorMessage: null,
    );

    try {
      await ref.read(shippingAddressesServiceProvider).deleteAddress(addressId);
      final nextItems = state.items.where((item) => item.id != addressId).toList();
      state = state.copyWith(
        items: nextItems,
        pendingDeleteId: null,
      );
      await load();
      return true;
    } on ShippingAddressesException catch (error) {
      state = state.copyWith(
        pendingDeleteId: null,
        errorMessage: _mapFailureToMessage(error.failure),
      );
      return false;
    }
  }

  String _mapFailureToMessage(ShippingAddressesFailure failure) {
    return switch (failure) {
      ShippingAddressesFailure.network => 'network',
      ShippingAddressesFailure.unauthorized => 'unauthorized',
      ShippingAddressesFailure.notFound => 'not_found',
      ShippingAddressesFailure.validation => 'validation',
      ShippingAddressesFailure.unknown => 'unknown',
    };
  }
}
