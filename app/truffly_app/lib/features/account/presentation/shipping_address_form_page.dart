import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/shipping_address_form_notifier.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_data.dart';
import 'package:truffly_app/features/account/domain/shipping_address_form_state.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_country_options.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ShippingAddressFormPage extends ConsumerStatefulWidget {
  const ShippingAddressFormPage({
    super.key,
    this.addressId,
  });

  final String? addressId;

  @override
  ConsumerState<ShippingAddressFormPage> createState() =>
      _ShippingAddressFormPageState();
}

class _ShippingAddressFormPageState
    extends ConsumerState<ShippingAddressFormPage> {
  final _fullNameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  ShippingAddressFormData? _hydratedForm;
  String? _selectedPhonePrefix;

  @override
  void dispose() {
    _fullNameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(
      shippingAddressFormNotifierProvider(widget.addressId),
    );
    final notifier = ref.read(
      shippingAddressFormNotifierProvider(widget.addressId).notifier,
    );
    final form = state.form;
    final isBusy = state.isSaving || state.isDeleting;

    if (form != null && _hydratedForm != state.initialForm) {
      _fullNameController.text = form.fullName;
      _streetController.text = form.street;
      _cityController.text = form.city;
      _postalCodeController.text = form.postalCode;
      final detectedPrefix =
          detectEuropeanPhonePrefix(form.phone) ??
          europeanCountryPhonePrefix(form.countryCode);
      _selectedPhonePrefix = detectedPrefix;
      _phoneController.text = stripPhonePrefix(form.phone, detectedPrefix);
      _hydratedForm = state.initialForm;
    }

    return PopScope(
      canPop: !isBusy,
      child: Scaffold(
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
              onPressed: isBusy
                  ? null
                  : () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.accountShipping);
                      }
                    },
            ),
          ),
          title: Text(
            widget.addressId == null
                ? l10n.shippingAddressAddTitle
                : l10n.shippingAddressEditTitle,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
          ),
        ),
        bottomNavigationBar: form == null
            ? null
            : SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.spacingM,
                    AppSpacing.spacingS,
                    AppSpacing.spacingM,
                    AppSpacing.spacingM,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AuthPrimaryButton(
                        key: const Key('shipping_save_button'),
                        label: l10n.shippingAddressSaveCta,
                        backgroundColor: AppColors.black,
                        enabled: notifier.canSubmit(),
                        isLoading: state.isSaving,
                        onPressed: notifier.canSubmit()
                            ? () => _handleSave(notifier)
                            : null,
                      ),
                      if (form.isEditing) ...[
                        const SizedBox(height: AppSpacing.spacingXS),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: isBusy ? null : () => _handleDelete(notifier),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.authBorderRadius,
                              ),
                              textStyle: AppTextStyles.buttonText,
                            ),
                            child: state.isDeleting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.error,
                                    ),
                                  )
                                : Text(l10n.shippingAddressDeleteCta),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
        body: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : form == null
                  ? _ShippingAddressFormErrorState(
                      message: _submitMessage(
                        l10n,
                        state.errorMessage ?? 'unknown',
                      ),
                      onRetry: () => ref.invalidate(
                        shippingAddressFormNotifierProvider(widget.addressId),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.spacingM,
                        AppSpacing.spacingS,
                        AppSpacing.spacingM,
                        AppSpacing.spacingXXL,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.shippingAddressFormSubtitle,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.black80,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingL),
                          _FieldLabel(label: l10n.shippingAddressFullNameLabel),
                          AuthTextField(
                            key: const Key('shipping_full_name_field'),
                            controller: _fullNameController,
                            labelText: l10n.shippingAddressFullNamePlaceholder,
                            enabled: !isBusy,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            onChanged: notifier.updateFullName,
                            errorText: _fieldError(
                              l10n,
                              notifier.errorFor(ShippingAddressField.fullName),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _FieldLabel(label: l10n.shippingAddressStreetLabel),
                          AuthTextField(
                            key: const Key('shipping_street_field'),
                            controller: _streetController,
                            labelText: l10n.shippingAddressStreetPlaceholder,
                            enabled: !isBusy,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            onChanged: notifier.updateStreet,
                            errorText: _fieldError(
                              l10n,
                              notifier.errorFor(ShippingAddressField.street),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _FieldLabel(label: l10n.shippingAddressCityLabel),
                          AuthTextField(
                            key: const Key('shipping_city_field'),
                            controller: _cityController,
                            labelText: l10n.shippingAddressCityPlaceholder,
                            enabled: !isBusy,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            onChanged: notifier.updateCity,
                            errorText: _fieldError(
                              l10n,
                              notifier.errorFor(ShippingAddressField.city),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _FieldLabel(label: l10n.shippingAddressPostalCodeLabel),
                          AuthTextField(
                            key: const Key('shipping_postal_code_field'),
                            controller: _postalCodeController,
                            labelText: l10n.shippingAddressPostalCodePlaceholder,
                            enabled: !isBusy,
                            keyboardType: TextInputType.streetAddress,
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.singleLineFormatter,
                            ],
                            onChanged: notifier.updatePostalCode,
                            errorText: _fieldError(
                              l10n,
                              notifier.errorFor(ShippingAddressField.postalCode),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _FieldLabel(label: l10n.shippingAddressCountryLabel),
                          OnboardingDropdownField<String>(
                            key: const Key('shipping_country_field'),
                            initialValue: form.countryCode.isEmpty
                                ? null
                                : form.countryCode,
                            hintText: l10n.shippingAddressCountryPlaceholder,
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(
                                  l10n.shippingAddressCountryPlaceholder,
                                ),
                              ),
                              for (final option in onboardingCountryOptions)
                                DropdownMenuItem<String>(
                                  value: option.code,
                                  child: Text(
                                    option.localizedName(l10n),
                                  ),
                                ),
                            ],
                            errorText: _fieldError(
                              l10n,
                              notifier.errorFor(ShippingAddressField.countryCode),
                            ),
                            onChanged: isBusy
                                ? (_) {}
                                : (value) => _handleCountryChanged(
                                      notifier,
                                      value ?? '',
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _FieldLabel(label: l10n.shippingAddressPhoneLabel),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 123,
                                child: OnboardingDropdownField<String>(
                                  key: const Key('shipping_phone_prefix_field'),
                                  initialValue: _selectedPhonePrefix,
                                  hintText: _phonePrefixHint(l10n),
                                  items: [
                                    for (final option in onboardingCountryOptions)
                                      DropdownMenuItem<String>(
                                        value: option.phonePrefix,
                                        child: Text(option.phonePrefix),
                                      ),
                                  ],
                                  onChanged: isBusy
                                      ? (_) {}
                                      : (value) => _handlePhonePrefixChanged(
                                            notifier,
                                            value,
                                          ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.spacingXS),
                              Expanded(
                                flex: 4,
                                child: AuthTextField(
                                  key: const Key('shipping_phone_field'),
                                  controller: _phoneController,
                                  labelText: _phoneNumberPlaceholder(l10n),
                                  enabled: !isBusy,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .singleLineFormatter,
                                  ],
                                  onChanged: (_) =>
                                      _syncCombinedPhoneValue(notifier),
                                  errorText: _fieldError(
                                    l10n,
                                    notifier.errorFor(ShippingAddressField.phone),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                          _DefaultAddressSwitch(
                            value: form.isDefault,
                            onChanged: isBusy ? null : notifier.updateIsDefault,
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: AppSpacing.spacingM),
                            Text(
                              _submitMessage(l10n, state.errorMessage!),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Future<void> _handleSave(ShippingAddressFormNotifier notifier) async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final didSave = await notifier.save();
    final state = ref.read(shippingAddressFormNotifierProvider(widget.addressId));

    if (!mounted) return;

    if (!didSave) {
      final errorMessage = state.errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_submitMessage(l10n, errorMessage))),
        );
      }
      return;
    }

    if (context.canPop()) {
      context.pop('saved');
    }
  }

  Future<void> _handleDelete(ShippingAddressFormNotifier notifier) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.shippingAddressDeleteDialogTitle),
        content: Text(l10n.shippingAddressDeleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.shippingAddressDeleteDialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.shippingAddressDeleteDialogConfirm),
          ),
        ],
      ),
    );

    if (!mounted || shouldDelete != true) return;

    final didDelete = await notifier.delete();
    final state = ref.read(shippingAddressFormNotifierProvider(widget.addressId));

    if (!mounted) return;

    if (!didDelete) {
      final errorMessage = state.errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_submitMessage(l10n, errorMessage))),
        );
      }
      return;
    }

    if (context.canPop()) {
      context.pop('deleted');
    }
  }

  void _handleCountryChanged(
    ShippingAddressFormNotifier notifier,
    String value,
  ) {
    notifier.updateCountryCode(value);

    final nextPrefix = europeanCountryPhonePrefix(value);
    setState(() {
      _selectedPhonePrefix = nextPrefix;
    });
    _syncCombinedPhoneValue(notifier);
  }

  void _handlePhonePrefixChanged(
    ShippingAddressFormNotifier notifier,
    String? value,
  ) {
    setState(() {
      _selectedPhonePrefix = value;
    });
    _syncCombinedPhoneValue(notifier);
  }

  void _syncCombinedPhoneValue(ShippingAddressFormNotifier notifier) {
    notifier.updatePhone(
      combinePhoneNumber(
        phonePrefix: _selectedPhonePrefix,
        localNumber: _phoneController.text,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.spacingXS,
        bottom: AppSpacing.spacingXS,
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(
          color: AppColors.black50,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _DefaultAddressSwitch extends StatelessWidget {
  const _DefaultAddressSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10, width: 1.2),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingXS,
        ),
        activeThumbColor: AppColors.accent,
        title: Text(
          l10n.shippingAddressDefaultToggleLabel,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          l10n.shippingAddressDefaultToggleHelper,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.black80,
          ),
        ),
      ),
    );
  }
}

