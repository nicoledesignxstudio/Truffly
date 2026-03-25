import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_providers.dart';
import 'package:truffly_app/features/account/data/shipping_addresses_service.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_state.dart';

final shippingAddressFormNotifierProvider = AutoDisposeNotifierProvider.family<
  ShippingAddressFormNotifier,
  ShippingAddressFormState,
  String?
>(ShippingAddressFormNotifier.new);

final class ShippingAddressFormNotifier
    extends AutoDisposeFamilyNotifier<ShippingAddressFormState, String?> {
  @override
  ShippingAddressFormState build(String? arg) {
    Future.microtask(_load);
    return const ShippingAddressFormState.loading();
  }

  void updateFullName(String value) => _updateField(
    ShippingAddressField.fullName,
    (form) => form.copyWith(fullName: value),
  );

  void updateStreet(String value) => _updateField(
    ShippingAddressField.street,
    (form) => form.copyWith(street: value),
  );

  void updateCity(String value) => _updateField(
    ShippingAddressField.city,
    (form) => form.copyWith(city: value),
  );

  void updatePostalCode(String value) => _updateField(
    ShippingAddressField.postalCode,
    (form) => form.copyWith(postalCode: value),
  );

  void updateCountryCode(String value) => _updateField(
    ShippingAddressField.countryCode,
    (form) => form.copyWith(countryCode: value.trim().toUpperCase()),
  );

  void updatePhone(String value) => _updateField(
    ShippingAddressField.phone,
    (form) => form.copyWith(phone: value),
  );

  void updateIsDefault(bool value) {
    final currentForm = state.form;
    if (currentForm == null || state.isSaving || state.isDeleting) return;

    state = state.copyWith(
      form: currentForm.copyWith(isDefault: value),
      errorMessage: null,
      lastSavedAddress: null,
      deletedAddressId: null,
    );
  }

  String? errorFor(ShippingAddressField field) {
    final form = state.form;
    if (form == null) return null;

    final shouldShow = state.submitAttempted || state.touchedFields.contains(field);
    if (!shouldShow) return null;

    return switch (field) {
      ShippingAddressField.fullName => _requiredError(form.fullName),
      ShippingAddressField.street => _requiredError(form.street),
      ShippingAddressField.city => _cityError(form.city),
      ShippingAddressField.postalCode => _postalCodeError(
        form.postalCode,
        form.countryCode,
      ),
      ShippingAddressField.countryCode => _countryError(form.countryCode),
      ShippingAddressField.phone => _phoneError(form.phone),
    };
  }

  bool canSubmit() {
    final form = state.form;
    if (form == null || state.isSaving || state.isDeleting) return false;

    final initialForm = state.initialForm;
    if (initialForm == null) return false;

    return !form.isEditing || form.hasChangesComparedTo(initialForm);
  }

  Future<bool> save() async {
    final currentForm = state.form;
    if (currentForm == null) return false;

    if (_hasValidationErrors(currentForm)) {
      state = state.copyWith(
        submitAttempted: true,
        errorMessage: null,
        lastSavedAddress: null,
      );
      return false;
    }

    state = state.copyWith(
      status: ShippingAddressFormStatus.saving,
      submitAttempted: true,
      errorMessage: null,
      lastSavedAddress: null,
      deletedAddressId: null,
    );

    try {
      final savedAddress = await ref
          .read(shippingAddressesServiceProvider)
          .saveAddress(currentForm);
      final savedForm = ShippingAddressFormData.fromAddress(savedAddress);

      state = state.copyWith(
        status: ShippingAddressFormStatus.ready,
        form: savedForm,
        initialForm: savedForm,
        errorMessage: null,
        lastSavedAddress: savedAddress,
      );
      return true;
    } on ShippingAddressesException catch (error) {
      state = state.copyWith(
        status: ShippingAddressFormStatus.ready,
        errorMessage: _mapFailureToMessage(error),
        lastSavedAddress: null,
      );
      return false;
    }
  }

  Future<bool> delete() async {
    final addressId = state.form?.id;
    if (addressId == null) return false;

    state = state.copyWith(
      status: ShippingAddressFormStatus.deleting,
      errorMessage: null,
      lastSavedAddress: null,
      deletedAddressId: null,
    );

    try {
      await ref.read(shippingAddressesServiceProvider).deleteAddress(addressId);
      state = state.copyWith(
        status: ShippingAddressFormStatus.ready,
        deletedAddressId: addressId,
      );
      return true;
    } on ShippingAddressesException catch (error) {
      state = state.copyWith(
        status: ShippingAddressFormStatus.ready,
        errorMessage: _mapFailureToMessage(error),
      );
      return false;
    }
  }

  Future<void> _load() async {
    final addressId = arg;
    if (addressId == null) {
      final form = ShippingAddressFormData.empty();
      state = ShippingAddressFormState(
        status: ShippingAddressFormStatus.ready,
        form: form,
        initialForm: form,
        touchedFields: const <ShippingAddressField>{},
        submitAttempted: false,
        errorMessage: null,
        lastSavedAddress: null,
        deletedAddressId: null,
      );
      return;
    }

    try {
      final address = await ref
          .read(shippingAddressesServiceProvider)
          .fetchAddressById(addressId);
      final form = ShippingAddressFormData.fromAddress(address);
      state = ShippingAddressFormState(
        status: ShippingAddressFormStatus.ready,
        form: form,
        initialForm: form,
        touchedFields: const <ShippingAddressField>{},
        submitAttempted: false,
        errorMessage: null,
        lastSavedAddress: null,
        deletedAddressId: null,
      );
    } on ShippingAddressesException catch (error) {
      state = ShippingAddressFormState(
        status: ShippingAddressFormStatus.ready,
        form: null,
        initialForm: null,
        touchedFields: const <ShippingAddressField>{},
        submitAttempted: false,
        errorMessage: _mapFailureToMessage(error),
        lastSavedAddress: null,
        deletedAddressId: null,
      );
    }
  }

  void _updateField(
    ShippingAddressField field,
    ShippingAddressFormData Function(ShippingAddressFormData form) update,
  ) {
    final currentForm = state.form;
    if (currentForm == null || state.isSaving || state.isDeleting) return;

    state = state.copyWith(
      status: ShippingAddressFormStatus.ready,
      form: update(currentForm),
      touchedFields: {...state.touchedFields, field},
      errorMessage: null,
      lastSavedAddress: null,
      deletedAddressId: null,
    );
  }

  bool _hasValidationErrors(ShippingAddressFormData form) {
    return _requiredError(form.fullName) != null ||
        _requiredError(form.street) != null ||
        _cityError(form.city) != null ||
        _postalCodeError(form.postalCode, form.countryCode) != null ||
        _countryError(form.countryCode) != null ||
        _phoneError(form.phone) != null;
  }

  String? _requiredError(String value) {
    return value.trim().isEmpty ? 'required' : null;
  }

  String? _countryError(String value) {
    final countryCode = value.trim().toUpperCase();
    if (countryCode.isEmpty) return 'country_required';
    if (!isSupportedEuropeanCountryCode(countryCode)) return 'country_invalid';
    return null;
  }

  String? _cityError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'required';
    if (trimmed.length < 2) return 'city_invalid';
    if (!RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]+$").hasMatch(trimmed)) {
      return 'city_invalid';
    }
    return null;
  }

  String? _postalCodeError(String postalCode, String countryCode) {
    final trimmedPostalCode = postalCode.trim();
    if (trimmedPostalCode.isEmpty) return 'required';

    final normalizedCountryCode = countryCode.trim().toUpperCase();
    if (normalizedCountryCode == 'IT') {
      return RegExp(r'^\d{5}$').hasMatch(trimmedPostalCode)
          ? null
          : 'postal_code_invalid';
    }

    return RegExp(r'^[A-Za-z0-9 -]{3,10}$').hasMatch(trimmedPostalCode)
        ? null
        : 'postal_code_invalid';
  }

  String? _phoneError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'required';
    if (!trimmed.startsWith('+')) return 'phone_invalid';

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 7 || digitsOnly.length > 15) {
      return 'phone_invalid';
    }

    return null;
  }

  String _mapFailureToMessage(ShippingAddressesException error) {
    return switch (error.failure) {
      ShippingAddressesFailure.network => 'network',
      ShippingAddressesFailure.unauthorized => 'unauthorized',
      ShippingAddressesFailure.notFound => 'not_found',
      ShippingAddressesFailure.validation => error.code ?? 'validation',
      ShippingAddressesFailure.unknown => 'unknown',
    };
  }
}
