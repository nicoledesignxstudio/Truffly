import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/shipping_address_form_notifier.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_state.dart';

class _FakeShippingAddressesService implements ShippingAddressesService {
  List<ShippingAddress> addresses;

  _FakeShippingAddressesService({required this.addresses});

  ShippingAddressFormData? lastSavedForm;
  String? lastDeletedId;

  @override
  Future<void> deleteAddress(String addressId) async {
    lastDeletedId = addressId;
    final deletedWasDefault = addresses.any(
      (item) => item.id == addressId && item.isDefault,
    );
    addresses = addresses.where((item) => item.id != addressId).toList();
    if (deletedWasDefault && addresses.isNotEmpty) {
      final firstId = addresses.first.id;
      addresses = [
        for (final item in addresses)
          item.copyWith(isDefault: item.id == firstId),
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
    lastSavedForm = form.normalized();
    final savedAddress = ShippingAddress(
      id: form.id ?? 'new-id',
      userId: 'u1',
      fullName: form.fullName.trim(),
      street: form.street.trim(),
      city: form.city.trim(),
      postalCode: form.postalCode.trim(),
      countryCode: form.countryCode.trim().toUpperCase(),
      phone: form.phone.trim(),
      isDefault: addresses.isEmpty ? true : form.isDefault,
      createdAt: DateTime.utc(2026, 3, 22),
    );

    addresses = [
      for (final item in addresses)
        if (savedAddress.isDefault)
          item.copyWith(isDefault: item.id == savedAddress.id ? true : false)
        else
          item,
      if (!addresses.any((item) => item.id == savedAddress.id)) savedAddress,
    ];

    return savedAddress;
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

Future<void> _pumpLoadedState(
  ProviderContainer container,
  String? addressId,
) async {
  container.read(shippingAddressFormNotifierProvider(addressId));
  await Future<void>.microtask(() {});
  await Future<void>.microtask(() {});
}

void main() {
  test('new address requires all mandatory fields before save', () async {
    final service = _FakeShippingAddressesService(addresses: []);
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container, null);

    final notifier = container.read(
      shippingAddressFormNotifierProvider(null).notifier,
    );

    final didSave = await notifier.save();

    expect(didSave, isFalse);
    expect(
      notifier.errorFor(ShippingAddressField.fullName),
      'required',
    );
    expect(
      notifier.errorFor(ShippingAddressField.countryCode),
      'country_required',
    );
  });

  test('saving first address keeps it as default even when toggle is off', () async {
    final service = _FakeShippingAddressesService(addresses: []);
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container, null);

    final notifier = container.read(
      shippingAddressFormNotifierProvider(null).notifier,
    );
    notifier.updateFullName('  Luigi Bianchi  ');
    notifier.updateStreet(' Via Milano 15 ');
    notifier.updateCity(' Bologna ');
    notifier.updatePostalCode(' 40100 ');
    notifier.updateCountryCode('it');
    notifier.updatePhone(' +39 320 0000000 ');

    final didSave = await notifier.save();
    final state = container.read(shippingAddressFormNotifierProvider(null));

    expect(didSave, isTrue);
    expect(service.lastSavedForm?.fullName, 'Luigi Bianchi');
    expect(state.lastSavedAddress?.isDefault, isTrue);
  });

  test('non-European country codes are rejected', () async {
    final service = _FakeShippingAddressesService(addresses: []);
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container, null);

    final notifier = container.read(
      shippingAddressFormNotifierProvider(null).notifier,
    );
    notifier.updateFullName('Luigi Bianchi');
    notifier.updateStreet('Via Milano 15');
    notifier.updateCity('Bologna');
    notifier.updatePostalCode('40100');
    notifier.updateCountryCode('US');
    notifier.updatePhone('+1 320 0000000');

    final didSave = await notifier.save();

    expect(didSave, isFalse);
    expect(
      notifier.errorFor(ShippingAddressField.countryCode),
      'country_invalid',
    );
  });

  test('editing existing address can delete it', () async {
    final service = _FakeShippingAddressesService(
      addresses: [_address(id: 'a1', isDefault: true)],
    );
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container, 'a1');

    final notifier = container.read(
      shippingAddressFormNotifierProvider('a1').notifier,
    );
    final didDelete = await notifier.delete();
    final state = container.read(shippingAddressFormNotifierProvider('a1'));

    expect(didDelete, isTrue);
    expect(service.lastDeletedId, 'a1');
    expect(state.deletedAddressId, 'a1');
  });

  test('saving another address as default persists the toggle', () async {
    final service = _FakeShippingAddressesService(
      addresses: [
        _address(id: 'a1', isDefault: true),
        _address(id: 'a2', isDefault: false).copyWith(
          fullName: 'Luigi Bianchi',
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        shippingAddressesServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await _pumpLoadedState(container, 'a2');

    final notifier = container.read(
      shippingAddressFormNotifierProvider('a2').notifier,
    );
    notifier.updateIsDefault(true);
    final didSave = await notifier.save();
    final state = container.read(shippingAddressFormNotifierProvider('a2'));

    expect(didSave, isTrue);
    expect(service.lastSavedForm?.isDefault, isTrue);
    expect(state.lastSavedAddress?.isDefault, isTrue);
  });
}
