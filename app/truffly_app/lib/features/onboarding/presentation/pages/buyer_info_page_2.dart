import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class BuyerInfoPage2 extends StatelessWidget {
  const BuyerInfoPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingBuyerInfo2Title,
      description: l10n.onboardingBuyerInfo2Description,
      assetName: 'buyer_info_page_2',
      fallbackIcon: Icons.shield_outlined,
    );
  }
}
