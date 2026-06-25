import 'package:flutter/services.dart';
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
import 'package:truffly_app/features/account/presentation/widgets/destructive_confirmation_dialog.dart';
import 'package:truffly_app/features/orders/application/orders_providers.dart';
import 'package:truffly_app/features/orders/data/orders_service.dart';
import 'package:truffly_app/features/orders/domain/order_detail.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/presentation/orders_text.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_card.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_section_card.dart';
import 'package:truffly_app/features/orders/presentation/widgets/order_timeline_card.dart';
import 'package:truffly_app/features/reviews/application/reviews_providers.dart';
import 'package:truffly_app/features/reviews/data/reviews_service.dart';
import 'package:truffly_app/features/reviews/domain/review_policy.dart';
import 'package:truffly_app/features/reviews/presentation/widgets/review_bottom_sheet.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.openReviewOnLoad = false,
  });

  final String orderId;
  final bool openReviewOnLoad;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _didAttemptOpenReviewOnLoad = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);
    final detailAsync = ref.watch(orderDetailProvider(widget.orderId));

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
            final l10n = AppLocalizations.of(context)!;
            final isBuyerView = order.buyerId == profile.userId;
            final isSellerSalesView =
                !isBuyerView && order.sellerId == profile.userId;
            final reviewAsync = ref.watch(orderReviewProvider(order.id));
            final review = reviewAsync.valueOrNull;
            final isReviewResolved = reviewAsync.hasValue;
            final canLeaveReview =
                isBuyerView &&
                isReviewResolved &&
                isManualReviewWindowOpenForOrder(order, review: review);
            final showReviewUnavailableCopy =
                isBuyerView &&
                order.status == OrderStatus.completed &&
                isReviewResolved &&
                review == null &&
                !canLeaveReview;
            final isPending = ref.watch(
              orderMutationProvider.select(
                (pending) => pending.contains(order.id),
              ),
            );

            if (widget.openReviewOnLoad &&
                !_didAttemptOpenReviewOnLoad &&
                canLeaveReview) {
              _didAttemptOpenReviewOnLoad = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _openReviewSheet(context, order.id);
              });
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(orderDetailProvider(widget.orderId));
                await ref.read(orderDetailProvider(widget.orderId).future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingL,
                ),
                children: [
                  OrderCard(
                    title: order.type.localizedName(l10n),
                    imageUrl: order.primaryImageUrl,
                    fallbackAssetPath: order.type.guideAssetImagePath,
                    status: order.status,
                    totalPrice: order.totalPrice,
                    weightGrams: order.weightGrams,
                    createdAt: order.createdAt,
                    shortReference: _shortReference(order.id),
                    isSalesScope: isSellerSalesView,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderTimelineCard(
                    status: order.status,
                    isSellerView: isSellerSalesView,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  OrderSectionCard(
                    title: shippingAddressTitle(context),
                    child: Text(
                      _formattedShippingDetails(context, order),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black80,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  if (isSellerSalesView &&
                      order.status == OrderStatus.paid) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    OrderSectionCard(
                      title: shippingDeadlineTitle(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.spacingS),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shippingDeadlineHighlight(
                                context,
                                order.createdAt,
                              ),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacingXS),
                            Text(
                              shippingDeadlineCopy(context),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.black80,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                            onCopy: () =>
                                _copyTrackingCode(context, order.trackingCode!),
                          ),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            isItalianOrders(context)
                                ? 'Usa questo codice per seguire la spedizione.'
                                : 'Use this code to follow your shipment.',
                            style: AppTextStyles.bodySmall.copyWith(
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
                            style: AppTextStyles.bodySmall.copyWith(
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
                  if (isBuyerView &&
                      order.status == OrderStatus.completed &&
                      isReviewResolved &&
                      review == null) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    OrderSectionCard(
                      title: l10n.reviewSectionTitle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            canLeaveReview
                                ? l10n.reviewSectionCopy
                                : l10n.reviewUnavailableCopy,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.black80,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (canLeaveReview) ...[
                            const SizedBox(height: AppSpacing.spacingS),
                            AuthPrimaryButton(
                              label: l10n.reviewLeaveCta,
                              onPressed: () =>
                                  _openReviewSheet(context, order.id),
                            ),
                          ] else if (showReviewUnavailableCopy) ...[
                            const SizedBox(height: AppSpacing.spacingXS),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (isBuyerView && order.status == OrderStatus.shipped) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    AuthPrimaryButton(
                      label: confirmReceiptLabel(context),
                      isLoading: isPending,
                      onPressed: () => _handleConfirmReceipt(context, order.id),
                    ),
                  ],
                  if (isSellerSalesView &&
                      order.status == OrderStatus.paid) ...[
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
                      onPressed: () =>
                          _confirmCancelOrder(context, ref, order.id),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _DetailErrorState(
            onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _DetailErrorState(
          onRetry: () => ref.invalidate(orderDetailProvider(widget.orderId)),
        ),
      ),
    );
  }

  Future<void> _handleConfirmReceipt(
    BuildContext context,
    String orderId,
  ) async {
    final succeeded = await _runMutation(
      context,
      ref,
      orderId: orderId,
      action: 'confirm_receipt',
      task: () {
        return ref.read(orderMutationProvider.notifier).confirmReceipt(orderId);
      },
    );
    if (!context.mounted || !succeeded) return;
    await _maybeOpenReviewAfterCompletion(context, orderId);
  }

  Future<void> _openTrackingSheet(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final pageContext = context;
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
                    20,
                    AppSpacing.spacingM,
                    AppSpacing.spacingL,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trackingBottomSheetTitle(context),
                        style: AppTextStyles.sectionTitle.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacingXS),
                      Text(
                        trackingBottomSheetSubtitle(context),
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
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
                          final succeeded = await _runMutation(
                            pageContext,
                            ref,
                            orderId: orderId,
                            action: 'mark_shipped',
                            task: () => ref
                                .read(orderMutationProvider.notifier)
                                .markAsShipped(orderId, trackingCode),
                          );
                          if (!context.mounted) return;
                          if (succeeded) {
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isSubmitting = false;
                            });
                          }
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

  Future<void> _confirmCancelOrder(
    BuildContext context,
    WidgetRef ref,
    String orderId,
  ) async {
    final italian = isItalianOrders(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => DestructiveConfirmationDialog(
        title: cancelOrderDialogTitle(context),
        message: cancelOrderDialogMessage(context),
        confirmLabel: cancelOrderDialogConfirmLabel(context),
        cancelLabel: cancelOrderDialogCancelLabel(context),
      ),
    );

    if (messenger == null || shouldCancel != true) return;

    try {
      final latestOrder = await ref.read(orderDetailProvider(orderId).future);
      if (latestOrder.status != OrderStatus.paid) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              latestOrder.status == OrderStatus.cancelled
                  ? (italian
                        ? 'Questo ordine risulta gia annullato.'
                        : 'This order is already cancelled.')
                  : (italian
                        ? 'Questo ordine non e piu annullabile.'
                        : 'This order can no longer be cancelled.'),
            ),
          ),
        );
        return;
      }
    } catch (_) {
      // Fall through to the mutation; the service will surface a proper error if needed.
    }

    if (!context.mounted) {
      return;
    }
    await _runMutation(
      context,
      ref,
      orderId: orderId,
      action: 'cancel_order',
      task: () {
        return ref.read(orderMutationProvider.notifier).cancelOrder(orderId);
      },
    );
  }

  Future<void> _maybeOpenReviewAfterCompletion(
    BuildContext context,
    String orderId,
  ) async {
    ref.invalidate(orderDetailProvider(orderId));
    ref.invalidate(orderReviewProvider(orderId));
    final refreshedOrder = await ref.read(orderDetailProvider(orderId).future);
    final review = await ref.read(orderReviewProvider(orderId).future);
    if (!context.mounted) return;
    if (!isManualReviewWindowOpenForOrder(refreshedOrder, review: review)) {
      return;
    }
    await _openReviewSheet(context, orderId);
  }

  Future<void> _openReviewSheet(BuildContext context, String orderId) async {
    final pageContext = context;
    final messenger = ScaffoldMessenger.maybeOf(pageContext);
    final l10n = AppLocalizations.of(pageContext)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetNavigator = Navigator.of(sheetContext);
        return ReviewBottomSheet(
          orderId: orderId,
          onSubmitted: (rating, comment) async {
            try {
              await ref
                  .read(reviewSubmissionProvider.notifier)
                  .submitReview(
                    orderId: orderId,
                    rating: rating,
                    comment: comment,
                  );
              ref.invalidate(orderReviewProvider(orderId));
              ref.invalidate(orderDetailProvider(orderId));
              ref.invalidate(currentUserOrdersProvider);
              if (!sheetContext.mounted) return;
              sheetNavigator.pop();
              messenger?.showSnackBar(
                SnackBar(content: Text(l10n.reviewSubmittedSnackBar)),
              );
            } on ReviewsServiceException catch (error) {
              ref.invalidate(orderReviewProvider(orderId));
              ref.invalidate(orderDetailProvider(orderId));
              if (error.code == 'review_window_expired' ||
                  error.code == 'review_already_exists') {
                if (sheetContext.mounted && sheetNavigator.canPop()) {
                  sheetNavigator.pop();
                }
              }
              if (!pageContext.mounted) return;
              if (error.code == 'review_window_expired') {
                ref.invalidate(currentUserOrdersProvider);
              }
              messenger?.showSnackBar(
                SnackBar(content: Text(_reviewErrorText(pageContext, error))),
              );
            }
          },
        );
      },
    );
  }

  Future<bool> _runMutation(
    BuildContext context,
    WidgetRef ref, {
    required String orderId,
    required String action,
    required Future<void> Function() task,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final successMessage = mutationSuccessMessage(context, action);
    try {
      await task();
      if (!context.mounted) return true;
      messenger?.showSnackBar(SnackBar(content: Text(successMessage)));
      return true;
    } on OrdersServiceException catch (error) {
      if (error.code == 'invalid_order_transition' ||
          error.code == 'order_not_paid' ||
          error.code == 'shipping_deadline_elapsed' ||
          error.code == 'shipping_window_expired' ||
          error.code == 'order_auto_cancel_pending') {
        ref.invalidate(orderDetailProvider(orderId));
        ref.invalidate(currentUserOrdersProvider);
      }
      if (!context.mounted) return false;
      messenger?.showSnackBar(
        SnackBar(content: Text(_mutationErrorText(context, error))),
      );
      return false;
    }
  }

  String _errorText(BuildContext context, OrdersServiceException error) {
    if (error.code == 'invalid_tracking_code') {
      return trackingRequired(context);
    }
    if (error.code == 'shipping_deadline_elapsed' ||
        error.code == 'shipping_window_expired') {
      return isItalianOrders(context)
          ? 'La finestra di spedizione e scaduta: non puoi piu segnare questo ordine come spedito.'
          : 'The shipping window has expired: you can no longer mark this order as shipped.';
    }
    if (error.code == 'order_auto_cancel_pending') {
      return isItalianOrders(context)
          ? 'Esiste gia una cancellazione automatica in corso per questo ordine.'
          : 'An automatic cancellation is already in progress for this order.';
    }
    if (error.code == 'missing_runtime_secret') {
      return isItalianOrders(context)
          ? 'Il backend non e configurato correttamente per aggiornare l\'ordine.'
          : 'The backend is not configured correctly to update this order.';
    }
    if (error.code == 'invalid_order_transition' ||
        error.code == 'order_not_paid') {
      return isItalianOrders(context)
          ? 'Questo ordine non è più annullabile o aggiornabile in questo stato.'
          : 'This order can no longer be cancelled or updated in its current state.';
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

  String _mutationErrorText(
    BuildContext context,
    OrdersServiceException error,
  ) {
    final baseMessage = _errorText(context, error);
    final code = error.code ?? 'unknown';
    final requestId = error.requestId ?? 'unknown';
    return '$baseMessage\n\nOrder update failed:\n$code\n$requestId';
  }

  String _reviewErrorText(BuildContext context, ReviewsServiceException error) {
    final l10n = AppLocalizations.of(context)!;
    if (error.code == 'review_window_expired') {
      return l10n.reviewWindowExpiredMessage;
    }
    if (error.code == 'review_already_exists') {
      return l10n.reviewAlreadySubmittedMessage;
    }
    return l10n.reviewSubmitErrorMessage;
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

  String _shortReference(String id) {
    final normalized = id.replaceAll('-', '').toUpperCase();
    final suffix = normalized.length <= 6
        ? normalized
        : normalized.substring(normalized.length - 6);
    return '#$suffix';
  }

  Future<void> _copyTrackingCode(
    BuildContext context,
    String trackingCode,
  ) async {
    await Clipboard.setData(ClipboardData(text: trackingCode));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(trackingCodeCopiedMessage(context))));
  }
}

class _ReadOnlyTrackingField extends StatelessWidget {
  const _ReadOnlyTrackingField({required this.value, required this.onCopy});

  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppShadows.authField,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFFD7C6)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.accent,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.spacingXS),
            IconButton(
              onPressed: onCopy,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              iconSize: 18,
              tooltip: isItalianOrders(context)
                  ? 'Copia codice tracking'
                  : 'Copy tracking code',
              icon: const Icon(Icons.copy_rounded, color: AppColors.black50),
            ),
          ],
        ),
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
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(label: retryLabel(context), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
