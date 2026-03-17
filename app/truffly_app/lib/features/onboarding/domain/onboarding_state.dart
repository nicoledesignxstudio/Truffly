import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_path.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_section.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_definition.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_id.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';

enum OnboardingSubmissionFailure {
  network,
  validation,
  documentUpload,
  server,
  unimplemented,
  unknown,
}

final class OnboardingState {
  const OnboardingState({
    this.draft = const OnboardingDraft(),
    this.currentStepIndex = 0,
    this.steps = const [],
    this.isSubmitting = false,
    this.submissionFailure,
    this.validationFailures = const [],
  });

  final OnboardingDraft draft;
  final int currentStepIndex;
  final List<OnboardingStepDefinition> steps;
  final bool isSubmitting;
  final OnboardingSubmissionFailure? submissionFailure;
  final List<OnboardingValidationFailure> validationFailures;

  OnboardingPath? get path => draft.path;

  OnboardingStepDefinition? get currentStep {
    if (currentStepIndex < 0 || currentStepIndex >= steps.length) return null;
    return steps[currentStepIndex];
  }

  OnboardingStepId? get currentStepId => currentStep?.id;
  OnboardingSection? get currentSection => currentStep?.section;

  bool get hasSelectedPath => path != null;
  bool get hasSteps => steps.isNotEmpty;
  bool get canGoBack => currentStepIndex > 0;
  bool get canGoNext =>
      currentStepIndex >= 0 && currentStepIndex < steps.length - 1;
  bool get isOnLastStep => hasSteps && currentStepIndex == steps.length - 1;
  bool get hasValidationFailures => validationFailures.isNotEmpty;
  bool get hasSubmissionFailure => submissionFailure != null;
  bool get isBuyerFlow => path?.isBuyer ?? false;
  bool get isSellerFlow => path?.isSeller ?? false;
  bool get isCurrentStepProgressTracked =>
      currentStep?.showsProgressIndicator ?? false;
  bool get currentStepRequiresRegion => currentStep?.requiresRegion ?? false;
  bool get currentStepRequiresDocuments =>
      currentStep?.requiresDocuments ?? false;

  OnboardingState copyWith({
    OnboardingDraft? draft,
    int? currentStepIndex,
    List<OnboardingStepDefinition>? steps,
    bool? isSubmitting,
    Object? submissionFailure = _sentinel,
    List<OnboardingValidationFailure>? validationFailures,
  }) {
    return OnboardingState(
      draft: draft ?? this.draft,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      steps: steps ?? this.steps,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submissionFailure: identical(submissionFailure, _sentinel)
          ? this.submissionFailure
          : submissionFailure as OnboardingSubmissionFailure?,
      validationFailures: validationFailures ?? this.validationFailures,
    );
  }

  static OnboardingState initial() {
    return const OnboardingState();
  }

  static OnboardingState forPath(OnboardingPath path) {
    return OnboardingState(
      draft: OnboardingDraft(path: path),
      currentStepIndex: 0,
      steps: OnboardingStepCatalog.stepsForPath(path),
      isSubmitting: false,
      validationFailures: const [],
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OnboardingState &&
            other.draft == draft &&
            other.currentStepIndex == currentStepIndex &&
            _listEquals(other.steps, steps) &&
            other.isSubmitting == isSubmitting &&
            other.submissionFailure == submissionFailure &&
            _listEquals(other.validationFailures, validationFailures));
  }

  @override
  int get hashCode => Object.hash(
        draft,
        currentStepIndex,
        Object.hashAll(steps),
        isSubmitting,
        submissionFailure,
        Object.hashAll(validationFailures),
      );
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (left.length != right.length) return false;

  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }

  return true;
}

const Object _sentinel = Object();
