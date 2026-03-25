import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';

enum ShippingAddressField {
  fullName,
  street,
  city,
  postalCode,
  countryCode,
  phone,
}

enum ShippingAddressFormStatus { loading, ready, saving, deleting }

final class ShippingAddressFormState {
  const ShippingAddressFormState({
    required this.status,
    required this.form,
    required this.initialForm,
    required this.touchedFields,
    required this.submitAttempted,
    required this.errorMessage,
    required this.lastSavedAddress,
    required this.deletedAddressId,
  });

  const ShippingAddressFormState.loading()
      : status = ShippingAddressFormStatus.loading,
        form = null,
        initialForm = null,
        touchedFields = const <ShippingAddressField>{},
        submitAttempted = false,
        errorMessage = null,
        lastSavedAddress = null,
        deletedAddressId = null;

  final ShippingAddressFormStatus status;
  final ShippingAddressFormData? form;
  final ShippingAddressFormData? initialForm;
  final Set<ShippingAddressField> touchedFields;
  final bool submitAttempted;
  final String? errorMessage;
  final ShippingAddress? lastSavedAddress;
  final String? deletedAddressId;

  bool get isLoading => status == ShippingAddressFormStatus.loading;
  bool get isSaving => status == ShippingAddressFormStatus.saving;
  bool get isDeleting => status == ShippingAddressFormStatus.deleting;

  ShippingAddressFormState copyWith({
    ShippingAddressFormStatus? status,
    Object? form = _sentinel,
    Object? initialForm = _sentinel,
    Set<ShippingAddressField>? touchedFields,
    bool? submitAttempted,
    Object? errorMessage = _sentinel,
    Object? lastSavedAddress = _sentinel,
    Object? deletedAddressId = _sentinel,
  }) {
    return ShippingAddressFormState(
      status: status ?? this.status,
      form: identical(form, _sentinel) ? this.form : form as ShippingAddressFormData?,
      initialForm: identical(initialForm, _sentinel)
          ? this.initialForm
          : initialForm as ShippingAddressFormData?,
      touchedFields: touchedFields ?? this.touchedFields,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      lastSavedAddress: identical(lastSavedAddress, _sentinel)
          ? this.lastSavedAddress
          : lastSavedAddress as ShippingAddress?,
      deletedAddressId: identical(deletedAddressId, _sentinel)
          ? this.deletedAddressId
          : deletedAddressId as String?,
    );
  }
}

const _sentinel = Object();
