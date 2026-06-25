import 'package:flutter/material.dart';
import 'package:truffly_app/features/orders/domain/order_status.dart';
import 'package:truffly_app/features/orders/domain/orders_filter.dart';

bool isItalianOrders(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'it';
}

String orderPageTitle(BuildContext context) {
  return isItalianOrders(context) ? 'I miei ordini' : 'My orders';
}

String ordersScopeLabel(BuildContext context, bool sales) {
  if (isItalianOrders(context)) return sales ? 'Vendite' : 'Acquisti';
  return sales ? 'Sales' : 'Purchases';
}

String ordersFilterLabel(BuildContext context, OrdersFilter filter) {
  final italian = isItalianOrders(context);
  return switch (filter) {
    OrdersFilter.all => italian ? 'Tutti' : 'All',
    OrdersFilter.inProgress => italian ? 'In corso' : 'In progress',
    OrdersFilter.completed => italian ? 'Completati' : 'Completed',
    OrdersFilter.cancelled => italian ? 'Annullati' : 'Cancelled',
  };
}

String orderStatusLabel(
  BuildContext context,
  OrderStatus status, {
  bool sellerTone = false,
}) {
  final italian = isItalianOrders(context);
  return switch (status) {
    OrderStatus.paid =>
      sellerTone
          ? (italian ? 'Da spedire' : 'Ready to ship')
          : (italian ? 'Ordine confermato' : 'Order confirmed'),
    OrderStatus.shipped => italian ? 'Spedito' : 'Shipped',
    OrderStatus.completed => italian ? 'Completato' : 'Completed',
    OrderStatus.cancelled => italian ? 'Annullato' : 'Cancelled',
  };
}

String orderStatusDescription(
  BuildContext context,
  OrderStatus status, {
  required bool isSellerView,
}) {
  final italian = isItalianOrders(context);
  return switch (status) {
    OrderStatus.paid =>
      isSellerView
          ? (italian
                ? "Il pagamento e stato confermato. Spedisci entro 48 ore per mantenere l'ordine attivo."
                : 'Payment has been confirmed. Ship within 48 hours to keep the order active.')
          : (italian
                ? 'Il pagamento e confermato. Il venditore sta preparando la spedizione.'
                : 'Payment is confirmed. The seller is preparing shipment.'),
    OrderStatus.shipped =>
      isSellerView
          ? (italian
                ? 'La spedizione e stata registrata. Il payout partira dopo la conferma di ricezione.'
                : 'Shipment has been registered. The payout starts after delivery is confirmed.')
          : (italian
                ? 'Il tuo ordine e in viaggio. Controlla il tracking per seguire il pacco.'
                : 'Your order is on the way. Check tracking to follow the package.'),
    OrderStatus.completed =>
      isSellerView
          ? (italian
                ? "L'ordine e stato completato e il pagamento e stato confermato."
                : 'The order is completed and payment has been confirmed.')
          : (italian
                ? "L'ordine e stato consegnato e completato correttamente."
                : 'The order has been delivered and completed successfully.'),
    OrderStatus.cancelled =>
      italian
          ? 'Questo ordine e stato annullato.'
          : 'This order has been cancelled.',
  };
}

String ordersEmptyTitle(
  BuildContext context, {
  required OrdersFilter filter,
  required bool isSalesScope,
}) {
  final italian = isItalianOrders(context);
  if (isSalesScope) {
    return switch (filter) {
      OrdersFilter.all => italian ? 'Nessuna vendita' : 'No sales yet',
      OrdersFilter.inProgress =>
        italian ? 'Nessuna vendita in corso' : 'No sales in progress',
      OrdersFilter.completed =>
        italian ? 'Nessuna vendita completata' : 'No completed sales',
      OrdersFilter.cancelled =>
        italian ? 'Nessuna vendita annullata' : 'No cancelled sales',
    };
  }
  return switch (filter) {
    OrdersFilter.all => italian ? 'Nessun ordine' : 'No orders yet',
    OrdersFilter.inProgress =>
      italian ? 'Nessun ordine in corso' : 'No orders in progress',
    OrdersFilter.completed =>
      italian ? 'Nessun ordine completato' : 'No completed orders',
    OrdersFilter.cancelled =>
      italian ? 'Nessun ordine annullato' : 'No cancelled orders',
  };
}

