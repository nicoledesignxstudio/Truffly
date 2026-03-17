enum OnboardingPath {
  buyer,
  seller,
}

extension OnboardingPathX on OnboardingPath {
  bool get isBuyer => this == OnboardingPath.buyer;
  bool get isSeller => this == OnboardingPath.seller;
}
