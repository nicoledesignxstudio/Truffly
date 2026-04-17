import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/data/orders_service.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_section_card.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_status_badge.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_timeline_card.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);
    final detailAsync = ref.watch(orderDetailProvider(orderId));

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
                context.go(AppRoutes.accountOrders);
              }
            },
          ),
        ),
        title: Text(
          orderPageTitle(context),
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: profileAsync.when(
        data: (profile) => detailAsync.when(
          data: (order) {
            final isBuyerView = order.buyerId == profile.userId;
            final isSellerSalesView =
                !isBuyerView && order.sellerId == profile.userId;
            final isPending = ref.watch(
              orderMutationProvider.select(
                (pending) => pending.contains(order.id),
              ),
            );

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(orderDetailProvider(orderId));
                await ref.read(orderDetailProvider(orderId).future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingL,
                ),
                children: [
                  _ProductSummaryCard(order: order),
                  const SizedBox(height: AppSpacing.spacingM),
                  if (isBuyerView)
                    _CounterpartyCard(
                      title: sellerLabel(context),
                      name: order.sellerName,
                      subtitle:
                          '${boughtOnLabel(context)} ${formatShortDate(context, order.createdAt)}',
                      imageUrl: order.sellerProfileImageUrl,
                      onTap: () => context.push(
                        AppRoutes.sellerProfilePath(order.sellerId),
                      ),
                    )
                  else
                    _OrderMetaCard(
                      title: buyerLabel(context),
                      leading: order.buyerName,
                      trailing:
                          '${boughtOnLabel(context)} ${formatShortDate(context, order.createdAt)}',
                    ),
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderTimelineCard(
                    status: order.status,
                    isSellerView: isSellerSalesView,
                  ),
                  if ((order.status == OrderStatus.shipped ||
                          order.status == OrderStatus.completed) &&
                      (order.trackingCode?.trim().isNotEmpty ?? false)) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    OrderSectionCard(
                      title: trackPackageTitle(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ReadOnlyTrackingField(
                            value: order.trackingCode!,
                          ),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            isItalianOrders(context)
                                ? 'Usa questo codice per seguire la spedizione.'
                                : 'Use this code to follow your shipment.',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.black80,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderSectionCard(
                    title: shippingDetailsTitle(context),
                    child: Text(
                      _formattedShippingDetails(context, order),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.black80,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isBuyerView && order.status == OrderStatus.shipped) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    AuthPrimaryButton(
                      label: confirmReceiptLabel(context),
                      isLoading: isPending,
                      onPressed: () => _runMutation(
                        context,
                        ref,
                        action: 'confirm_receipt',
                        task: () {
                          return ref
                              .read(orderMutationProvider.notifier)
                              .confirmReceipt(order.id);
                        },
                      ),
                    ),
                  ],
                  if (isSellerSalesView) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    if (order.status == OrderStatus.paid) ...[
                      OrderSectionCard(
                        title: shippingDeadlineTitle(context),
                        child: Text(
                          shippingDeadlineCopy(context),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.black80,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingM),
                    ],
                    OrderSectionCard(
                      title: paymentStatusTitle(context),
                      child: Text(
                        paymentStatusCopy(context, order.status),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.black80,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (order.status == OrderStatus.paid) ...[
                      const SizedBox(height: AppSpacing.spacingM),
                      AuthPrimaryButton(
                        label: markAsShippedLabel(context),
                        isLoading: isPending,
                        onPressed: () =>
                            _openTrackingSheet(context, ref, order.id),
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      AuthSecondaryButton(
                        label: cancelOrderLabel(context),
                        enabled: !isPending,
                        onPressed: () => _runMutation(
                          context,
                          ref,
                          action: 'cancel_order',
                          task: () {
                            return ref
                                .read(orderMutationProvider.notifier)
                                .cancelOrder(order.id);
                          },
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderSectionCard(
                    title: financialStatusTitle(context),
                    child: Text(
                      financialStatusCopy(
                        context,
                        status: order.status,
                        isSellerView: isSellerSalesView,
                        payoutStatus: order.payoutStatus,
                        refundStatus: order.refundStatus,
                      ),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.black80,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderSectionCard(
                    title: supportTitle(context),
                    onTap: () => context.push(AppRoutes.accountSupport),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.headset_mic_outlined,
                          color: AppColors.black80,
                        ),
                        const SizedBox(width: AppSpacing.spacingS),
                        Expanded(
                          child: Text(
                            supportCopy(context),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.black80,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.black50,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _DetailErrorState(
            onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _DetailErrorState(
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      ),
    );
  }

  Future<void> _openTrackingSheet(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final controller = TextEditingController();
    String? errorText;
    var isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spacingM,
                    AppSpacing.spacingM,
                    AppSpacing.spacingM,
                    AppSpacing.spacingL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trackingBottomSheetTitle(context),
                        style: AppTextStyles.sectionTitle,
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        trackingBottomSheetSubtitle(context),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.spacingM),
                      AuthTextField(
                        controller: controller,
                        labelText: trackingCodeLabel(context),
                        errorText: errorText,
                        textInputAction: TextInputAction.done,
                        enabled: !isSubmitting,
                        onChanged: (_) {
                          if (errorText == null) return;
                          setState(() {
                            errorText = null;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacingM),
                      AuthPrimaryButton(
                        label: confirmLabel(context),
                        isLoading: isSubmitting,
                        onPressed: () async {
                          if (isSubmitting) return;
                          final trackingCode = controller.text.trim();
                          if (trackingCode.isEmpty) {
                            setState(() {
                              errorText = trackingRequired(context);
                            });
                            return;
                          }

                          setState(() {
                            isSubmitting = true;
                          });
                          Navigator.of(context).pop();
                          await _runMutation(
                            context,
                            ref,
                            action: 'mark_shipped',
                            task: () {
                              return ref
                                  .read(orderMutationProvider.notifier)
                                  .markAsShipped(orderId, trackingCode);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.spacingS),
                      AuthSecondaryButton(
                        label: closeLabel(context),
                        enabled: !isSubmitting,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _runMutation(
    BuildContext context,
    WidgetRef ref, {
    required String action,
    required Future<void> Function() task,
  }) async {
    try {
      await task();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mutationSuccessMessage(context, action))),
      );
    } on OrdersServiceException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorText(context, error))));
    }
  }

  String _errorText(BuildContext context, OrdersServiceException error) {
    if (error.code == 'invalid_tracking_code') {
      return trackingRequired(context);
    }
    if (error.code == 'refund_failed') {
      return isItalianOrders(context)
          ? 'Il rimborso non e disponibile in questo momento. Riprova tra poco.'
          : 'Refund is not available right now. Please try again soon.';
    }
    if (error.failure == OrdersFailure.notFound) {
      return isItalianOrders(context)
          ? 'Questo ordine non è più disponibile.'
          : 'This order is no longer available.';
    }
    if (error.failure == OrdersFailure.forbidden) {
      return isItalianOrders(context)
          ? 'Non puoi aggiornare questo ordine.'
          : 'You cannot update this order.';
    }
    return genericMutationError(context);
  }

  String _formattedShippingDetails(BuildContext context, OrderDetail order) {
    final lines = [
      order.shippingFullName.trim(),
      order.shippingStreet.trim(),
      [
        order.shippingPostalCode.trim(),
        order.shippingCity.trim(),
      ].where((value) => value.isNotEmpty).join(' '),
      localizedEuropeanCountryName(
        AppLocalizations.of(context)!,
        order.shippingCountryCode,
      ),
      order.shippingPhone.trim(),
    ].where((value) => value.isNotEmpty).toList(growable: false);

    if (lines.isEmpty) {
      return isItalianOrders(context)
          ? 'Nessun dettaglio di spedizione disponibile.'
          : 'No shipping details available.';
    }

    return lines.join('\n');
  }
}

class _ProductSummaryCard extends StatelessWidget {
  const _ProductSummaryCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: SizedBox(
        height: 148,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryImage(imageUrl: order.primaryImageUrl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            order.type.localizedName(l10n),
                            style: AppTextStyles.cardTitle.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacingS),
                        OrderStatusBadge(status: order.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(order.type.latinName, style: AppTextStyles.bodySmall),
                    const Spacer(),
                    Text(
                      '${formatEuro(order.totalPrice)} - ${formatWeightGrams(order.weightGrams)}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryImage extends StatelessWidget {
  const _SummaryImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final child = imageUrl == null
        ? const ColoredBox(
            color: AppColors.softGrey,
            child: Center(
              child: Icon(Icons.image_outlined, color: AppColors.black50),
            ),
          )
        : Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: AppColors.softGrey,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.black50,
                  ),
                ),
              );
            },
          );

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
      child: SizedBox(
        width: 124,
        child: child,
      ),
    );
  }
}

class _ReadOnlyTrackingField extends StatelessWidget {
  const _ReadOnlyTrackingField({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: AppShadows.authField,
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFFF3ED),
          suffixIcon: const Icon(
            Icons.local_shipping_outlined,
            color: AppColors.accent,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingM,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFD7C6)),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFD7C6)),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFFD7C6)),
          ),
        ),
        child: Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CounterpartyCard extends StatelessWidget {
  const _CounterpartyCard({
    required this.title,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.onTap,
  });

  final String title;
  final String name;
  final String subtitle;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((value) => value.isNotEmpty)
        .take(2)
        .map((value) => value.substring(0, 1).toUpperCase())
        .join();

    return OrderSectionCard(
      title: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingXS),
            child: Row(
              children: [
                SellerAvatar(
                  imageUrl: imageUrl,
                  initials: initials.isEmpty ? 'T' : initials,
                  size: 54,
                ),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.black50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderMetaCard extends StatelessWidget {
  const _OrderMetaCard({
    required this.title,
    required this.leading,
    required this.trailing,
  });

  final String title;
  final String leading;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return OrderSectionCard(
      title: title,
      child: Wrap(
        spacing: AppSpacing.spacingS,
        runSpacing: 2,
        children: [
          Text(
            leading,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.black80,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            trailing,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.black80,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ordersLoadError(context),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(label: retryLabel(context), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