class _ShippingAddressFormErrorState extends StatelessWidget {
  const _ShippingAddressFormErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              label: l10n.truffleRetry,
              backgroundColor: AppColors.accent,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

String? _fieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;

  return switch (code) {
    'required' => l10n.shippingAddressRequiredFieldError,
    'city_invalid' => l10n.shippingAddressCityInvalidError,
    'postal_code_invalid' => l10n.shippingAddressPostalCodeInvalidError,
    'country_required' => l10n.shippingAddressCountryRequiredError,
    'country_invalid' => l10n.shippingAddressCountryInvalidError,
    'phone_invalid' => l10n.shippingAddressPhoneInvalidError,
    _ => l10n.shippingAddressValidationFallback,
  };
}

String _submitMessage(AppLocalizations l10n, String code) {
  return switch (code) {
    'network' => l10n.shippingAddressesNetworkError,
    'unauthorized' => l10n.shippingAddressesUnauthorizedError,
    'not_found' => l10n.shippingAddressesNotFoundError,
    'shipping_address_full_name_required' => l10n.shippingAddressFullNameRequiredError,
    'shipping_address_street_required' => l10n.shippingAddressStreetRequiredError,
    'shipping_address_city_required' => l10n.shippingAddressCityRequiredError,
    'shipping_address_postal_code_required' => l10n.shippingAddressPostalCodeRequiredError,
    'shipping_address_country_code_invalid' => l10n.shippingAddressCountryInvalidError,
    'shipping_address_phone_required' => l10n.shippingAddressPhoneRequiredError,
    'validation' => l10n.shippingAddressesValidationError,
    _ => l10n.shippingAddressSaveError,
  };
}

String _phonePrefixHint(AppLocalizations l10n) {
  return l10n.localeName.startsWith('it') ? 'Prefisso' : 'Prefix';
}

String _phoneNumberPlaceholder(AppLocalizations l10n) {
  return l10n.localeName.startsWith('it')
      ? 'Numero di telefono'
      : 'Phone number';
}
