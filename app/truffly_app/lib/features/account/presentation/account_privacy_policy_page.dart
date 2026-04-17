import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountPrivacyPolicyPage extends StatelessWidget {
  const AccountPrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSubpageScaffold(
      title: l10n.accountPrivacyPolicyTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          _LegalLeadCard(
            title: l10n.accountPrivacyPolicyLeadTitle,
            body: l10n.accountPrivacyPolicyLeadBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _LegalSection(
            heading: l10n.accountPrivacyPolicySectionDataTitle,
            body: l10n.accountPrivacyPolicySectionDataBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _LegalSection(
            heading: l10n.accountPrivacyPolicySectionUsageTitle,
            body: l10n.accountPrivacyPolicySectionUsageBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _LegalSection(
            heading: l10n.accountPrivacyPolicySectionSharingTitle,
            body: l10n.accountPrivacyPolicySectionSharingBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _LegalSection(
            heading: l10n.accountPrivacyPolicySectionRightsTitle,
            body: l10n.accountPrivacyPolicySectionRightsBody,
          ),
        ],
      ),
    );
  }
}

class _LegalLeadCard extends StatelessWidget {
  const _LegalLeadCard({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              body,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              heading,
              style: AppTextStyles.cardTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              body,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ],
        ),
      ),
    );
  }
}
