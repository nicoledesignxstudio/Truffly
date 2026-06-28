import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/data/orders_service.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/order_detail_page.dart';
import 'package:truffly_app/features/reviews/application/reviews_providers.dart';
import 'package:truffly_app/features/reviews/data/reviews_service.dart';
import 'package:truffly_app/features/reviews/domain/order_review.dart';
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
          orderController: _OrderController(
            _buildOrder(
              buyerId: _buyerProfile.userId,
              sellerId: 'seller-1',
              status: OrderStatus.shipped,
            ),
          ),
          reviewController: _ReviewController(null),
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
          orderController: _OrderController(
            _buildOrder(
              buyerId: 'buyer-1',
              sellerId: _sellerProfile.userId,
              status: OrderStatus.paid,
            ),
          ),
          reviewController: _ReviewController(null),
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
          orderController: _OrderController(
            _buildOrder(
              buyerId: _sellerProfile.userId,
              sellerId: 'seller-2',
              status: OrderStatus.shipped,
            ),
          ),
          reviewController: _ReviewController(null),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Conferma ricezione');

      expect(find.text('Conferma ricezione'), findsOneWidget);
      expect(find.text('Segna come spedito'), findsNothing);
      expect(find.text('Annulla ordine'), findsNothing);
    });

    testWidgets('seller tracking submit calls mark shipped service', (
      tester,
    ) async {
      final fakeService = _FakeOrdersService();
      addTearDown(fakeService.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          profile: _sellerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: 'buyer-1',
              sellerId: _sellerProfile.userId,
              status: OrderStatus.paid,
            ),
          ),
          reviewController: _ReviewController(null),
          ordersService: fakeService,
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Segna come spedito');
      await tester.tap(find.text('Segna come spedito'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '  TRK-999  ');
      await tester.tap(find.text('Conferma'));
      await tester.pump();

      expect(fakeService.markShippedCalls, isEmpty);
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      await tester.pumpAndSettle();

      expect(fakeService.markShippedCalls, ['order-1:TRK-999']);
      expect(find.text('Ordine aggiornato come spedito.'), findsOneWidget);
      expect(find.text('Codice tracking'), findsNothing);
    });

    testWidgets('tracking code can be copied', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: _buyerProfile.userId,
              sellerId: 'seller-1',
              status: OrderStatus.shipped,
            ),
          ),
          reviewController: _ReviewController(null),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Traccia il tuo pacco');

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('paid order timeline uses black styling in detail view', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(
          profile: _sellerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: 'buyer-1',
              sellerId: _sellerProfile.userId,
              status: OrderStatus.paid,
            ),
          ),
          reviewController: _ReviewController(null),
        ),
      );

      await tester.pumpAndSettle();

      final stepText = tester.widget<Text>(find.text('Ordine confermato'));
      expect(stepText.style?.color, AppColors.black);
    });

    testWidgets(
      'buyer sees review CTA only for completed orders without review',
      (tester) async {
        final completedAt = DateTime.now().toUtc().subtract(
          const Duration(days: 1),
        );
        await tester.pumpWidget(
          _buildTestApp(
            profile: _buyerProfile,
            orderController: _OrderController(
              _buildOrder(
                buyerId: _buyerProfile.userId,
                sellerId: 'seller-1',
                status: OrderStatus.completed,
                completedAt: completedAt,
              ),
            ),
            reviewController: _ReviewController(null),
          ),
        );

        await tester.pumpAndSettle();
        await _scrollUntilTextVisible(tester, 'Lascia recensione');

        expect(find.text('Lascia recensione'), findsOneWidget);
        expect(find.text('Recensione inviata'), findsNothing);
      },
    );

    testWidgets('buyer does not see review CTA when review already exists', (
      tester,
    ) async {
      final completedAt = DateTime.now().toUtc().subtract(
        const Duration(days: 1),
      );
      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: _buyerProfile.userId,
              sellerId: 'seller-1',
              status: OrderStatus.completed,
              completedAt: completedAt,
            ),
          ),
          reviewController: _ReviewController(
            OrderReview(
              id: 'review-1',
              orderId: 'order-1',
              rating: 5,
              comment: null,
              createdAt: DateTime(2026, 3, 26),
              isAuto: false,
              autoCreatedAt: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lascia recensione'), findsNothing);
    });

    testWidgets('buyer does not see review CTA after 48 hours', (tester) async {
      final completedAt = DateTime.now().toUtc().subtract(
        const Duration(hours: 49),
      );
      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: _buyerProfile.userId,
              sellerId: 'seller-1',
              status: OrderStatus.completed,
              completedAt: completedAt,
            ),
          ),
          reviewController: _ReviewController(null),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lascia recensione'), findsNothing);
    });

    testWidgets('leave review CTA opens review bottom sheet', (tester) async {
      final completedAt = DateTime.now().toUtc().subtract(
        const Duration(hours: 24),
      );
      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: _OrderController(
            _buildOrder(
              buyerId: _buyerProfile.userId,
              sellerId: 'seller-1',
              status: OrderStatus.completed,
              completedAt: completedAt,
            ),
          ),
          reviewController: _ReviewController(null),
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Lascia recensione');
      await tester.tap(find.text('Lascia recensione'));
      await tester.pumpAndSettle();

      expect(find.text("Com'è stata la tua esperienza?"), findsOneWidget);
      expect(find.text('Pubblica recensione'), findsOneWidget);
      expect(find.text('Più tardi'), findsOneWidget);
    });

    testWidgets('submit review updates UI and hides CTA', (tester) async {
      final completedAt = DateTime.now().toUtc().subtract(
        const Duration(hours: 24),
      );
      final orderController = _OrderController(
        _buildOrder(
          buyerId: _buyerProfile.userId,
          sellerId: 'seller-1',
          status: OrderStatus.completed,
          completedAt: completedAt,
        ),
      );
      final reviewController = _ReviewController(null);
      final reviewsService = _FakeReviewsService()
        ..onSubmit =
            ({required orderId, required rating, required comment}) async {
              reviewController.currentReview = OrderReview(
                id: 'review-1',
                orderId: orderId,
                rating: rating,
                comment: comment,
                createdAt: DateTime.now().toUtc(),
                isAuto: false,
                autoCreatedAt: null,
              );
            };
      addTearDown(reviewsService.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: orderController,
          reviewController: reviewController,
          reviewsService: reviewsService,
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Lascia recensione');
      await tester.tap(find.text('Lascia recensione'));
      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Pubblica recensione');
      await tester.tap(find.text('Pubblica recensione'));
      await tester.pumpAndSettle();

      expect(reviewsService.submitReviewCalls.length, 1);
      expect(find.text('Grazie, recensione pubblicata.'), findsOneWidget);
      expect(find.text('Lascia recensione'), findsNothing);
    });

    testWidgets('confirm receipt success opens review bottom sheet', (
      tester,
    ) async {
      final orderController = _OrderController(
        _buildOrder(
          buyerId: _buyerProfile.userId,
          sellerId: 'seller-1',
          status: OrderStatus.shipped,
        ),
      );
      final reviewController = _ReviewController(null);
      final ordersService = _FakeOrdersService()
        ..onConfirmReceipt = (orderId) async {
          orderController.currentOrder = _buildOrder(
            buyerId: _buyerProfile.userId,
            sellerId: 'seller-1',
            status: OrderStatus.completed,
            completedAt: DateTime.now().toUtc(),
          );
        };
      addTearDown(ordersService.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: orderController,
          reviewController: reviewController,
          ordersService: ordersService,
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Conferma ricezione');
      await tester.tap(find.text('Conferma ricezione'));
      await tester.pumpAndSettle();

      expect(find.text("Com'è stata la tua esperienza?"), findsOneWidget);
    });

    testWidgets('review_window_expired is handled without crash', (
      tester,
    ) async {
      final completedAt = DateTime.now().toUtc().subtract(
        const Duration(hours: 24),
      );
      final orderController = _OrderController(
        _buildOrder(
          buyerId: _buyerProfile.userId,
          sellerId: 'seller-1',
          status: OrderStatus.completed,
          completedAt: completedAt,
        ),
      );
      final reviewController = _ReviewController(null);
      final reviewsService = _FakeReviewsService()
        ..onSubmit =
            ({required orderId, required rating, required comment}) async {
              orderController.currentOrder = _buildOrder(
                buyerId: _buyerProfile.userId,
                sellerId: 'seller-1',
                status: OrderStatus.completed,
                completedAt: DateTime.now().toUtc().subtract(
                  const Duration(hours: 49),
                ),
              );
              throw const ReviewsServiceException(
                'review_window_expired',
                'expired',
              );
            };
      addTearDown(reviewsService.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          profile: _buyerProfile,
          orderController: orderController,
          reviewController: reviewController,
          reviewsService: reviewsService,
        ),
      );

      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Lascia recensione');
      await tester.tap(find.text('Lascia recensione'));
      await tester.pumpAndSettle();
      await _scrollUntilTextVisible(tester, 'Pubblica recensione');
      await tester.tap(find.text('Pubblica recensione'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Il tempo per lasciare una recensione è scaduto. Se non hai recensito, verrà registrata la valutazione automatica prevista.',
        ),
        findsOneWidget,
      );
      expect(find.text('Lascia recensione'), findsNothing);
    });
  });
}

