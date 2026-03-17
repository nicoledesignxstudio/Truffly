enum OnboardingStepId {
  buyerInfo1,
  buyerInfo2,
  buyerInfo3,
  sellerInfo1,
  sellerInfo2,
  sellerInfo3,
  sellerInfo4,
  name,
  buyerLocation,
  sellerRegion,
  sellerDocuments,
  notifications,
  welcome,
}

extension OnboardingStepIdX on OnboardingStepId {
  bool get isBuyerInfoStep {
    return this == OnboardingStepId.buyerInfo1 ||
        this == OnboardingStepId.buyerInfo2 ||
        this == OnboardingStepId.buyerInfo3;
  }

  bool get isSellerInfoStep {
    return this == OnboardingStepId.sellerInfo1 ||
        this == OnboardingStepId.sellerInfo2 ||
        this == OnboardingStepId.sellerInfo3 ||
        this == OnboardingStepId.sellerInfo4;
  }

  bool get isInfoStep => isBuyerInfoStep || isSellerInfoStep;

  bool get requiresName {
    return this == OnboardingStepId.name;
  }

  bool get requiresBuyerLocation {
    return this == OnboardingStepId.buyerLocation;
  }

  bool get requiresSellerRegion {
    return this == OnboardingStepId.sellerRegion;
  }

  bool get requiresRegion {
    return requiresBuyerLocation || requiresSellerRegion;
  }

  bool get requiresDocuments {
    return this == OnboardingStepId.sellerDocuments;
  }

  bool get isNotificationsStep {
    return this == OnboardingStepId.notifications;
  }

  bool get isWelcomeStep {
    return this == OnboardingStepId.welcome;
  }
}
