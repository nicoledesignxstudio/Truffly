import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/data/account_support_launcher.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_section_card.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountSupportPage extends ConsumerWidget {
  const AccountSupportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return AccountSubpageScaffold(
      title: l10n.accountSupportTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          Text(
            l10n.accountSupportIntro,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: l10n.accountSupportFaqSection,
            children: const [
              _SupportFaqTile(questionKey: _SupportFaqQuestion.orderFlow),
              Divider(height: 1, color: AppColors.black10),
              _SupportFaqTile(questionKey: _SupportFaqQuestion.shippingTiming),
              Divider(height: 1, color: AppColors.black10),
              _SupportFaqTile(questionKey: _SupportFaqQuestion.orderTracking),
              Divider(height: 1, color: AppColors.black10),
              _SupportFaqTile(questionKey: _SupportFaqQuestion.cancellation),
              Divider(height: 1, color: AppColors.black10),
              _SupportFaqTile(questionKey: _SupportFaqQuestion.deliveryIssue),
              Divider(height: 1, color: AppColors.black10),
              _SupportFaqTile(questionKey: _SupportFaqQuestion.contact),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _ContactSupportCard(
            onPressed: () async {
              final opened = await ref
                  .read(accountSupportLauncherProvider)
                  .composeSupportEmail();
              if (!context.mounted || opened) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.accountSupportEmailLaunchError)),
              );
            },
          ),
        ],
      ),
    );
  }
}

enum _SupportFaqQuestion {
  orderFlow,
  shippingTiming,
  orderTracking,
  cancellation,
  deliveryIssue,
  contact,
}

class _SupportFaqTile extends StatelessWidget {
  const _SupportFaqTile({
    required this.questionKey,
  });

  final _SupportFaqQuestion questionKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: Key('support_faq_${questionKey.name}'),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          0,
          AppSpacing.spacingM,
          AppSpacing.spacingM,
        ),
        iconColor: AppColors.black80,
        collapsedIconColor: AppColors.black50,
        title: Text(
          _questionText(l10n, questionKey),
          style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _answerText(l10n, questionKey),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ),
        ],
      ),
    );
  }

  String _questionText(AppLocalizations l10n, _SupportFaqQuestion key) {
    return switch (key) {
      _SupportFaqQuestion.orderFlow => l10n.accountSupportFaqOrderFlowQuestion,
      _SupportFaqQuestion.shippingTiming =>
        l10n.accountSupportFaqShippingTimingQuestion,
      _SupportFaqQuestion.orderTracking =>
        l10n.accountSupportFaqOrderTrackingQuestion,
      _SupportFaqQuestion.cancellation =>
        l10n.accountSupportFaqCancellationQuestion,
      _SupportFaqQuestion.deliveryIssue =>
        l10n.accountSupportFaqDeliveryIssueQuestion,
      _SupportFaqQuestion.contact => l10n.accountSupportFaqContactQuestion,
    };
  }

  String _answerText(AppLocalizations l10n, _SupportFaqQuestion key) {
    return switch (key) {
      _SupportFaqQuestion.orderFlow => l10n.accountSupportFaqOrderFlowAnswer,
      _SupportFaqQuestion.shippingTiming =>
        l10n.accountSupportFaqShippingTimingAnswer,
      _SupportFaqQuestion.orderTracking =>
        l10n.accountSupportFaqOrderTrackingAnswer,
      _SupportFaqQuestion.cancellation =>
        l10n.accountSupportFaqCancellationAnswer,
      _SupportFaqQuestion.deliveryIssue =>
        l10n.accountSupportFaqDeliveryIssueAnswer,
      _SupportFaqQuestion.contact => l10n.accountSupportFaqContactAnswer,
    };
  }
}

class _ContactSupportCard extends StatelessWidget {
  const _ContactSupportCard({
    required this.onPressed,
  });

  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              l10n.accountSupportContactTitle,
              style: AppTextStyles.sectionTitle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              l10n.accountSupportContactBody,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              supportEmailAddress,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              key: const Key('support_email_button'),
              label: l10n.accountSupportContactCta,
              backgroundColor: AppColors.black,
              onPressed: () async {
                await onPressed();
              },
            ),
          ],
        ),
      ),
    );
  }
}
