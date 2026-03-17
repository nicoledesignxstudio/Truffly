enum OnboardingSection {
  aboutTruffly,
  yourDetails,
  documents,
  notifications,
  welcome;

  bool get showsProgressIndicator {
    return this == OnboardingSection.aboutTruffly ||
        this == OnboardingSection.yourDetails;
  }

  bool get isStandalone {
    return !showsProgressIndicator;
  }
}
