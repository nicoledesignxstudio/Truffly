import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';
import 'package:truffly_app/features/account/presentation/shipping_address_form_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class _FakeShippingAddressesService implements ShippingAddressesService {
  _FakeShippingAddressesService({
    required this.addresses,
  });

  final List<ShippingAddress> addresses;
  int saveCalls = 0;
  ShippingAddressFormData? lastSavedForm;

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
    saveCalls += 1;
    lastSavedForm = form.normalized();
    return ShippingAddress(
      id: form.id ?? 'new-id',
      userId: 'u1',
      fullName: form.fullName.trim(),
      street: form.street.trim(),
      city: form.city.trim(),
      postalCode: form.postalCode.trim(),
      countryCode: form.countryCode.trim().toUpperCase(),
      phone: form.phone.trim(),
      isDefault: true,
      createdAt: DateTime.utc(2026, 3, 22),
    );
  }
}

Widget _buildApp(ShippingAddressesService service) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const ShippingAddressFormPage(),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      shippingAddressesServiceProvider.overrideWithValue(service),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

ShippingAddress _address() {
  return ShippingAddress(
    id: 'a1',
    userId: 'u1',
    fullName: 'Mario Rossi',
    street: 'Via Roma 10',
    city: 'Firenze',
    postalCode: '50100',
    countryCode: 'IT',
    phone: '+39 333 1234567',
    isDefault: true,
    createdAt: DateTime.utc(2026, 3, 20),
  );
}

void main() {
  testWidgets('form validation prevents saving incomplete address', (
    tester,
  ) async {
    final service = _FakeShippingAddressesService(addresses: const []);

    await tester.pumpWidget(_buildApp(service));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shipping_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('This field is required.'), findsWidgets);
    expect(service.saveCalls, 0);
  });

  testWidgets('saving valid address submits once', (tester) async {
    final service = _FakeShippingAddressesService(addresses: const []);

    await tester.pumpWidget(_buildApp(service));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('shipping_full_name_field')),
      'Luigi Bianchi',
    );
    await tester.enterText(
      find.byKey(const Key('shipping_street_field')),
      'Via Milano 4',
    );
    await tester.enterText(
      find.byKey(const Key('shipping_city_field')),
      'Bologna',
    );
    await tester.enterText(
      find.byKey(const Key('shipping_postal_code_field')),
      '40100',
    );
    await tester.enterText(
      find.byKey(const Key('shipping_phone_field')),
      '320 1234567',
    );

    await tester.ensureVisible(find.byKey(const Key('shipping_country_field')));
    await tester.tap(find.byKey(const Key('shipping_country_field')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Italy').last);
    await tester.tap(find.text('Italy').last);
    await tester.pumpAndSettle();

    expect(find.text('+39'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shipping_save_button')));
    await tester.pumpAndSettle();

    expect(service.saveCalls, 1);
    expect(service.lastSavedForm?.phone, '+39 320 1234567');
  });

  testWidgets('edit page preloads existing address values', (tester) async {
    final service = _FakeShippingAddressesService(addresses: [_address()]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shippingAddressesServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const ShippingAddressFormPage(addressId: 'a1'),
              ),
            ],
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('Via Roma 10'), findsOneWidget);
    expect(find.text('Firenze'), findsOneWidget);
    expect(find.text('50100'), findsOneWidget);
    expect(find.text('+39'), findsOneWidget);
    expect(find.text('333 1234567'), findsOneWidget);
  });

  testWidgets('changing country updates the default phone prefix', (tester) async {
    final service = _FakeShippingAddressesService(addresses: const []);

    await tester.pumpWidget(_buildApp(service));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('shipping_country_field')));
    await tester.tap(find.byKey(const Key('shipping_country_field')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('France').last);
    await tester.tap(find.text('France').last);
    await tester.pumpAndSettle();

    expect(find.text('+33'), findsOneWidget);
  });
}
