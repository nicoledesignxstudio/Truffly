import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_notifier.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';

class _FakeShippingAddressesService implements ShippingAddressesService {
  _FakeShippingAddressesService(this.addresses);

  List<ShippingAddress> addresses;

  @override
  Future<void> deleteAddress(String addressId) async {
    final deletedWasDefault = addresses.any(
      (item) => item.id == addressId && item.isDefault,
    );
    addresses = addresses.where((item) => item.id != addressId).toList();
    if (deletedWasDefault && addresses.isNotEmpty) {
      final replacementId = addresses.first.id;
      addresses = [
        for (final item in addresses)
          item.copyWith(isDefault: item.id == replacementId),
      ];
    }
  }

  @override
  Future<ShippingAddress> fetchAddressById(String addressId) async {
    return addresses.firstWhere((item) => item.id == addressId);
  }

  @override
  Future<List<ShippingAddress>> fetchAddresses() async => addresses;

  @override
  Future<ShippingAddress> saveAddress(ShippingAddressFormData form) async {
    throw UnimplementedError();
  }
}

ShippingAddress _address({
  required String id,
  required bool isDefault,
}) {
  return ShippingAddress(
    id: id,
    userId: 'u1',
    fullName: 'Mario Rossi',
    street: 'Via Roma 10',
    city: 'Firenze',
    postalCode: '50100',
    countryCode: 'IT',
    phone: '+39 333 1234567',
    isDefault: isDefault,
    createdAt: DateTime.utc(2026, 3, 20),
  );
}

Future<void> _pumpLoadedState(ProviderContainer container) async {
  container.read(shippingAddressesNotifierProvider);
  await Future<void>.microtask(() {});
  await Future<void>.microtask(() {});
}

void main() {
  test('delete refreshes list and promotes another address to default', () async {
    final service = _FakeShippingAddressesService([
      _address(id: 'a1', isDefault: true),
      _address(id: 'a2', isDefault: false).copyWith(
        fullName: 'Luigi Bianchi',
      ),
    ]);
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container);

    final notifier = container.read(shippingAddressesNotifierProvider.notifier);
    final didDelete = await notifier.deleteAddress('a1');
    final state = container.read(shippingAddressesNotifierProvider);

    expect(didDelete, isTrue);
    expect(state.items, hasLength(1));
    expect(state.items.single.id, 'a2');
    expect(state.items.single.isDefault, isTrue);
  });
}
