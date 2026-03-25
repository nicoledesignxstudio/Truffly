import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/order_detail_page.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  group('OrderDetailPage CTA visibility', () {
    testWidgets('buyer sees confirm receipt only for shipped orders', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          order: _buildOrder(
            buyerId: _buyerProfile.userId,
            sellerId: 'seller-1',
            status: OrderStatus.shipped,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Conferma ricezione');

      expect(find.text('Conferma ricezione'), findsOneWidget);
      expect(find.text('Segna come spedito'), findsNothing);
      expect(find.text('Annulla ordine'), findsNothing);
    });

    testWidgets('seller sees shipment CTA only for paid sales orders', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          profile: _sellerProfile,
          order: _buildOrder(
            buyerId: 'buyer-1',
            sellerId: _sellerProfile.userId,
            status: OrderStatus.paid,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Segna come spedito');

      expect(find.text('Segna come spedito'), findsOneWidget);
      expect(find.text('Annulla ordine'), findsOneWidget);
      expect(find.text('Conferma ricezione'), findsNothing);
    });

    testWidgets('seller purchase opens buyer style detail', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          profile: _sellerProfile,
          order: _buildOrder(
            buyerId: _sellerProfile.userId,
            sellerId: 'seller-2',
            status: OrderStatus.shipped,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Conferma ricezione');

      expect(find.text('Conferma ricezione'), findsOneWidget);
      expect(find.text('Segna come spedito'), findsNothing);
      expect(find.text('Annulla ordine'), findsNothing);
    });
  });
}

Widget _buildTestApp({
  required CurrentUserProfile profile,
  required OrderDetail order,
}) {
  return ProviderScope(
    overrides: [
      currentUserAccountProfileProvider.overrideWith((ref) async => profile),
      orderDetailProvider(order.id).overrideWith((ref) async => order),
    ],
    child: MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrderDetailPage(orderId: order.id),
    ),
  );
}

OrderDetail _buildOrder({
  required String buyerId,
  required String sellerId,
  required OrderStatus status,
}) {
  return OrderDetail(
    id: 'order-1',
    truffleId: 'truffle-1',
    type: TruffleType.tuberAestivum,
    quality: TruffleQuality.first,
    weightGrams: 80,
    totalPrice: 120,
    commissionAmount: 12,
    sellerAmount: 108,
    status: status,
    createdAt: DateTime(2026, 3, 22),
    trackingCode: status == OrderStatus.shipped ? 'TRK-123' : null,
    primaryImageUrl: null,
    buyerId: buyerId,
    buyerName: 'Buyer Test',
    sellerId: sellerId,
    sellerName: 'Seller Test',
    sellerProfileImageUrl: null,
    shippingFullName: 'Buyer Test',
    shippingStreet: 'Via Roma 1',
    shippingCity: 'Firenze',
    shippingPostalCode: '50100',
    shippingCountryCode: 'IT',
    shippingPhone: '3331234567',
  );
}

const _buyerProfile = CurrentUserProfile(
  userId: 'buyer-1',
  email: 'buyer@test.com',
  onboardingCompleted: true,
  firstName: 'Buyer',
  lastName: 'Test',
  role: 'buyer',
  sellerStatus: 'not_requested',
  countryCode: 'IT',
  region: 'TOSCANA',
  bio: null,
  profileImageUrl: null,
);

const _sellerProfile = CurrentUserProfile(
  userId: 'seller-1',
  email: 'seller@test.com',
  onboardingCompleted: true,
  firstName: 'Seller',
  lastName: 'Test',
  role: 'seller',
  sellerStatus: 'approved',
  countryCode: 'IT',
  region: 'PIEMONTE',
  bio: null,
  profileImageUrl: null,
);

Future<void> _scrollUntilTextVisible(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.text(text),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}
