enum OnboardingValidationFailure {
  pathRequired,
  firstNameRequired,
  firstNameTooShort,
  lastNameRequired,
  lastNameTooShort,
  countryRequired,
  countryInvalid,
  regionRequired,
  tesserinoNumberRequired,
  identityDocumentRequired,
  tesserinoDocumentRequired,
}

extension OnboardingValidationFailureX on OnboardingValidationFailure {
  bool get isNameFailure {
    return this == OnboardingValidationFailure.firstNameRequired ||
        this == OnboardingValidationFailure.firstNameTooShort ||
        this == OnboardingValidationFailure.lastNameRequired ||
        this == OnboardingValidationFailure.lastNameTooShort;
  }

  bool get isLocationFailure {
    return this == OnboardingValidationFailure.countryRequired ||
        this == OnboardingValidationFailure.countryInvalid ||
        this == OnboardingValidationFailure.regionRequired;
  }

  bool get isDocumentFailure {
    return this == OnboardingValidationFailure.tesserinoNumberRequired ||
        this == OnboardingValidationFailure.identityDocumentRequired ||
        this == OnboardingValidationFailure.tesserinoDocumentRequired;
  }
}