String ordersEmptySubtitle(
  BuildContext context, {
  required OrdersFilter filter,
  required bool isSalesScope,
}) {
  final italian = isItalianOrders(context);
  if (isSalesScope) {
    return switch (filter) {
      OrdersFilter.all =>
        italian
            ? 'Le tue vendite compariranno qui appena riceverai i primi ordini.'
            : 'Your sales will appear here as soon as you receive your first orders.',
      OrdersFilter.inProgress =>
        italian
            ? 'Quando un ordine sara confermato o spedito lo troverai in questa sezione.'
            : 'Confirmed or shipped sales will appear here.',
      OrdersFilter.completed =>
        italian
            ? 'Le vendite concluse con successo appariranno qui.'
            : 'Successfully completed sales will appear here.',
      OrdersFilter.cancelled =>
        italian
            ? 'Le vendite annullate appariranno qui se presenti.'
            : 'Cancelled sales will appear here if any exist.',
    };
  }
  return switch (filter) {
    OrdersFilter.all =>
      italian
          ? 'I tuoi acquisti compariranno qui dopo il checkout.'
          : 'Your purchases will appear here after checkout.',
    OrdersFilter.inProgress =>
      italian
          ? 'Gli ordini confermati o spediti compariranno qui.'
          : 'Confirmed or shipped orders will appear here.',
    OrdersFilter.completed =>
      italian
          ? 'Gli ordini completati appariranno qui.'
          : 'Completed orders will appear here.',
    OrdersFilter.cancelled =>
      italian
          ? 'Gli ordini annullati appariranno qui se presenti.'
          : 'Cancelled orders will appear here if any exist.',
  };
}

String ordersLoadError(BuildContext context) {
  return isItalianOrders(context)
      ? 'Impossibile caricare gli ordini in questo momento.'
      : 'Unable to load orders right now.';
}

String retryLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Riprova' : 'Retry';
}

String sellerLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Venditore' : 'Seller';
}

String buyerLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Acquirente' : 'Buyer';
}

String boughtOnLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Acquistato il' : 'Purchased on';
}

String shippingAddressTitle(BuildContext context) {
  return isItalianOrders(context)
      ? 'Indirizzo di spedizione'
      : 'Shipping address';
}

String trackPackageTitle(BuildContext context) {
  return isItalianOrders(context)
      ? 'Traccia il tuo pacco'
      : 'Track your parcel';
}

String trackingCodeCopiedMessage(BuildContext context) {
  return isItalianOrders(context)
      ? 'Codice tracking copiato.'
      : 'Tracking code copied.';
}

String confirmReceiptLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Conferma ricezione' : 'Confirm receipt';
}

String markAsShippedLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Segna come spedito' : 'Mark as shipped';
}

String cancelOrderLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Annulla ordine' : 'Cancel order';
}

String cancelOrderDialogTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Annullare l\'ordine?' : 'Cancel order?';
}

String cancelOrderDialogMessage(BuildContext context) {
  return isItalianOrders(context)
      ? 'Il buyer riceverà automaticamente un rimborso Stripe e l\'ordine verrà segnato come annullato.'
      : 'The buyer will be automatically refunded via Stripe and the order will be marked as cancelled.';
}

String cancelOrderDialogConfirmLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Annulla ordine' : 'Cancel order';
}

String cancelOrderDialogCancelLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Torna indietro' : 'Go back';
}

String shippingDeadlineTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Limite spedizione' : 'Shipping deadline';
}

String shippingDeadlineCopy(BuildContext context) {
  return isItalianOrders(context)
      ? "Spedisci entro 48 ore dall'acquisto. Se non viene registrata una spedizione in tempo, l'ordine puo essere annullato."
      : 'Ship within 48 hours from purchase. If shipping is not registered in time, the order may be cancelled.';
}

String shippingDeadlineHighlight(
  BuildContext context,
  DateTime purchasedAt,
) {
  final deadline = purchasedAt.toLocal().add(const Duration(hours: 48));
  final localizations = MaterialLocalizations.of(context);
  final date = localizations.formatMediumDate(deadline);
  final time = localizations.formatTimeOfDay(
    TimeOfDay.fromDateTime(deadline),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  return isItalianOrders(context)
      ? 'Da spedire entro $date alle $time'
      : 'Ship by $date at $time';
}

String paymentStatusTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Stato pagamento' : 'Payment status';
}

String paymentStatusCopy(BuildContext context, OrderStatus status) {
  final italian = isItalianOrders(context);
  return switch (status) {
    OrderStatus.paid =>
      italian
          ? 'Pagamento confermato e gestito da Stripe fino alla spedizione.'
          : 'Payment confirmed and handled by Stripe until shipment.',
    OrderStatus.shipped =>
      italian
          ? 'Il payout al seller partira dopo conferma di ricezione o completamento.'
          : 'Seller payout starts after delivery is confirmed or the order is completed.',
    OrderStatus.completed =>
      italian
          ? 'Ordine completato e payout gestito lato backend.'
          : 'Order completed and payout handled server-side.',
    OrderStatus.cancelled =>
      italian
          ? 'Ordine annullato. Il rimborso viene gestito lato backend.'
          : 'Order cancelled. Refund is handled server-side.',
  };
}

