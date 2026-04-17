import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_menu_row.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_section_card.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(appLocaleCodeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return AccountSubpageScaffold(
      title: l10n.accountSettingsTitle,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          Text(
            l10n.accountSettingsIntro,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: l10n.accountSettingsPreferencesSection,
            children: [
              _SettingsValueRow(
                key: const Key('settings_language_tile'),
                icon: Icons.language_outlined,
                label: l10n.accountSettingsLanguageLabel,
                value: _languageLabel(l10n, localeCode),
                onTap: () => _showLanguageSheet(context, ref),
              ),
              const Divider(height: 1, color: AppColors.black10),
              _SettingsSwitchRow(
                key: const Key('settings_notifications_tile'),
                icon: Icons.notifications_none_rounded,
                label: l10n.accountSettingsNotificationsLabel,
                value: notificationsEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationsEnabledProvider.notifier)
                      .setEnabled(value);
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: l10n.accountSettingsLegalSection,
            children: [
              AccountMenuRow(
                key: const Key('settings_privacy_tile'),
                label: l10n.accountSettingsPrivacyPolicyLabel,
                icon: Icons.privacy_tip_outlined,
                onTap: () => context.push(AppRoutes.accountPrivacyPolicy),
              ),
              const Divider(height: 1, color: AppColors.black10),
              AccountMenuRow(
                key: const Key('settings_terms_tile'),
                label: l10n.accountSettingsTermsLabel,
                icon: Icons.description_outlined,
                onTap: () => context.push(AppRoutes.accountTerms),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingL),
          AccountSectionCard(
            title: l10n.accountSettingsAccountSection,
            children: [
              AccountMenuRow(
                key: const Key('settings_delete_account_tile'),
                label: l10n.accountSettingsDeleteAccountLabel,
                icon: Icons.delete_outline_rounded,
                isDestructive: true,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _languageLabel(AppLocalizations l10n, String localeCode) {
    return localeCode.trim().toLowerCase() == 'en'
        ? l10n.accountLanguageEnglish
        : l10n.accountLanguageItalian;
  }

  Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final currentCode = ref.read(appLocaleCodeProvider).trim().toLowerCase();

    final selectedCode = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              0,
              AppSpacing.spacingM,
              AppSpacing.spacingM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountSettingsLanguageSheetTitle,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  l10n.accountSettingsLanguageSheetBody,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.black80,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _LanguageOptionTile(
                  label: l10n.accountLanguageItalian,
                  selected: currentCode != 'en',
                  onTap: () => Navigator.of(context).pop('it'),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                _LanguageOptionTile(
                  label: l10n.accountLanguageEnglish,
                  selected: currentCode == 'en',
                  onTap: () => Navigator.of(context).pop('en'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCode == null) return;
    ref.read(appLocaleProvider.notifier).setLanguageCode(selectedCode);
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.accountSettingsDeleteAccountDialogTitle),
          content: Text(l10n.accountSettingsDeleteAccountDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.accountSettingsDeleteAccountDialogCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.accountSettingsDeleteAccountDialogConfirm),
            ),
          ],
        );
      },
    );

    if (!context.mounted || confirmed != true) return;

    // TODO: Connect this confirmation to the real account deletion flow.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.accountSettingsDeleteAccountPendingMessage),
      ),
    );
  }
}

class _SettingsValueRow extends StatelessWidget {
  const _SettingsValueRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingS,
          ),
          child: Row(
            children: [
              _SettingsLeadingIcon(icon: icon),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.black80,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black50,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingXS),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.black50,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingXXS,
      ),
      child: Row(
        children: [
          _SettingsLeadingIcon(icon: icon),
          const SizedBox(width: AppSpacing.spacingS),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.sectionTitle.copyWith(
                color: AppColors.black80,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsLeadingIcon extends StatelessWidget {
  const _SettingsLeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.black,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          icon,
          color: AppColors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingM,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.black10,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: AppTextStyles.bodyLarge),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? AppColors.accent : AppColors.black50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
