import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerInfoPage3 extends StatelessWidget {
  const SellerInfoPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingSellerInfo3Title,
      description: l10n.onboardingSellerInfo3Description,
      assetName: 'buyer_info_page_3',
      fallbackIcon: Icons.local_shipping_outlined,
    );
  }
}