String financialStatusTitle(BuildContext context) {
  return isItalianOrders(context)
      ? 'Stato finanziario'
      : 'Financial status';
}

String financialStatusCopy(
  BuildContext context, {
  required OrderStatus status,
  required bool isSellerView,
  required String? payoutStatus,
  required String? refundStatus,
}) {
  final italian = isItalianOrders(context);

  if (status == OrderStatus.cancelled) {
    if (refundStatus == 'succeeded') {
      return italian
          ? 'Rimborso elaborato con successo.'
          : 'Refund processed successfully.';
    }
    if (refundStatus == 'failed') {
      return italian
          ? 'Il rimborso richiede un nuovo tentativo lato backend.'
          : 'The refund requires a backend retry.';
    }
    return italian
        ? 'L ordine e annullato. Il rimborso viene gestito lato backend.'
        : 'The order is cancelled. The refund is handled server-side.';
  }

  if (status == OrderStatus.completed) {
    if (payoutStatus == 'succeeded') {
      return isSellerView
          ? (italian
                ? 'Il payout al seller e stato registrato.'
                : 'Seller payout has been recorded.')
          : (italian
                ? 'L ordine e completato e il payout al seller e stato registrato.'
                : 'The order is complete and the seller payout has been recorded.');
    }
    if (payoutStatus == 'failed') {
      return italian
          ? 'Il payout richiede un nuovo tentativo lato backend, ma l ordine resta completato.'
          : 'Payout needs a backend retry, but the order remains completed.';
    }
    if (payoutStatus == 'processing') {
      return italian
          ? 'Il payout e in lavorazione lato backend.'
          : 'Payout is being processed server-side.';
    }
  }

  return paymentStatusCopy(context, status);
}

String supportTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Supporto' : 'Support';
}

String supportCopy(BuildContext context) {
  return isItalianOrders(context)
      ? "Hai qualche problema con il tuo ordine? Contatta l'assistenza."
      : 'Having a problem with your order? Contact support.';
}

String cancelledCardTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Ordine annullato' : 'Order cancelled';
}

String timelineTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Stato ordine' : 'Order status';
}

String timelineStepConfirmed(BuildContext context) {
  return isItalianOrders(context) ? 'Ordine confermato' : 'Order confirmed';
}

String timelineStepShipped(BuildContext context) {
  return isItalianOrders(context) ? 'Spedito' : 'Shipped';
}

String timelineStepCompleted(BuildContext context) {
  return isItalianOrders(context) ? 'Completato' : 'Completed';
}

String timelineStepStateLabel(
  BuildContext context, {
  required bool isReached,
  required bool isCurrent,
}) {
  final italian = isItalianOrders(context);
  if (isCurrent) {
    return italian ? 'In corso' : 'In progress';
  }
  if (isReached) {
    return italian ? 'Completato' : 'Done';
  }
  return italian ? 'In attesa' : 'Pending';
}

String trackingCodeLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Codice tracking' : 'Tracking code';
}

String trackingHint(BuildContext context) {
  return isItalianOrders(context)
      ? 'Inserisci il codice tracking'
      : 'Enter the tracking code';
}

String trackingBottomSheetTitle(BuildContext context) {
  return isItalianOrders(context) ? 'Conferma spedizione' : 'Confirm shipment';
}

String trackingBottomSheetSubtitle(BuildContext context) {
  return isItalianOrders(context)
      ? "Inserisci il tracking code per aggiornare l'ordine come spedito."
      : 'Enter the tracking code to update the order as shipped.';
}

String trackingRequired(BuildContext context) {
  return isItalianOrders(context)
      ? 'Il tracking code e obbligatorio.'
      : 'Tracking code is required.';
}

String closeLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Chiudi' : 'Close';
}

String confirmLabel(BuildContext context) {
  return isItalianOrders(context) ? 'Conferma' : 'Confirm';
}

String mutationSuccessMessage(BuildContext context, String action) {
  final italian = isItalianOrders(context);
  return switch (action) {
    'confirm_receipt' =>
      italian
          ? 'Ordine completato con successo.'
          : 'Order completed successfully.',
    'mark_shipped' =>
      italian ? 'Ordine aggiornato come spedito.' : 'Order updated as shipped.',
    'cancel_order' =>
      italian
          ? 'Ordine annullato con successo.'
          : 'Order cancelled successfully.',
    _ => italian ? 'Ordine aggiornato.' : 'Order updated.',
  };
}

String genericMutationError(BuildContext context) {
  return isItalianOrders(context)
      ? "Non e stato possibile aggiornare l'ordine."
      : 'Unable to update the order.';
}
