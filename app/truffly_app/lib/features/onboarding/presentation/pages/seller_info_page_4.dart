import 'package:flutter/material.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_info_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerInfoPage4 extends StatelessWidget {
  const SellerInfoPage4({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OnboardingInfoPage(
      title: l10n.onboardingSellerInfo4Title,
      description: l10n.onboardingSellerInfo4Description,
      assetName: 'buyer_info_page_4',
      fallbackIcon: Icons.account_balance_wallet_outlined,
    );
  }
}
