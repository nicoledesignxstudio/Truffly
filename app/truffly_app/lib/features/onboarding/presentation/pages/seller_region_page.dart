import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_region_options.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerRegionPage extends ConsumerWidget {
  const SellerRegionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);
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
                        l10n.onboardingSellerRegionTitle,
                        style: AppTextStyles.authScreenTitle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingSellerRegionSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.black80,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    OnboardingDropdownField<String>(
                      initialValue: selectedRegion,
                      hintText: l10n.onboardingRegionLabel,
                      errorText: onboardingState.validationFailures.contains(
                              OnboardingValidationFailure.regionRequired)
                          ? l10n.onboardingRegionRequiredError
                          : null,
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
                        notifier.updateSellerRegion(value ?? '');
                        FocusScope.of(context).unfocus();
                      },
                    ),
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

String? _selectedRegionValue(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  return value;
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