Widget _buildTestApp({
  required CurrentUserProfile profile,
  required _OrderController orderController,
  required _ReviewController reviewController,
  OrdersService? ordersService,
  ReviewsService? reviewsService,
}) {
  return ProviderScope(
    overrides: [
      currentUserAccountProfileProvider.overrideWith((ref) async => profile),
      orderDetailProvider(
        orderController.currentOrder.id,
      ).overrideWith((ref) async => orderController.currentOrder),
      orderReviewProvider(
        orderController.currentOrder.id,
      ).overrideWith((ref) async => reviewController.currentReview),
      if (ordersService != null)
        ordersServiceProvider.overrideWithValue(ordersService),
      if (reviewsService != null)
        reviewsServiceProvider.overrideWithValue(reviewsService),
    ],
    child: MaterialApp(
      locale: const Locale('it'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: OrderDetailPage(orderId: orderController.currentOrder.id),
    ),
  );
}

final class _FakeOrdersService extends OrdersService {
  _FakeOrdersService() : this._(_createClient());

  _FakeOrdersService._(this._client) : super(_client);

  static SupabaseClient _createClient() {
    return SupabaseClient(
      'http://localhost',
      'anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
  }

  final SupabaseClient _client;

  final List<String> markShippedCalls = [];
  final List<String> confirmReceiptCalls = [];
  Future<void> Function(String orderId)? onConfirmReceipt;

  @override
  Future<void> markAsShipped(String orderId, String trackingCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    markShippedCalls.add('$orderId:$trackingCode');
  }

  @override
  Future<void> confirmReceipt(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    confirmReceiptCalls.add(orderId);
    await onConfirmReceipt?.call(orderId);
  }

  void dispose() {
    _client.auth.stopAutoRefresh();
  }
}

final class _FakeReviewsService extends ReviewsService {
  _FakeReviewsService() : this._(_createClient());

  _FakeReviewsService._(this._client) : super(_client);

  static SupabaseClient _createClient() {
    return SupabaseClient(
      'http://localhost',
      'anon-key',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
  }

  final SupabaseClient _client;
  final List<Map<String, Object?>> submitReviewCalls = [];
  Future<void> Function({
    required String orderId,
    required int rating,
    required String? comment,
  })?
  onSubmit;

  @override
  Future<void> submitReview({
    required String orderId,
    required int rating,
    required String? comment,
  }) async {
    submitReviewCalls.add({
      'orderId': orderId,
      'rating': rating,
      'comment': comment,
    });
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await onSubmit?.call(orderId: orderId, rating: rating, comment: comment);
  }

  void dispose() {
    _client.auth.stopAutoRefresh();
  }
}

final class _OrderController {
  _OrderController(this.currentOrder);

  OrderDetail currentOrder;
}

final class _ReviewController {
  _ReviewController(this.currentReview);

  OrderReview? currentReview;
}

OrderDetail _buildOrder({
  required String buyerId,
  required String sellerId,
  required OrderStatus status,
  DateTime? completedAt,
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
    paidAt: DateTime(2026, 3, 22),
    shippedAt: status == OrderStatus.shipped || status == OrderStatus.completed
        ? DateTime(2026, 3, 23)
        : null,
    completedAt: completedAt,
    cancelledAt: null,
    trackingCode: status == OrderStatus.shipped ? 'TRK-123' : null,
    payoutStatus: null,
    refundStatus: null,
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
