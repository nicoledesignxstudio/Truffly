import 'package:truffly_app/features/account/domain/account_details_form_data.dart';

enum AccountDetailsField {
  firstName,
  lastName,
  email,
  countryCode,
  region,
  bio,
  profileImageUrl,
}

enum AccountDetailsStatus {
  loading,
  ready,
  saving,
}

final class AccountDetailsSubmissionResult {
  const AccountDetailsSubmissionResult({
    required this.emailChanged,
  });

  final bool emailChanged;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AccountDetailsSubmissionResult &&
            other.emailChanged == emailChanged;
  }

  @override
  int get hashCode => emailChanged.hashCode;
}

final class AccountDetailsState {
  const AccountDetailsState({
    required this.status,
    required this.form,
    required this.initialForm,
    required this.touchedFields,
    required this.submitAttempted,
    required this.lastSubmissionResult,
    required this.errorMessage,
  });

  const AccountDetailsState.loading()
    : status = AccountDetailsStatus.loading,
      form = null,
      initialForm = null,
      touchedFields = const <AccountDetailsField>{},
      submitAttempted = false,
      lastSubmissionResult = null,
      errorMessage = null;

  final AccountDetailsStatus status;
  final AccountDetailsFormData? form;
  final AccountDetailsFormData? initialForm;
  final Set<AccountDetailsField> touchedFields;
  final bool submitAttempted;
  final AccountDetailsSubmissionResult? lastSubmissionResult;
  final String? errorMessage;

  bool get isLoading => status == AccountDetailsStatus.loading;
  bool get isSaving => status == AccountDetailsStatus.saving;
  bool get isReady => status == AccountDetailsStatus.ready;

  bool get canSubmit {
    final currentForm = form;
    final baseline = initialForm;
    if (currentForm == null || baseline == null || isSaving) return false;
    return currentForm.hasChangesComparedTo(baseline);
  }

  AccountDetailsState copyWith({
    AccountDetailsStatus? status,
    Object? form = _sentinel,
    Object? initialForm = _sentinel,
    Set<AccountDetailsField>? touchedFields,
    bool? submitAttempted,
    Object? lastSubmissionResult = _sentinel,
    Object? errorMessage = _sentinel,
  }) {
    return AccountDetailsState(
      status: status ?? this.status,
      form: identical(form, _sentinel) ? this.form : form as AccountDetailsFormData?,
      initialForm: identical(initialForm, _sentinel)
          ? this.initialForm
          : initialForm as AccountDetailsFormData?,
      touchedFields: touchedFields ?? this.touchedFields,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      lastSubmissionResult: identical(lastSubmissionResult, _sentinel)
          ? this.lastSubmissionResult
          : lastSubmissionResult as AccountDetailsSubmissionResult?,
      errorMessage: identical(errorMessage, _sentinel) ? this.errorMessage : errorMessage as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AccountDetailsState &&
            other.status == status &&
            other.form == form &&
            other.initialForm == initialForm &&
            _setEquals(other.touchedFields, touchedFields) &&
            other.submitAttempted == submitAttempted &&
            other.lastSubmissionResult == lastSubmissionResult &&
            other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(
    status,
    form,
    initialForm,
    Object.hashAllUnordered(touchedFields),
    submitAttempted,
    lastSubmissionResult,
    errorMessage,
  );
}

bool _setEquals<T>(Set<T> left, Set<T> right) {
  if (left.length != right.length) return false;
  for (final value in left) {
    if (!right.contains(value)) return false;
  }
  return true;
}

const _sentinel = Object();
