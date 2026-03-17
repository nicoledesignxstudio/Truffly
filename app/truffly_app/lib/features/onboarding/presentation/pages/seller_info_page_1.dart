import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerInfoPage1 extends StatelessWidget {
  const SellerInfoPage1({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingSellerInfo1Title,
      description: l10n.onboardingSellerInfo1Description,
      assetName: 'buyer_info_page_1',
      fallbackIcon: Icons.storefront_outlined,
    );
  }
}
