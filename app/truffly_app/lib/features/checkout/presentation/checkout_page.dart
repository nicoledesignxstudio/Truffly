import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/presentation/widgets/shipping_address_card.dart';
import 'package:truffly_app/features/home/application/home_content_provider.dart';
import 'package:truffly_app/features/checkout/application/checkout_providers.dart';
import 'package:truffly_app/features/checkout/data/checkout_payment_service.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/marketplace/application/marketplace_providers.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/domain/order_summary.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';
import 'package:truffly_app/features/truffle/domain/truffle_detail.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

final checkoutShippingAddressesProvider = FutureProvider<List<ShippingAddress>>(
  (ref) {
    ref.watch(authNotifierProvider);
    return ref.read(shippingAddressesServiceProvider).fetchAddresses();
  },
);

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key, required this.truffleId});

  final String truffleId;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  String? _selectedAddressId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(truffleDetailProvider(widget.truffleId));
    final addressesAsync = ref.watch(checkoutShippingAddressesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.truffleDetailPath(widget.truffleId));
              }
            },
          ),
        ),
        title: Text(
          _isItalian ? 'Pagamento' : 'Payment',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
        ),
      ),
      body: detailAsync.when(
        data: (detail) => addressesAsync.when(
          data: (addresses) {
            final selectedAddress = _resolveSelectedAddress(addresses);
            return _CheckoutLoadedBody(
              detail: detail,
              selectedAddress: selectedAddress,
              isItalian: _isItalian,
              isSubmitting: _isSubmitting,
              shippingCost: _shippingCost(detail, selectedAddress),
              onChooseAddress: addresses.isEmpty
                  ? _openAddAddressForm
                  : () => _chooseShippingAddress(addresses),
              onSubmit: selectedAddress == null
                  ? null
                  : () => _startCheckout(
                      detail: detail,
                      selectedAddress: selectedAddress,
                    ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _ErrorView(
            message: _isItalian
                ? 'Non riusciamo a caricare gli indirizzi di spedizione.'
                : 'We could not load your shipping addresses.',
            onRetry: () => ref.invalidate(checkoutShippingAddressesProvider),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorView(
          message: _isItalian
              ? 'Non riusciamo a caricare questo tartufo.'
              : 'We could not load this truffle.',
          onRetry: () =>
              ref.invalidate(truffleDetailProvider(widget.truffleId)),
        ),
      ),
    );
  }

  bool get _isItalian => Localizations.localeOf(context).languageCode == 'it';

  ShippingAddress? _resolveSelectedAddress(List<ShippingAddress> addresses) {
    if (addresses.isEmpty) {
      return null;
    }

    final selectedAddressId = _selectedAddressId;
    if (selectedAddressId != null) {
      for (final address in addresses) {
        if (address.id == selectedAddressId) {
          return address;
        }
      }
    }

    return addresses.first;
  }

  double _shippingCost(TruffleDetail detail, ShippingAddress? selectedAddress) {
    final countryCode = selectedAddress?.countryCode.toUpperCase();
    if (countryCode == null || countryCode == 'IT') {
      return detail.shippingPriceItaly;
    }
    return detail.shippingPriceAbroad;
  }

  Future<void> _chooseShippingAddress(List<ShippingAddress> addresses) async {
    final selection = await showModalBottomSheet<ShippingAddress>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              0,
              AppSpacing.spacingM,
              AppSpacing.spacingM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isItalian
                      ? 'Scegli indirizzo di spedizione'
                      : 'Choose shipping address',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.spacingS),
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return ShippingAddressCard(
                      address: address,
                      onTap: () => Navigator.of(context).pop(address),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.black,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(
                        AppSpacing.authControlHeight,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingS,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await _openAddAddressForm();
                    },
                    child: Text(
                      _isItalian ? 'Aggiungi indirizzo' : 'Add address',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selection == null || !mounted) {
      return;
    }

    setState(() {
      _selectedAddressId = selection.id;
    });
  }

  Future<void> _openAddAddressForm() async {
    await context.push(AppRoutes.accountShippingAdd);
    if (!mounted) {
      return;
    }
    ref.invalidate(checkoutShippingAddressesProvider);
  }

  void _refreshPurchaseSurfaces(String truffleId) {
    ref.invalidate(currentUserOrdersProvider);
    ref.invalidate(truffleDetailProvider(truffleId));
    ref.invalidate(truffleListingNotifierProvider);
    ref.invalidate(homeLatestTrufflesProvider);
    ref.invalidate(homeTopSellersProvider);
  }

  Future<OrderSummary?> _waitForConfirmedOrder(String truffleId) async {
    const attempts = 12;
    for (var index = 0; index < attempts; index++) {
      try {
        ref.invalidate(currentUserOrdersProvider);
        final orders = await ref.read(currentUserOrdersProvider.future);
        final matches =
            orders
                .where((order) => order.truffleId == truffleId)
                .toList(growable: false)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (matches.isNotEmpty) {
          return matches.first;
        }
      } catch (error) {
        if (kDebugMode) {
          debugPrint('[CheckoutPage] order refresh attempt failed: $error');
        }
      }

      if (index != attempts - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    return null;
  }

  Future<String?> _finalizePaymentAttemptWithRetry({
    required String paymentAttemptId,
    required String stripePaymentIntentId,
  }) async {
    const attempts = 6;
    for (var index = 0; index < attempts; index++) {
      final orderId = await ref
          .read(checkoutPaymentServiceProvider)
          .finalizePaymentAttempt(
            paymentAttemptId: paymentAttemptId,
            stripePaymentIntentId: stripePaymentIntentId,
          );
      if (orderId != null && orderId.isNotEmpty) {
        return orderId;
      }

      if (index != attempts - 1) {
        await Future.delayed(const Duration(milliseconds: 750));
      }
    }

    return null;
  }

  Future<void> _showPaymentOutcomeSheet({required OrderSummary? order}) async {
    final hasOrder = order != null;
    final confirmedOrderId = order?.id;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                Text(
                  hasOrder
                      ? (_isItalian ? 'Ordine confermato' : 'Order confirmed')
                      : (_isItalian
                            ? 'Pagamento riuscito'
                            : 'Payment successful'),
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  hasOrder
                      ? (_isItalian
                            ? 'Il tuo ordine è stato creato ed è pronto nella sezione Ordini.'
                            : 'Your order is ready in the Orders section.')
                      : (_isItalian
                            ? 'Il pagamento è andato a buon fine. L\'ordine apparirà a breve nella sezione Ordini.'
                            : 'Your payment went through. The order will appear in the Orders section shortly.'),
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.spacingL),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      if (!mounted) {
                        return;
                      }
                      if (hasOrder) {
                        final orderId = confirmedOrderId;
                        if (orderId == null) {
                          return;
                        }
                        context.go(AppRoutes.accountOrderDetailPath(orderId));
                      } else {
                        context.go(AppRoutes.accountOrders);
                      }
                    },
                    child: Text(
                      hasOrder
                          ? (_isItalian ? 'Apri ordine' : 'Open order')
                          : (_isItalian
                                ? 'Vai ai miei ordini'
                                : 'Go to my orders'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startCheckout({
    required TruffleDetail detail,
    required ShippingAddress selectedAddress,
  }) async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await ref
          .read(checkoutPaymentServiceProvider)
          .presentPaymentSheet(
            truffle: detail,
            shippingAddress: selectedAddress,
          );

      if (!mounted) {
        return;
      }

      switch (result.status) {
        case CheckoutPaymentStatus.success:
          final finalizedOrderId = await _finalizePaymentAttemptWithRetry(
            paymentAttemptId: result.paymentAttemptId!,
            stripePaymentIntentId: result.stripePaymentIntentId!,
          );
          if (!mounted) {
            return;
          }
          _refreshPurchaseSurfaces(detail.id);
          if (finalizedOrderId != null && finalizedOrderId.isNotEmpty) {
            context.go(AppRoutes.accountOrderDetailPath(finalizedOrderId));
            return;
          }
          final confirmedOrder = await _waitForConfirmedOrder(detail.id);
          if (!mounted) {
            return;
          }
          if (confirmedOrder != null) {
            context.go(AppRoutes.accountOrderDetailPath(confirmedOrder.id));
            return;
          }
          await _showPaymentOutcomeSheet(order: null);
          break;
        case CheckoutPaymentStatus.canceled:
          break;
        case CheckoutPaymentStatus.failure:
          final message = switch (result.failure ?? CheckoutFailure.unknown) {
            CheckoutFailure.network =>
              _isItalian
                  ? 'Il checkout non e raggiungibile in questo momento.'
                  : 'Checkout is temporarily unavailable.',
            CheckoutFailure.unauthenticated =>
              _isItalian
                  ? 'La sessione e scaduta. Accedi di nuovo.'
                  : 'Your session expired. Please sign in again.',
            CheckoutFailure.forbidden =>
              _isItalian
                  ? 'Questo acquisto non e consentito.'
                  : 'This purchase is not allowed.',
            CheckoutFailure.notFound =>
              _isItalian
                  ? 'Il tartufo non e piu disponibile.'
                  : 'This truffle is no longer available.',
            CheckoutFailure.sellerNotReady =>
              _isItalian
                  ? 'Il venditore deve completare Stripe prima di ricevere pagamenti.'
                  : 'The seller must finish Stripe setup before receiving payments.',
            CheckoutFailure.validation =>
              _isItalian
                  ? 'Non siamo riusciti a preparare il pagamento.'
                  : 'We could not prepare the payment.',
            CheckoutFailure.paymentCanceled =>
              _isItalian
                  ? 'Pagamento annullato. Nessun addebito confermato.'
                  : 'Payment canceled. No charge was confirmed.',
            CheckoutFailure.paymentFailed =>
              _isItalian
                  ? 'Il pagamento non e andato a buon fine.'
                  : 'The payment could not be completed.',
            CheckoutFailure.unknown =>
              _isItalian
                  ? 'Non siamo riusciti a completare il checkout.'
                  : 'We could not complete the checkout.',
          };

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _CheckoutLoadedBody extends StatelessWidget {
  const _CheckoutLoadedBody({
    required this.detail,
    required this.selectedAddress,
    required this.isItalian,
    required this.isSubmitting,
    required this.shippingCost,
    required this.onChooseAddress,
    required this.onSubmit,
  });

  final TruffleDetail detail;
  final ShippingAddress? selectedAddress;
  final bool isItalian;
  final bool isSubmitting;
  final double shippingCost;
  final VoidCallback onChooseAddress;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = detail.imageUrls.isEmpty ? null : detail.imageUrls.first;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              AppSpacing.spacingS,
              AppSpacing.spacingM,
              AppSpacing.spacingM,
            ),
            children: [
              _ProductCard(
                detail: detail,
                imageUrl: imageUrl,
                isItalian: isItalian,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _AddressCard(
                isItalian: isItalian,
                selectedAddress: selectedAddress,
                onPressed: onChooseAddress,
              ),
              const SizedBox(height: AppSpacing.spacingS),
              _SimpleInfoCard(
                title: isItalian ? 'Modalita di spedizione' : 'Shipping method',
                trailing: Text(
                  formatEuro(shippingCost),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.home_outlined,
                      size: 18,
                      color: AppColors.black80,
                    ),
                    const SizedBox(width: AppSpacing.spacingXS),
                    Expanded(
                      child: Text(
                        isItalian
                            ? 'Consegna a casa in 48h'
                            : 'Home delivery in 48h',
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              _PaymentMethodCard(isItalian: isItalian),
              const SizedBox(height: AppSpacing.spacingXS),
              _GuaranteeCard(isItalian: isItalian),
              const SizedBox(height: AppSpacing.spacingXS),
              _SimpleInfoCard(
                title: isItalian ? 'Riepilogo del prezzo' : 'Price summary',
                child: Column(
                  children: [
                    _SummaryRow(
                      label: isItalian ? 'Ordine' : 'Order',
                      value: formatEuro(detail.priceTotal),
                    ),
                    const SizedBox(height: AppSpacing.spacingXS),
                    _SummaryRow(
                      label: isItalian ? 'Spedizione' : 'Shipping',
                      value: formatEuro(shippingCost),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _FooterCheckoutBar(
          isItalian: isItalian,
          totalLabel: formatEuro(detail.priceTotal + shippingCost),
          isSubmitting: isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.detail,
    required this.imageUrl,
    required this.isItalian,
  });

  final TruffleDetail detail;
  final String? imageUrl;
  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _LightCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: SizedBox(
              width: 102,
              height: 102,
              child: ColoredBox(
                color: const Color(0xFFE0E0E3),
                child: imageUrl == null
                    ? _CheckoutFallbackImage(
                        assetPath: detail.type.guideAssetImagePath,
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _CheckoutFallbackImage(
                          assetPath: detail.type.guideAssetImagePath,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: SizedBox(
              height: 102,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.type.localizedName(l10n),
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail.type.latinName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black50,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        formatEuro(detail.priceTotal),
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacingXS),
                      Text(
                        '\u2022',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 14,
                          color: AppColors.black80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.spacingXS),
                      Text(
                        formatWeightGrams(detail.weightGrams),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontSize: 14,
                          color: AppColors.black80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutFallbackImage extends StatelessWidget {
  const _CheckoutFallbackImage({required this.assetPath});

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.image_outlined, color: AppColors.black50),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.isItalian,
    required this.selectedAddress,
    required this.onPressed,
  });

  final bool isItalian;
  final ShippingAddress? selectedAddress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            title: isItalian ? 'Indirizzo di spedizione' : 'Shipping address',
            onPressed: onPressed,
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          if (selectedAddress == null)
            Text(
              isItalian
                  ? 'Aggiungi un indirizzo per continuare.'
                  : 'Add a shipping address to continue.',
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
            )
          else
            Builder(
              builder: (context) {
                final address = selectedAddress!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.fullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.street,
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.cityLine,
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.isItalian});

  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isItalian
                ? 'Metodi di pagamento accettati'
                : 'Accepted payment methods',
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: const [
              _PaymentMethodBadge(label: 'Card', icon: Icons.credit_card_rounded),
              _PaymentMethodBadge(label: 'Apple Pay', icon: Icons.apple),
              _PaymentMethodBadge(label: 'Google Pay', icon: Icons.payments_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuaranteeCard extends StatelessWidget {
  const _GuaranteeCard({required this.isItalian});

  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.verified_user_outlined,
                color: AppColors.accent,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isItalian
                      ? 'Pagamento sicuro con garanzia'
                      : 'Secure payment with protection',
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  isItalian
                      ? 'Il pagamento viene gestito in modo sicuro e il payout al venditore parte solo dopo la conferma della ricezione del pacco.'
                      : 'The payment is handled securely and the seller payout starts only after delivery is confirmed.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.black80,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCheckoutBar extends StatelessWidget {
  const _FooterCheckoutBar({
    required this.isItalian,
    required this.totalLabel,
    required this.isSubmitting,
    required this.onPressed,
  });

  final bool isItalian;
  final String totalLabel;
  final bool isSubmitting;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14151618),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingM,
            AppSpacing.spacingM,
            AppSpacing.spacingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isItalian ? 'Totale da pagare' : 'Total to pay',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingM),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size.fromHeight(48),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: isSubmitting ? null : onPressed,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          isItalian
                              ? 'Procedi al pagamento'
                              : 'Proceed to payment',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: 16,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: AppColors.black50,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      isItalian
                          ? 'I dettagli del tuo pagamento sono crittografati e sicuri'
                          : 'Your payment details are encrypted and secure',
                      style: AppTextStyles.micro.copyWith(
                        fontSize: 12,
                        color: AppColors.black50,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleInfoCard extends StatelessWidget {
  const _SimpleInfoCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _LightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.spacingS),
          child,
        ],
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: onPressed,
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Icons.edit_outlined,
            color: AppColors.black80,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              color: AppColors.black80,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LightCard extends StatelessWidget {
  const _LightCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.black10, width: 1.2),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: child,
      ),
    );
  }
}

class _PaymentMethodBadge extends StatelessWidget {
  const _PaymentMethodBadge({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.black10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.black),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 34,
              color: AppColors.black50,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            FilledButton(
              onPressed: onRetry,
              child: Text(
                Localizations.localeOf(context).languageCode == 'it'
                    ? 'Riprova'
                    : 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
