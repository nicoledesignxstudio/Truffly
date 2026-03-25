import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/features/account/application/account_details_providers.dart';
import 'package:truffly_app/features/account/domain/account_details_form_data.dart';
import 'package:truffly_app/features/account/domain/account_details_state.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';

final accountDetailsNotifierProvider =
    AutoDisposeNotifierProvider<AccountDetailsNotifier, AccountDetailsState>(
      AccountDetailsNotifier.new,
    );

final class AccountDetailsNotifier extends AutoDisposeNotifier<AccountDetailsState> {
  @override
  AccountDetailsState build() {
    Future.microtask(_load);
    return const AccountDetailsState.loading();
  }

  Future<void> reload() => _load();

  void updateFirstName(String value) => _updateForm(
    field: AccountDetailsField.firstName,
    update: (form) => form.copyWith(firstName: value),
  );

  void updateLastName(String value) => _updateForm(
    field: AccountDetailsField.lastName,
    update: (form) => form.copyWith(lastName: value),
  );

  void updateEmail(String value) => _updateForm(
    field: AccountDetailsField.email,
    update: (form) => form.copyWith(email: value),
  );

  void updateCountryCode(String value) => _updateForm(
    field: AccountDetailsField.countryCode,
    update: (form) {
      final normalizedCountry = value.trim().toUpperCase();
      final shouldKeepRegion = normalizedCountry == 'IT';
      return form.copyWith(
        countryCode: normalizedCountry,
        region: shouldKeepRegion ? form.region : null,
      );
    },
  );

  void updateRegion(String? value) => _updateForm(
    field: AccountDetailsField.region,
    update: (form) => form.copyWith(region: value),
  );

  void updateBio(String value) => _updateForm(
    field: AccountDetailsField.bio,
    update: (form) => form.copyWith(bio: value),
  );

  void updateProfileImageUrl(String value) => _updateForm(
    field: AccountDetailsField.profileImageUrl,
    update: (form) => form.copyWith(profileImageUrl: value),
  );

  void removeProfileImage() => _updateForm(
    field: AccountDetailsField.profileImageUrl,
    update: (form) => form.copyWith(profileImageUrl: null),
  );

  String? errorFor(AccountDetailsField field) {
    final form = state.form;
    if (form == null) return null;

    final shouldShow = state.submitAttempted || state.touchedFields.contains(field);
    if (!shouldShow) return null;

    return switch (field) {
      AccountDetailsField.firstName =>
        _requiredFieldError(form.firstName),
      AccountDetailsField.lastName =>
        _requiredFieldError(form.lastName),
      AccountDetailsField.email => _emailError(form.email),
      AccountDetailsField.countryCode => _countryError(form),
      AccountDetailsField.region => _regionError(form),
      AccountDetailsField.bio => null,
      AccountDetailsField.profileImageUrl => _profileImageUrlError(form.profileImageUrl),
    };
  }

  Future<AccountDetailsSubmissionResult?> submit() async {
    return _submit(includeProfileChanges: true, includeEmailChange: true);
  }

  Future<AccountDetailsSubmissionResult?> submitProfileChanges() async {
    return _submit(includeProfileChanges: true, includeEmailChange: false);
  }

  Future<AccountDetailsSubmissionResult?> submitEmailChange() async {
    return _submit(includeProfileChanges: false, includeEmailChange: true);
  }

  Future<AccountDetailsSubmissionResult?> _submit({
    required bool includeProfileChanges,
    required bool includeEmailChange,
  }) async {
    final currentForm = state.form;
    final initialForm = state.initialForm;
    if (currentForm == null || initialForm == null) return null;

    final validationErrorExists = _hasValidationErrors(
      currentForm,
      validateProfileImageUrl: includeProfileChanges,
    );
    if (validationErrorExists) {
      state = state.copyWith(
        submitAttempted: true,
        errorMessage: null,
        lastSubmissionResult: null,
      );
      return null;
    }

    if (!currentForm.hasChangesComparedTo(initialForm)) {
      state = state.copyWith(
        status: AccountDetailsStatus.ready,
        errorMessage: null,
        lastSubmissionResult: null,
      );
      return null;
    }

    final normalizedForm = currentForm.normalized();
    final normalizedInitialForm = initialForm.normalized();
    final emailChanged = normalizedForm.email != normalizedInitialForm.email;
    final profileChanged = normalizedForm.copyWith(
          email: normalizedInitialForm.email,
        ).hasChangesComparedTo(
          normalizedInitialForm.copyWith(email: normalizedInitialForm.email),
        );

    if ((includeProfileChanges && !profileChanged) ||
        (includeEmailChange && !emailChanged)) {
      if ((!includeProfileChanges || profileChanged) &&
          (!includeEmailChange || emailChanged)) {
        // noop, at least one selected scope changed
      } else if (!profileChanged && !emailChanged) {
        state = state.copyWith(
          status: AccountDetailsStatus.ready,
          errorMessage: null,
          lastSubmissionResult: null,
        );
        return null;
      }
    }

    if (!includeProfileChanges && !emailChanged) {
      state = state.copyWith(
        status: AccountDetailsStatus.ready,
        errorMessage: null,
        lastSubmissionResult: null,
      );
      return null;
    }

    if (!includeEmailChange && !profileChanged) {
      state = state.copyWith(
        status: AccountDetailsStatus.ready,
        errorMessage: null,
        lastSubmissionResult: null,
      );
      return null;
    }

    state = state.copyWith(
      status: AccountDetailsStatus.saving,
      submitAttempted: true,
      errorMessage: null,
      lastSubmissionResult: null,
    );

    if (includeProfileChanges && profileChanged) {
      final profileResult = await ref
          .read(accountDetailsServiceProvider)
          .updateProfile(
            firstName: normalizedForm.firstName,
            lastName: normalizedForm.lastName,
            countryCode: normalizedForm.countryCode,
            region: normalizedForm.region,
            bio: normalizedForm.bio,
            profileImageUrl: normalizedForm.profileImageUrl,
            isSeller: normalizedForm.isSeller,
          );

      if (profileResult case AuthFailureResult<AuthUnit>(:final failure)) {
        state = state.copyWith(
          status: AccountDetailsStatus.ready,
          errorMessage: _mapFailureToMessage(failure),
          lastSubmissionResult: null,
        );
        return null;
      }
    }

    if (includeEmailChange && emailChanged) {
      final emailResult = await ref.read(accountDetailsServiceProvider).updateEmail(
        email: normalizedForm.email,
      );

      if (emailResult case AuthFailureResult<AuthUnit>(:final failure)) {
        state = state.copyWith(
          status: AccountDetailsStatus.ready,
          errorMessage: _mapFailureToMessage(failure),
          lastSubmissionResult: null,
        );
        return null;
      }
    }

    final submissionResult = AccountDetailsSubmissionResult(
      emailChanged: emailChanged,
    );

    state = state.copyWith(
      status: AccountDetailsStatus.ready,
      form: normalizedForm,
      initialForm: normalizedForm,
      errorMessage: null,
      lastSubmissionResult: submissionResult,
    );

    return submissionResult;
  }

