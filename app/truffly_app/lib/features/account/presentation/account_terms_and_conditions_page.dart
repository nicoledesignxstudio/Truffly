import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountTermsAndConditionsPage extends StatelessWidget {
  const AccountTermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSubpageScaffold(
      title: l10n.accountTermsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          _TermsSection(
            title: l10n.accountTermsLeadTitle,
            body: l10n.accountTermsLeadBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _TermsSection(
            title: l10n.accountTermsSectionOrdersTitle,
            body: l10n.accountTermsSectionOrdersBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _TermsSection(
            title: l10n.accountTermsSectionShippingTitle,
            body: l10n.accountTermsSectionShippingBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _TermsSection(
            title: l10n.accountTermsSectionSupportTitle,
            body: l10n.accountTermsSectionSupportBody,
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _TermsSection(
            title: l10n.accountTermsSectionUpdatesTitle,
            body: l10n.accountTermsSectionUpdatesBody,
          ),
        ],
      ),
    );
  }
}

class _TermsSection extends StatelessWidget {
  const _TermsSection({
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
