final class CompleteBuyerOnboardingInput {
  const CompleteBuyerOnboardingInput({
    required this.firstName,
    required this.lastName,
    required this.countryCode,
    required this.region,
  });

  final String firstName;
  final String lastName;
  final String countryCode;
  final String? region;
}
