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
          ..._faqSections(l10n).expand(
            (section) => [
              _SupportFaqSection(section: section),
              const SizedBox(height: AppSpacing.spacingM),
            ],
          ),
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

class _SupportFaqSection extends StatelessWidget {
  const _SupportFaqSection({required this.section});

  final _FaqSectionData section;

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      title: section.title,
      children: [
        for (var index = 0; index < section.items.length; index++) ...[
          _SupportFaqTile(item: section.items[index]),
          if (index < section.items.length - 1)
            const Divider(height: 1, color: AppColors.black10),
        ],
      ],
    );
  }
}

class _SupportFaqTile extends StatelessWidget {
  const _SupportFaqTile({required this.item});

  final _FaqItemData item;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: Key('support_faq_${item.id}'),
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
          item.question,
          style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w500),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              item.answer,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqSectionData {
  const _FaqSectionData({required this.title, required this.items});

  final String title;
  final List<_FaqItemData> items;
}

class _FaqItemData {
  const _FaqItemData({
    required this.id,
    required this.question,
    required this.answer,
  });

  final String id;
  final String question;
  final String answer;
}

List<_FaqSectionData> _faqSections(AppLocalizations l10n) => [
  _FaqSectionData(
    title: l10n.accountSupportFaqBuyingOrdersSection,
    items: [
      _FaqItemData(
        id: 'buy_truffle',
        question: l10n.accountSupportFaqBuyTruffleQuestion,
        answer: l10n.accountSupportFaqBuyTruffleAnswer,
      ),
      _FaqItemData(
        id: 'track_order',
        question: l10n.accountSupportFaqTrackOrderQuestion,
        answer: l10n.accountSupportFaqTrackOrderAnswer,
      ),
      _FaqItemData(
        id: 'after_order',
        question: l10n.accountSupportFaqAfterOrderQuestion,
        answer: l10n.accountSupportFaqAfterOrderAnswer,
      ),
      _FaqItemData(
        id: 'seller_does_not_ship',
        question: l10n.accountSupportFaqSellerDoesNotShipQuestion,
        answer: l10n.accountSupportFaqSellerDoesNotShipAnswer,
      ),
      _FaqItemData(
        id: 'confirm_delivery',
        question: l10n.accountSupportFaqConfirmDeliveryQuestion,
        answer: l10n.accountSupportFaqConfirmDeliveryAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqTrufflesQualitySection,
    items: [
      _FaqItemData(
        id: 'truffles_fresh',
        question: l10n.accountSupportFaqTrufflesFreshQuestion,
        answer: l10n.accountSupportFaqTrufflesFreshAnswer,
      ),
      _FaqItemData(
        id: 'quality_grades',
        question: l10n.accountSupportFaqQualityGradesQuestion,
        answer: l10n.accountSupportFaqQualityGradesAnswer,
      ),
      _FaqItemData(
        id: 'store_truffles',
        question: l10n.accountSupportFaqStoreTrufflesQuestion,
        answer: l10n.accountSupportFaqStoreTrufflesAnswer,
      ),
      _FaqItemData(
        id: 'damaged_order',
        question: l10n.accountSupportFaqDamagedOrderQuestion,
        answer: l10n.accountSupportFaqDamagedOrderAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqShippingDeliverySection,
    items: [
      _FaqItemData(
        id: 'supported_countries',
        question: l10n.accountSupportFaqSupportedCountriesQuestion,
        answer: l10n.accountSupportFaqSupportedCountriesAnswer,
      ),
      _FaqItemData(
        id: 'shipping_cost',
        question: l10n.accountSupportFaqShippingCostQuestion,
        answer: l10n.accountSupportFaqShippingCostAnswer,
      ),
      _FaqItemData(
        id: 'tracking_number',
        question: l10n.accountSupportFaqTrackingNumberQuestion,
        answer: l10n.accountSupportFaqTrackingNumberAnswer,
      ),
      _FaqItemData(
        id: 'package_delayed',
        question: l10n.accountSupportFaqPackageDelayedQuestion,
        answer: l10n.accountSupportFaqPackageDelayedAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqPaymentsRefundsSection,
    items: [
      _FaqItemData(
        id: 'secure_payments',
        question: l10n.accountSupportFaqSecurePaymentsQuestion,
        answer: l10n.accountSupportFaqSecurePaymentsAnswer,
      ),
      _FaqItemData(
        id: 'payment_charged',
        question: l10n.accountSupportFaqPaymentChargedQuestion,
        answer: l10n.accountSupportFaqPaymentChargedAnswer,
      ),
      _FaqItemData(
        id: 'refunds_work',
        question: l10n.accountSupportFaqRefundsWorkQuestion,
        answer: l10n.accountSupportFaqRefundsWorkAnswer,
      ),
      _FaqItemData(
        id: 'refund_timing',
        question: l10n.accountSupportFaqRefundTimingQuestion,
        answer: l10n.accountSupportFaqRefundTimingAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqSellingSection,
    items: [
      _FaqItemData(
        id: 'become_seller',
        question: l10n.accountSupportFaqBecomeSellerQuestion,
        answer: l10n.accountSupportFaqBecomeSellerAnswer,
      ),
      _FaqItemData(
        id: 'verify_identity',
        question: l10n.accountSupportFaqVerifyIdentityQuestion,
        answer: l10n.accountSupportFaqVerifyIdentityAnswer,
      ),
      _FaqItemData(
        id: 'seller_approval_timing',
        question: l10n.accountSupportFaqSellerApprovalTimingQuestion,
        answer: l10n.accountSupportFaqSellerApprovalTimingAnswer,
      ),
      _FaqItemData(
        id: 'publish_after_approval',
        question: l10n.accountSupportFaqPublishAfterApprovalQuestion,
        answer: l10n.accountSupportFaqPublishAfterApprovalAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqSellerPaymentsSection,
    items: [
      _FaqItemData(
        id: 'seller_payment_timing',
        question: l10n.accountSupportFaqSellerPaymentTimingQuestion,
        answer: l10n.accountSupportFaqSellerPaymentTimingAnswer,
      ),
      _FaqItemData(
        id: 'stripe_account',
        question: l10n.accountSupportFaqStripeAccountQuestion,
        answer: l10n.accountSupportFaqStripeAccountAnswer,
      ),
      _FaqItemData(
        id: 'commission',
        question: l10n.accountSupportFaqCommissionQuestion,
        answer: l10n.accountSupportFaqCommissionAnswer,
      ),
    ],
  ),
  _FaqSectionData(
    title: l10n.accountSupportFaqAccountPrivacySection,
    items: [
      _FaqItemData(
        id: 'delete_account',
        question: l10n.accountSupportFaqDeleteAccountQuestion,
        answer: l10n.accountSupportFaqDeleteAccountAnswer,
      ),
      _FaqItemData(
        id: 'after_delete_account',
        question: l10n.accountSupportFaqAfterDeleteAccountQuestion,
        answer: l10n.accountSupportFaqAfterDeleteAccountAnswer,
      ),
      _FaqItemData(
        id: 'protect_data',
        question: l10n.accountSupportFaqProtectDataQuestion,
        answer: l10n.accountSupportFaqProtectDataAnswer,
      ),
    ],
  ),
];

class _ContactSupportCard extends StatelessWidget {
  const _ContactSupportCard({required this.onPressed});

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
