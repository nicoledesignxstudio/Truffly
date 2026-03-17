final class OnboardingCountryOption {
  const OnboardingCountryOption({
    required this.code,
    required this.localizationKey,
  });

  final String code;
  final String localizationKey;
}

const onboardingCountryOptions = <OnboardingCountryOption>[
  OnboardingCountryOption(
    code: 'IT',
    localizationKey: 'onboardingCountryItaly',
  ),
  OnboardingCountryOption(
    code: 'FR',
    localizationKey: 'onboardingCountryFrance',
  ),
  OnboardingCountryOption(
    code: 'DE',
    localizationKey: 'onboardingCountryGermany',
  ),
  OnboardingCountryOption(
    code: 'ES',
    localizationKey: 'onboardingCountrySpain',
  ),
  OnboardingCountryOption(
    code: 'GB',
    localizationKey: 'onboardingCountryUnitedKingdom',
  ),
  OnboardingCountryOption(
    code: 'US',
    localizationKey: 'onboardingCountryUnitedStates',
  ),
];