  void clearSubmissionFeedback() {
    if (state.lastSubmissionResult == null && state.errorMessage == null) return;
    state = state.copyWith(
      lastSubmissionResult: null,
      errorMessage: null,
    );
  }

  Future<void> _load() async {
    final result = await ref.read(accountDetailsServiceProvider).loadCurrentProfile();

    if (result case AuthSuccess<CurrentUserProfile>(:final data)) {
      final form = AccountDetailsFormData(
        firstName: data.firstName ?? '',
        lastName: data.lastName ?? '',
        email: data.email,
        countryCode: data.countryCode ?? (data.isSeller ? 'IT' : ''),
        region: data.region,
        bio: data.bio,
        profileImageUrl: data.profileImageUrl,
        isSeller: data.isSeller,
      ).normalized();

      state = AccountDetailsState(
        status: AccountDetailsStatus.ready,
        form: form,
        initialForm: form,
        touchedFields: const <AccountDetailsField>{},
        submitAttempted: false,
        lastSubmissionResult: null,
        errorMessage: null,
      );
      return;
    }

    final failure = (result as AuthFailureResult<CurrentUserProfile>).failure;
    state = AccountDetailsState(
      status: AccountDetailsStatus.ready,
      form: null,
      initialForm: null,
      touchedFields: const <AccountDetailsField>{},
      submitAttempted: false,
      lastSubmissionResult: null,
      errorMessage: _mapFailureToMessage(failure),
    );
  }

  void _updateForm({
    required AccountDetailsField field,
    required AccountDetailsFormData Function(AccountDetailsFormData form) update,
  }) {
    final currentForm = state.form;
    if (currentForm == null || state.isSaving) return;

    final nextTouched = <AccountDetailsField>{
      ...state.touchedFields,
      field,
      if (field == AccountDetailsField.countryCode) AccountDetailsField.region,
    };

    state = state.copyWith(
      status: AccountDetailsStatus.ready,
      form: update(currentForm),
      touchedFields: nextTouched,
      errorMessage: null,
      lastSubmissionResult: null,
    );
  }

  bool _hasValidationErrors(
    AccountDetailsFormData form, {
    required bool validateProfileImageUrl,
  }) {
    return _requiredFieldError(form.firstName) != null ||
        _requiredFieldError(form.lastName) != null ||
        _emailError(form.email) != null ||
        _countryError(form) != null ||
        _regionError(form) != null ||
        (validateProfileImageUrl &&
            _profileImageUrlError(form.profileImageUrl) != null);
  }

  String? _requiredFieldError(String value) {
    return value.trim().isEmpty ? 'required' : null;
  }

  String? _emailError(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'email_required';
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) return 'invalid_email';
    return null;
  }

  String? _countryError(AccountDetailsFormData form) {
    final countryCode = form.countryCode.trim().toUpperCase();
    if (countryCode.isEmpty) return 'country_required';
    if (!isSupportedEuropeanCountryCode(countryCode)) return 'country_invalid';
    if (form.isSeller && countryCode != 'IT') return 'seller_country_invalid';
    return null;
  }

  String? _regionError(AccountDetailsFormData form) {
    if (!form.requiresRegion) return null;
    return form.region?.trim().isEmpty ?? true ? 'region_required' : null;
  }

  String? _profileImageUrlError(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) return 'invalid_image_url';
    return null;
  }

  String _mapFailureToMessage(AuthFailure failure) {
    return switch (failure) {
      NetworkErrorFailure() => 'network',
      TimeoutFailure() => 'timeout',
      EmailAlreadyUsedFailure() => 'email_already_used',
      InvalidCredentialsFailure() => 'invalid_credentials',
      UnauthenticatedFailure() => 'unauthenticated',
      EmailNotVerifiedFailure() => 'email_not_verified',
      UserProfileMissingFailure() => 'profile_missing',
      ResetLinkInvalidFailure() || UnknownAuthFailure() => 'unknown',
    };
  }
}
