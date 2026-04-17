import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_item.dart';
import 'package:truffly_app/features/truffle/domain/seller_managed_truffle_status.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/seller_managed_truffle_card.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

void main() {
  group('SellerManagedTruffleCard', () {
    testWidgets('shows reserved label without treating it as sold', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          child: SellerManagedTruffleCard(
            item: _buildItem(status: SellerManagedTruffleStatus.reserved),
            onTap: null,
          ),
        ),
      );

      expect(find.text('Reserved'), findsOneWidget);
      expect(find.text('Sold'), findsNothing);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('shows publishing label for publishing truffles', (
      tester,
    ) async {
      await tester.pumpWidget(
        _TestApp(
          child: SellerManagedTruffleCard(
            item: _buildItem(status: SellerManagedTruffleStatus.publishing),
            onTap: null,
          ),
        ),
      );

      expect(find.text('Publishing'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('keeps delete action only for active truffles', (tester) async {
      await tester.pumpWidget(
        _TestApp(
          child: SellerManagedTruffleCard(
            item: _buildItem(status: SellerManagedTruffleStatus.active),
            onTap: () {},
            onDeleteTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(find.text('Active'), findsNothing);
    });
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }
}

SellerManagedTruffleItem _buildItem({
  required SellerManagedTruffleStatus status,
}) {
  final now = DateTime.utc(2026, 3, 26, 12);
  return SellerManagedTruffleItem(
    id: 'truffle-$status',
    status: status,
    type: TruffleType.tuberMagnatum,
    quality: TruffleQuality.first,
    weightGrams: 120,
    priceTotal: 180,
    shippingPriceItaly: 12,
    shippingPriceAbroad: 25,
    region: 'TOSCANA',
    harvestDate: now.subtract(const Duration(days: 1)),
    createdAt: now.subtract(const Duration(days: 2)),
    expiresAt: now.add(const Duration(days: 5)),
    primaryImageUrl: null,
  );
}
