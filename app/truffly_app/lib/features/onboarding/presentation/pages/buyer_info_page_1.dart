import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class BuyerInfoPage1 extends StatelessWidget {
  const BuyerInfoPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingBuyerInfo1Title,
      description: l10n.onboardingBuyerInfo1Description,
      assetName: 'buyer_info_page_1',
      fallbackIcon: Icons.forest_outlined,
    );
  }
}
