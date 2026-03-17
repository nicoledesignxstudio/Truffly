import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_country_options.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_region_options.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class BuyerLocationPage extends ConsumerWidget {
  const BuyerLocationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final requiresRegion = onboardingState.draft.requiresRegion;
    final selectedCountry = _selectedCountryValue(onboardingState.draft.countryCode);
    final selectedRegion = _selectedRegionValue(onboardingState.draft.region);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingBuyerLocationTitle,
                        style: AppTextStyles.authScreenTitle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingBuyerLocationSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.black80,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    OnboardingDropdownField<String>(
                      initialValue: selectedCountry,
                      hintText: l10n.onboardingCountryLabel,
                      errorText: _countryError(
                        onboardingState.validationFailures,
                        l10n,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(l10n.onboardingCountryPlaceholder),
                        ),
                        for (final option in onboardingCountryOptions)
                          DropdownMenuItem<String>(
                            value: option.code,
                            child: Text(_countryLabel(l10n, option.localizationKey)),
                          ),
                      ],
                      onChanged: (value) {
                        notifier.updateBuyerCountry(value ?? '');
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    if (requiresRegion) ...[
                      const SizedBox(height: AppSpacing.authFieldGap),
                      OnboardingDropdownField<String>(
                        initialValue: selectedRegion,
                        hintText: l10n.onboardingRegionLabel,
                        errorText: _regionError(
                          onboardingState.validationFailures,
                          l10n,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text(l10n.onboardingRegionPlaceholder),
                          ),
                          for (final option in onboardingRegionOptions)
                            DropdownMenuItem<String>(
                              value: option.value,
                              child: Text(
                                _regionLabel(l10n, option.localizationKey),
                              ),
                            ),
                        ],
                        onChanged: (value) {
                          notifier.updateBuyerRegion(value);
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.authFieldGap),
                      AuthTextBlock(
                        alignment: Alignment.center,
                        maxWidth: 440,
                        child: Text(
                          l10n.onboardingBuyerLocationRegionHelper,
                          style: AppTextStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String? _countryError(
  List<OnboardingValidationFailure> failures,
  AppLocalizations l10n,
) {
  if (failures.contains(OnboardingValidationFailure.countryRequired)) {
    return l10n.onboardingCountryRequiredError;
  }
  if (failures.contains(OnboardingValidationFailure.countryInvalid)) {
    return l10n.onboardingCountryInvalidError;
  }
  return null;
}

String? _regionError(
  List<OnboardingValidationFailure> failures,
  AppLocalizations l10n,
) {
  if (failures.contains(OnboardingValidationFailure.regionRequired)) {
    return l10n.onboardingRegionRequiredError;
  }
  return null;
}

String? _selectedCountryValue(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return value;
}

String? _selectedRegionValue(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return value;
}

String _countryLabel(AppLocalizations l10n, String localizationKey) {
  return switch (localizationKey) {
    'onboardingCountryItaly' => l10n.onboardingCountryItaly,
    'onboardingCountryFrance' => l10n.onboardingCountryFrance,
    'onboardingCountryGermany' => l10n.onboardingCountryGermany,
    'onboardingCountrySpain' => l10n.onboardingCountrySpain,
    'onboardingCountryUnitedKingdom' => l10n.onboardingCountryUnitedKingdom,
    'onboardingCountryUnitedStates' => l10n.onboardingCountryUnitedStates,
    _ => localizationKey,
  };
}

String _regionLabel(AppLocalizations l10n, String localizationKey) {
  return switch (localizationKey) {
    'onboardingRegionAbruzzo' => l10n.onboardingRegionAbruzzo,
    'onboardingRegionBasilicata' => l10n.onboardingRegionBasilicata,
    'onboardingRegionCalabria' => l10n.onboardingRegionCalabria,
    'onboardingRegionCampania' => l10n.onboardingRegionCampania,
    'onboardingRegionEmiliaRomagna' => l10n.onboardingRegionEmiliaRomagna,
    'onboardingRegionFriuliVeneziaGiulia' =>
      l10n.onboardingRegionFriuliVeneziaGiulia,
    'onboardingRegionLazio' => l10n.onboardingRegionLazio,
    'onboardingRegionLiguria' => l10n.onboardingRegionLiguria,
    'onboardingRegionLombardia' => l10n.onboardingRegionLombardia,
    'onboardingRegionMarche' => l10n.onboardingRegionMarche,
    'onboardingRegionMolise' => l10n.onboardingRegionMolise,
    'onboardingRegionPiemonte' => l10n.onboardingRegionPiemonte,
    'onboardingRegionPuglia' => l10n.onboardingRegionPuglia,
    'onboardingRegionSardegna' => l10n.onboardingRegionSardegna,
    'onboardingRegionSicilia' => l10n.onboardingRegionSicilia,
    'onboardingRegionToscana' => l10n.onboardingRegionToscana,
    'onboardingRegionTrentinoAltoAdige' =>
      l10n.onboardingRegionTrentinoAltoAdige,
    'onboardingRegionUmbria' => l10n.onboardingRegionUmbria,
    'onboardingRegionValleDaosta' => l10n.onboardingRegionValleDaosta,
    'onboardingRegionVeneto' => l10n.onboardingRegionVeneto,
    _ => localizationKey,
  };
}
