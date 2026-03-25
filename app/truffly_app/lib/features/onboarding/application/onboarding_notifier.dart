import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/data/models/complete_buyer_onboarding_input.dart';
import 'package:truffly_app/features/onboarding/data/models/notification_permission_result.dart';
import 'package:truffly_app/features/onboarding/data/models/submit_seller_onboarding_input.dart';
import 'package:truffly_app/features/onboarding/data/onboarding_service.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_path.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_state.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_id.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';

final class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    return OnboardingState.initial();
  }

  void selectPath(OnboardingPath path) {
    state = OnboardingState.forPath(path);
  }

  void resetFlow() {
    state = OnboardingState.initial();
  }

  bool nextStep() {
    final failures = _validateCurrentStep();
    if (failures.isNotEmpty) {
      _setValidationFailures(failures);
      return false;
    }

    if (!state.canGoNext) {
      _setValidationFailures(const []);
      return false;
    }

    state = state.copyWith(
      currentStepIndex: state.currentStepIndex + 1,
      validationFailures: const [],
      submissionIssue: null,
    );
    return true;
  }

  bool previousStep() {
    if (!state.canGoBack) return false;

    state = state.copyWith(
      currentStepIndex: state.currentStepIndex - 1,
      validationFailures: const [],
      submissionIssue: null,
    );
    return true;
  }

  // Internal flow helper for future notifier orchestration.
  // This is intentionally not a general-purpose UI escape hatch.
  bool goToStep(int index) {
    if (!_hasSelectedPathOrSteps()) return false;
    if (index < 0 || index >= state.steps.length) return false;

    state = state.copyWith(
      currentStepIndex: index,
      validationFailures: const [],
      submissionIssue: null,
    );
    return true;
  }

  void updateFirstName(String value) {
    _updateDraft(state.draft.copyWith(firstName: value));
  }

  void updateLastName(String value) {
    _updateDraft(state.draft.copyWith(lastName: value));
  }

  void updateBuyerCountry(String value) {
    final normalizedCountry = value.trim().toUpperCase();
    final nextCountry = normalizedCountry.isEmpty ? null : normalizedCountry;
    final shouldClearRegion = nextCountry == null || nextCountry != 'IT';

    _updateDraft(
      state.draft.copyWith(
        countryCode: nextCountry,
        region: shouldClearRegion ? null : state.draft.region,
      ),
    );
  }

  void updateBuyerRegion(String? value) {
    final normalizedRegion = _normalizeOptionalValue(value);
    final nextRegion = state.draft.requiresRegion ? normalizedRegion : null;
    _updateDraft(state.draft.copyWith(region: nextRegion));
  }

  void updateSellerRegion(String value) {
    _updateDraft(
      state.draft.copyWith(region: _normalizeOptionalValue(value)),
    );
  }

  void updateTesserinoNumber(String value) {
    _updateDraft(state.draft.copyWith(tesserinoNumber: value));
  }

  void setIdentityDocument(OnboardingLocalDocument document) {
    _updateDraft(state.draft.copyWith(identityDocument: document));
  }

  void setTesserinoDocument(OnboardingLocalDocument document) {
    _updateDraft(state.draft.copyWith(tesserinoDocument: document));
  }

  void clearIdentityDocument() {
    _updateDraft(state.draft.copyWith(identityDocument: null));
  }

  void clearTesserinoDocument() {
    _updateDraft(state.draft.copyWith(tesserinoDocument: null));
  }

  void setNotificationChoice(OnboardingNotificationChoice choice) {
    _updateDraft(state.draft.copyWith(notificationChoice: choice));
  }

  void setNotificationPermissionStatus(
    OnboardingNotificationPermissionStatus status,
  ) {
    _updateDraft(
      state.draft.copyWith(notificationPermissionStatus: status),
    );
  }

  Future<OnboardingNotificationPermissionStatus?>
      requestNotificationPermission() async {
    if (state.isSubmitting) return null;

    try {
      final result =
          await ref.read(onboardingServiceProvider).requestNotificationPermission();
      final status = switch (result) {
        NotificationPermissionResult.granted =>
          OnboardingNotificationPermissionStatus.granted,
        NotificationPermissionResult.denied =>
          OnboardingNotificationPermissionStatus.denied,
      };
      setNotificationPermissionStatus(status);
      return status;
    } on OnboardingSubmissionException catch (error) {
      state = state.copyWith(submissionIssue: error.issue);
      return null;
    } catch (_) {
      state = state.copyWith(
        submissionIssue: const OnboardingSubmissionIssue(
          failure: OnboardingSubmissionFailure.unknown,
        ),
      );
      return null;
    }
  }

  List<OnboardingValidationFailure> validateCurrentStep() {
    final failures = _validateCurrentStep();
    _setValidationFailures(failures);
    return failures;
  }

  bool canContinueFromCurrentStep() {
    return _validateCurrentStep().isEmpty;
  }

  List<OnboardingValidationFailure> validateAllBeforeSubmit() {
    final path = state.path;
    if (path == null) {
      const failures = [OnboardingValidationFailure.pathRequired];
      _setValidationFailures(failures);
      return failures;
    }

    final failures = <OnboardingValidationFailure>[
      ..._validateNameStep(),
      ...switch (path) {
        OnboardingPath.buyer => _validateBuyerLocationStep(),
        OnboardingPath.seller => <OnboardingValidationFailure>[
            ..._validateSellerRegionStep(),
            ..._validateSellerDocumentsStep(),
          ],
      },
    ];

    final distinctFailures = _dedupeFailures(failures);
    _setValidationFailures(distinctFailures);
    return distinctFailures;
  }

  Future<bool> completeBuyerOnboarding() async {
    if (state.isSubmitting || !state.isBuyerFlow) return false;

    final failures = validateAllBeforeSubmit();
    if (failures.isNotEmpty) return false;

    return _runSubmission(
      submission: () {
        return ref
            .read(onboardingServiceProvider)
            .completeBuyerOnboarding(_toCompleteBuyerOnboardingInput());
      },
    );
  }

  Future<bool> completeSellerOnboarding() async {
    if (state.isSubmitting || !state.isSellerFlow) return false;

    final failures = validateAllBeforeSubmit();
    if (failures.isNotEmpty) return false;

    return _runSubmission(
      submission: () {
        return ref
            .read(onboardingServiceProvider)
            .submitSellerOnboarding(_toSubmitSellerOnboardingInput());
      },
    );
  }

  Future<bool> _runSubmission({
    required Future<void> Function() submission,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      submissionIssue: null,
      validationFailures: const [],
    );

    try {
      await submission();
      state = state.copyWith(
        isSubmitting: false,
        submissionIssue: null,
      );
      return true;
    } on OnboardingSubmissionException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        submissionIssue: error.issue,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        submissionIssue: const OnboardingSubmissionIssue(
          failure: OnboardingSubmissionFailure.unknown,
        ),
      );
      return false;
    }
  }

  List<OnboardingValidationFailure> _validateCurrentStep() {
    final currentStep = state.currentStepId;
    if (currentStep == null) {
      return const [OnboardingValidationFailure.pathRequired];
    }

    return switch (currentStep) {
      OnboardingStepId.buyerInfo1 ||
      OnboardingStepId.buyerInfo2 ||
      OnboardingStepId.buyerInfo3 ||
      OnboardingStepId.sellerInfo1 ||
      OnboardingStepId.sellerInfo2 ||
      OnboardingStepId.sellerInfo3 ||
      OnboardingStepId.sellerInfo4 ||
      OnboardingStepId.notifications ||
      OnboardingStepId.welcome => const <OnboardingValidationFailure>[],
      OnboardingStepId.name => _validateNameStep(),
      OnboardingStepId.buyerLocation => _validateBuyerLocationStep(),
      OnboardingStepId.sellerRegion => _validateSellerRegionStep(),
      OnboardingStepId.sellerDocuments => _validateSellerDocumentsStep(),
    };
  }

  List<OnboardingValidationFailure> _validateNameStep() {
    final failures = <OnboardingValidationFailure>[];
    final firstName = state.draft.firstName.trim();
    final lastName = state.draft.lastName.trim();

    if (firstName.isEmpty) {
      failures.add(OnboardingValidationFailure.firstNameRequired);
    } else if (firstName.length < 2) {
      failures.add(OnboardingValidationFailure.firstNameTooShort);
    }

    if (lastName.isEmpty) {
      failures.add(OnboardingValidationFailure.lastNameRequired);
    } else if (lastName.length < 2) {
      failures.add(OnboardingValidationFailure.lastNameTooShort);
    }

    return failures;
  }

  List<OnboardingValidationFailure> _validateBuyerLocationStep() {
    final failures = <OnboardingValidationFailure>[];
    final countryCode = state.draft.countryCode?.trim().toUpperCase();
    final region = _normalizeOptionalValue(state.draft.region);

    if (countryCode == null || countryCode.isEmpty) {
      failures.add(OnboardingValidationFailure.countryRequired);
      return failures;
    }

    if (!_isValidCountryCode(countryCode)) {
      failures.add(OnboardingValidationFailure.countryInvalid);
      return failures;
    }

    if (countryCode == 'IT' && (region == null || region.isEmpty)) {
      failures.add(OnboardingValidationFailure.regionRequired);
    }

    return failures;
  }

  List<OnboardingValidationFailure> _validateSellerRegionStep() {
    final region = _normalizeOptionalValue(state.draft.region);
    if (region == null || region.isEmpty) {
      return const [OnboardingValidationFailure.regionRequired];
    }
    return const [];
  }

  List<OnboardingValidationFailure> _validateSellerDocumentsStep() {
    final failures = <OnboardingValidationFailure>[];
    final tesserinoNumber = state.draft.tesserinoNumber.trim();

    if (tesserinoNumber.isEmpty) {
      failures.add(OnboardingValidationFailure.tesserinoNumberRequired);
    }

    if (state.draft.identityDocument == null) {
      failures.add(OnboardingValidationFailure.identityDocumentRequired);
    }

    if (state.draft.tesserinoDocument == null) {
      failures.add(OnboardingValidationFailure.tesserinoDocumentRequired);
    }

    return failures;
  }

  void _updateDraft(OnboardingDraft draft) {
    state = state.copyWith(
      draft: draft,
      validationFailures: const [],
      submissionIssue: null,
    );
  }

  void _setValidationFailures(List<OnboardingValidationFailure> failures) {
    state = state.copyWith(
      validationFailures: failures,
      submissionIssue: null,
    );
  }

  bool _hasSelectedPathOrSteps() {
    return state.hasSelectedPath && state.hasSteps;
  }

  String? _normalizeOptionalValue(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;
    return normalized;
  }

  bool _isValidCountryCode(String value) {
    return isSupportedEuropeanCountryCode(value);
  }

  List<OnboardingValidationFailure> _dedupeFailures(
    List<OnboardingValidationFailure> failures,
  ) {
    return failures.toSet().toList(growable: false);
  }

  CompleteBuyerOnboardingInput _toCompleteBuyerOnboardingInput() {
    return CompleteBuyerOnboardingInput(
      firstName: state.draft.firstName.trim(),
      lastName: state.draft.lastName.trim(),
      countryCode: (state.draft.countryCode ?? '').trim().toUpperCase(),
      region: _normalizeOptionalValue(state.draft.region),
    );
  }

  SubmitSellerOnboardingInput _toSubmitSellerOnboardingInput() {
    final identityDocument = state.draft.identityDocument;
    final tesserinoDocument = state.draft.tesserinoDocument;
    if (identityDocument == null || tesserinoDocument == null) {
      throw StateError(
        'Seller onboarding input requested without required local documents.',
      );
    }

    return SubmitSellerOnboardingInput(
      firstName: state.draft.firstName.trim(),
      lastName: state.draft.lastName.trim(),
      region: (state.draft.region ?? '').trim(),
      tesserinoNumber: state.draft.tesserinoNumber.trim(),
      identityDocument: identityDocument,
      tesserinoDocument: tesserinoDocument,
    );
  }
}
