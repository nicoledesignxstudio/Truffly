import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';

final class SubmitSellerOnboardingInput {
  const SubmitSellerOnboardingInput({
    required this.firstName,
    required this.lastName,
    required this.region,
    required this.tesserinoNumber,
    required this.identityDocument,
    required this.tesserinoDocument,
  });

  static const implicitCountryCode = 'IT';

  final String firstName;
  final String lastName;
  final String region;
  final String tesserinoNumber;
  final OnboardingLocalDocument identityDocument;
  final OnboardingLocalDocument tesserinoDocument;

  String get countryCode => implicitCountryCode;
}
