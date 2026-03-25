import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';
import 'package:truffly_app/features/account/presentation/shipping_addresses_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeShippingAddressesService implements ShippingAddressesService {
  _FakeShippingAddressesService(this.addresses);

  final List<ShippingAddress> addresses;

  @override
  Future<void> deleteAddress(String addressId) async {}

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

Widget _buildApp(ShippingAddressesService service) {
  return ProviderScope(
    overrides: [
      shippingAddressesServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShippingAddressesPage(),
    ),
  );
}

void main() {
  testWidgets('empty state shows add address CTA', (tester) async {
    await tester.pumpWidget(_buildApp(_FakeShippingAddressesService(const [])));
    await tester.pumpAndSettle();

    expect(find.text('No saved addresses'), findsOneWidget);
    expect(find.byKey(const Key('shipping_empty_add_button')), findsOneWidget);
  });

  testWidgets('populated state shows address cards and default badge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        _FakeShippingAddressesService([
          _address(id: 'a1', isDefault: true),
          _address(id: 'a2', isDefault: false).copyWith(
            fullName: 'Luigi Bianchi',
            city: 'Bologna',
          ),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('shipping_address_card_a1')), findsOneWidget);
    expect(find.byKey(const Key('shipping_address_card_a2')), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    expect(find.byKey(const Key('shipping_add_button')), findsOneWidget);
  });
}
