import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerInfoPage2 extends StatelessWidget {
  const SellerInfoPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingSellerInfo2Title,
      description: l10n.onboardingSellerInfo2Description,
      assetName: 'buyer_info_page_2',
      fallbackIcon: Icons.percent_outlined,
    );
  }
}
