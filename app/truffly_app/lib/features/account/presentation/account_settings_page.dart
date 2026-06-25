import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/data/account_deletion_service.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_menu_row.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_section_card.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/features/account/presentation/widgets/destructive_confirmation_dialog.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/push/application/notification_preferences_provider.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  bool _isDeletingAccount = false;
  bool _isUpdatingNotifications = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(appLocaleCodeProvider);
    final notificationsEnabledAsync = ref.watch(notificationsEnabledProvider);
    final notificationsEnabled = notificationsEnabledAsync.valueOrNull ?? false;
    final notificationsAvailable = notificationsEnabledAsync.hasValue;

    return AccountSubpageScaffold(
      title: l10n.accountSettingsTitle,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isDeletingAccount,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacingM,
                AppSpacing.spacingS,
                AppSpacing.spacingM,
                AppSpacing.spacingL,
              ),
              children: [
                Text(
                  l10n.accountSettingsIntro,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black80,
                  ),
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
                      isEnabled:
                          notificationsAvailable && !_isUpdatingNotifications,
                      onChanged:
                          notificationsAvailable && !_isUpdatingNotifications
                          ? (value) {
                              _updateNotificationsPreference(value);
                            }
                          : null,
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
                    const Divider(height: 1, color: AppColors.black10),
                    AccountMenuRow(
                      key: const Key('settings_refund_tile'),
                      label: l10n.accountSettingsRefundAndCancellationLabel,
                      icon: Icons.currency_exchange_rounded,
                      onTap: () =>
                          context.push(AppRoutes.accountRefundAndCancellation),
                    ),
                    const Divider(height: 1, color: AppColors.black10),
                    AccountMenuRow(
                      key: const Key('settings_legal_information_tile'),
                      label: l10n.accountSettingsLegalInformationLabel,
                      icon: Icons.gavel_outlined,
                      onTap: () =>
                          context.push(AppRoutes.accountLegalInformation),
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
                      onTap: _isDeletingAccount
                          ? null
                          : () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isDeletingAccount)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66FFFFFF),
                child: Center(child: CircularProgressIndicator()),
              ),
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
        return DestructiveConfirmationDialog(
          title: l10n.accountSettingsDeleteAccountDialogTitle,
          message: l10n.accountSettingsDeleteAccountDialogBody,
          confirmLabel: l10n.accountSettingsDeleteAccountDialogConfirm,
          cancelLabel: l10n.accountSettingsDeleteAccountDialogCancel,
        );
      },
    );

    if (!context.mounted || confirmed != true) return;

    await _deleteAccount(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    if (_isDeletingAccount) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDeletingAccount = true;
    });

    try {
      final result = await ref
          .read(accountDeletionServiceProvider)
          .deleteCurrentAccount();
      if (!context.mounted) return;

      final message = switch (result.status) {
        AccountDeletionOutcome.deleted =>
          l10n.accountSettingsDeleteAccountDeletedMessage,
        AccountDeletionOutcome.deactivated =>
          l10n.accountSettingsDeleteAccountDeactivatedMessage,
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      await ref.read(authNotifierProvider.notifier).signOut();
    } on AccountDeletionServiceException catch (error) {
      if (!context.mounted) return;

      final message = switch (error.failure) {
        AccountDeletionFailure.unauthenticated =>
          l10n.accountSettingsDeleteAccountUnauthorizedMessage,
        AccountDeletionFailure.inactiveAccount =>
          l10n.accountSettingsDeleteAccountInactiveMessage,
        AccountDeletionFailure.requestFailed ||
        AccountDeletionFailure.network ||
        AccountDeletionFailure.unknown =>
          l10n.accountSettingsDeleteAccountErrorMessage,
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingAccount = false;
        });
      }
    }
  }

  Future<void> _updateNotificationsPreference(bool enabled) async {
    if (_isUpdatingNotifications) return;

    setState(() {
      _isUpdatingNotifications = true;
    });

    try {
      await ref
          .read(notificationPreferenceServiceProvider)
          .setCurrentDeviceNotificationsEnabled(enabled);
      ref.invalidate(notificationsEnabledProvider);
    } catch (_) {
      if (!mounted) return;
      final isItalian = Localizations.localeOf(context).languageCode == 'it';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isItalian
                ? 'Impossibile aggiornare la preferenza notifiche.'
                : 'Unable to update the notifications preference.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
    }
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
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black80,
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
    required this.isEnabled,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final bool isEnabled;
  final ValueChanged<bool>? onChanged;

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
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.black80,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.accent,
            onChanged: isEnabled ? onChanged : null,
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
        child: Icon(icon, color: AppColors.white, size: 18),
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
              Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
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
