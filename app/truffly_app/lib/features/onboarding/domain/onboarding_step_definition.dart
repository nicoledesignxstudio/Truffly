import 'dart:collection';

import 'package:truffly_app/features/onboarding/domain/onboarding_path.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_section.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_id.dart';

final class OnboardingStepDefinition {
  const OnboardingStepDefinition({
    required this.id,
    required this.path,
    required this.section,
    required this.sectionStepIndex,
    required this.sectionStepCount,
  });

  final OnboardingStepId id;
  final OnboardingPath path;
  final OnboardingSection section;
  final int sectionStepIndex;
  final int sectionStepCount;

  bool get showsProgressIndicator => section.showsProgressIndicator;
  bool get isStandaloneSection => section.isStandalone;
  bool get requiresName => id.requiresName;
  bool get requiresRegion => id.requiresRegion;
  bool get requiresDocuments => id.requiresDocuments;
  bool get isInfoStep => id.isInfoStep;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OnboardingStepDefinition &&
            other.id == id &&
            other.path == path &&
            other.section == section &&
            other.sectionStepIndex == sectionStepIndex &&
            other.sectionStepCount == sectionStepCount);
  }

  @override
  int get hashCode => Object.hash(
        id,
        path,
        section,
        sectionStepIndex,
        sectionStepCount,
      );
}

final class OnboardingStepCatalog {
  const OnboardingStepCatalog._();

  static const List<OnboardingStepDefinition> buyerSteps = [
    OnboardingStepDefinition(
      id: OnboardingStepId.buyerInfo1,
      path: OnboardingPath.buyer,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 0,
      sectionStepCount: 3,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.buyerInfo2,
      path: OnboardingPath.buyer,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 1,
      sectionStepCount: 3,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.buyerInfo3,
      path: OnboardingPath.buyer,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 2,
      sectionStepCount: 3,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.name,
      path: OnboardingPath.buyer,
      section: OnboardingSection.yourDetails,
      sectionStepIndex: 0,
      sectionStepCount: 2,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.buyerLocation,
      path: OnboardingPath.buyer,
      section: OnboardingSection.yourDetails,
      sectionStepIndex: 1,
      sectionStepCount: 2,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.notifications,
      path: OnboardingPath.buyer,
      section: OnboardingSection.notifications,
      sectionStepIndex: 0,
      sectionStepCount: 1,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.welcome,
      path: OnboardingPath.buyer,
      section: OnboardingSection.welcome,
      sectionStepIndex: 0,
      sectionStepCount: 1,
    ),
  ];

  static const List<OnboardingStepDefinition> sellerSteps = [
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerInfo1,
      path: OnboardingPath.seller,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 0,
      sectionStepCount: 4,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerInfo2,
      path: OnboardingPath.seller,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 1,
      sectionStepCount: 4,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerInfo3,
      path: OnboardingPath.seller,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 2,
      sectionStepCount: 4,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerInfo4,
      path: OnboardingPath.seller,
      section: OnboardingSection.aboutTruffly,
      sectionStepIndex: 3,
      sectionStepCount: 4,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.name,
      path: OnboardingPath.seller,
      section: OnboardingSection.yourDetails,
      sectionStepIndex: 0,
      sectionStepCount: 2,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerRegion,
      path: OnboardingPath.seller,
      section: OnboardingSection.yourDetails,
      sectionStepIndex: 1,
      sectionStepCount: 2,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.sellerDocuments,
      path: OnboardingPath.seller,
      section: OnboardingSection.documents,
      sectionStepIndex: 0,
      sectionStepCount: 1,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.notifications,
      path: OnboardingPath.seller,
      section: OnboardingSection.notifications,
      sectionStepIndex: 0,
      sectionStepCount: 1,
    ),
    OnboardingStepDefinition(
      id: OnboardingStepId.welcome,
      path: OnboardingPath.seller,
      section: OnboardingSection.welcome,
      sectionStepIndex: 0,
      sectionStepCount: 1,
    ),
  ];

  static List<OnboardingStepDefinition> stepsForPath(OnboardingPath path) {
    final steps = switch (path) {
      OnboardingPath.buyer => buyerSteps,
      OnboardingPath.seller => sellerSteps,
    };

    return UnmodifiableListView(steps);
  }

  static OnboardingStepDefinition? stepAt({
    required OnboardingPath path,
    required int index,
  }) {
    final steps = stepsForPath(path);
    if (index < 0 || index >= steps.length) return null;
    return steps[index];
  }
}
