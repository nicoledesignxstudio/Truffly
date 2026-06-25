import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_menu_row.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_section_card.dart';
import 'package:truffly_app/features/account/presentation/widgets/destructive_confirmation_dialog.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/features/push/application/notification_preferences_provider.dart';
import 'package:truffly_app/features/truffle/presentation/publish_truffle_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.account),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: Text(
          'Account',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => _AccountContent(
            profile: profile,
            isSigningOut: _isSigningOut,
            onLogoutPressed: _handleLogoutPressed,
            onRefresh: () async {
              ref.invalidate(currentUserAccountProfileProvider);
              ref.invalidate(currentSellerStripeStatusProvider);
              try {
                await Future.wait([
                  ref.read(currentUserAccountProfileProvider.future),
                  ref.read(currentSellerStripeStatusProvider.future),
                ]);
              } catch (_) {
                // Best effort refresh.
              }
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _AccountErrorState(
            onRetry: () {
              ref.invalidate(currentUserAccountProfileProvider);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogoutPressed() async {
    if (_isSigningOut) return;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => DestructiveConfirmationDialog(
        title: _text(context, it: 'Vuoi uscire?', en: 'Log out?'),
        message: _text(
          context,
          it: 'Verrai reindirizzato al flusso di accesso.',
          en: 'You will be redirected to the sign-in flow.',
        ),
        confirmLabel: _text(context, it: 'Esci', en: 'Log out'),
        cancelLabel: _text(context, it: 'Annulla', en: 'Cancel'),
      ),
    );

    if (!mounted || shouldLogout != true) return;

    setState(() => _isSigningOut = true);
    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;
    setState(() => _isSigningOut = false);
  }
}

class _AccountContent extends ConsumerWidget {
  const _AccountContent({
    required this.profile,
    required this.isSigningOut,
    required this.onLogoutPressed,
    required this.onRefresh,
  });

  final CurrentUserProfile profile;
  final bool isSigningOut;
  final Future<void> Function() onLogoutPressed;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerStripeStatusAsync = ref.watch(
      currentSellerStripeStatusProvider,
    );
    final sellerStripeStatus = sellerStripeStatusAsync.valueOrNull;

    final showSellerProgress =
        profile.isSellerRequestPending || profile.isSellerRequestApproved;
    final sellerStripeReady = sellerStripeStatus?.isReady == true;

    final businessItems = profile.isSellerRequestPending
        ? [
            _AccountDestination(
              label: _text(context, it: 'I miei ordini', en: 'My orders'),
              icon: Icons.receipt_long_outlined,
              onTap: () => context.push(AppRoutes.accountOrders),
            ),
            _AccountDestination(
              label: _text(
                context,
                it: 'Articoli preferiti',
                en: 'Favorite items',
              ),
              icon: Icons.favorite_border_rounded,
              onTap: () => context.push(AppRoutes.accountFavorites),
            ),
          ]
        : profile.isSellerRequestApproved
        ? [
            _AccountDestination(
              label: _text(
                context,
                it: 'Profilo venditore',
                en: 'Seller profile',
              ),
              icon: Icons.storefront_outlined,
              onTap: () =>
                  context.push(AppRoutes.sellerProfilePath(profile.userId)),
            ),
            _AccountDestination(
              label: _text(context, it: 'Account Stripe', en: 'Account Stripe'),
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => context.push(AppRoutes.accountBecomeSeller),
            ),
            _AccountDestination(
              label: _text(context, it: 'I miei ordini', en: 'My orders'),
              icon: Icons.receipt_long_outlined,
              onTap: () => context.push(AppRoutes.accountOrders),
            ),
            _AccountDestination(
              label: _text(context, it: 'I miei tartufi', en: 'My truffles'),
              icon: Icons.forest_outlined,
              onTap: () => context.push(AppRoutes.accountMyTruffles),
            ),
          ]
        : [
            _AccountDestination(
              label: _text(context, it: 'I miei ordini', en: 'My orders'),
              icon: Icons.receipt_long_outlined,
              onTap: () => context.push(AppRoutes.accountOrders),
            ),
            _AccountDestination(
              label: _text(
                context,
                it: 'Articoli preferiti',
                en: 'Favorite items',
              ),
              icon: Icons.favorite_border_rounded,
              onTap: () => context.push(AppRoutes.accountFavorites),
            ),
            if ((profile.countryCode ?? '').trim().toUpperCase() == 'IT')
              _AccountDestination(
                label: _text(
                  context,
                  it: 'Diventa venditore',
                  en: 'Become a seller',
                ),
                icon: Icons.workspace_premium_outlined,
                onTap: () => context.push(AppRoutes.accountSellerOnboarding),
              ),
          ];

    final personalItems = profile.isSeller
        ? [
            _AccountDestination(
              label: _text(
                context,
                it: 'Dettagli account',
                en: 'Account details',
              ),
              icon: Icons.person_outline_rounded,
              onTap: () => context.push(AppRoutes.accountDetails),
            ),
            _AccountDestination(
              label: _text(context, it: 'Spedizione', en: 'Shipping'),
              icon: Icons.local_shipping_outlined,
              onTap: () => context.push(AppRoutes.accountShipping),
            ),
          ]
        : [
            _AccountDestination(
              label: _text(
                context,
                it: 'Dettagli account',
                en: 'Account details',
              ),
              icon: Icons.person_outline_rounded,
              onTap: () => context.push(AppRoutes.accountDetails),
            ),
            _AccountDestination(
              label: _text(context, it: 'Spedizione', en: 'Shipping'),
              icon: Icons.local_shipping_outlined,
              onTap: () => context.push(AppRoutes.accountShipping),
            ),
            _AccountDestination(
              label: _text(context, it: 'Notifiche', en: 'Notifications'),
              icon: Icons.notifications_none_rounded,
              onTap: () => context.push(AppRoutes.notifications),
            ),
          ];

    final supportItems = [
      _AccountDestination(
        label: _text(context, it: 'Guide ai tartufi', en: 'Truffle guides'),
        icon: Icons.menu_book_outlined,
        onTap: () => context.push(AppRoutes.guides),
      ),
      _AccountDestination(
        label: _text(context, it: 'Assistenza', en: 'Support'),
        icon: Icons.headset_mic_outlined,
        onTap: () => context.push(AppRoutes.accountSupport),
      ),
      _AccountDestination(
        label: _text(context, it: 'Impostazioni', en: 'Settings'),
        icon: Icons.settings_outlined,
        onTap: () => context.push(AppRoutes.accountSettings),
      ),
    ];

    final notificationsEnabledAsync = ref.watch(notificationsEnabledProvider);
    final notificationsEnabled = notificationsEnabledAsync.valueOrNull;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          _AccountHeaderCard(profile: profile),
          const SizedBox(height: AppSpacing.spacingM),
          if (showSellerProgress) ...[
            _SellerProgressCard(
              sellerStatus: profile.sellerStatus,
              sellerStripeReady: sellerStripeReady,
              region: profile.region,
            ),
            const SizedBox(height: AppSpacing.spacingM),
          ],
          AccountSectionCard(
            title: _text(context, it: 'Business', en: 'Business'),
            children: [
              for (final item in businessItems)
                AccountMenuRow(
                  label: item.label,
                  icon: item.icon,
                  onTap: item.onTap,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: _text(context, it: 'Personal', en: 'Personal'),
            children: [
              for (final item in personalItems)
                AccountMenuRow(
                  label: item.label,
                  icon: item.icon,
                  onTap: item.onTap,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: _text(context, it: 'Support', en: 'Support'),
            children: [
              for (final item in supportItems)
                AccountMenuRow(
                  label: item.label,
                  icon: item.icon,
                  onTap: item.onTap,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacingM),
          AccountSectionCard(
            title: _text(context, it: 'Sessione', en: 'Session'),
            children: [
              AccountMenuRow(
                label: _text(context, it: 'Esci', en: 'Log out'),
                icon: Icons.logout_outlined,
                onTap: isSigningOut ? null : () => onLogoutPressed(),
                isDestructive: true,
              ),
            ],
          ),
          if (isSigningOut) ...[
            const SizedBox(height: AppSpacing.spacingM),
            Center(
              child: Text(
                _text(context, it: 'Uscita in corso...', en: 'Signing out...'),
                style: AppTextStyles.bodySmall,
              ),
            ),
          ],
          if (notificationsEnabled != null) ...[
            const SizedBox(height: AppSpacing.spacingM),
            Text(
              _text(
                context,
                it: notificationsEnabled
                    ? 'Le notifiche sono abilitate su questo dispositivo.'
                    : 'Le notifiche sono disattivate su questo dispositivo.',
                en: notificationsEnabled
                    ? 'Notifications are enabled on this device.'
                    : 'Notifications are disabled on this device.',
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.micro,
            ),
          ],
          const SizedBox(height: AppSpacing.spacingM),
        ],
      ),
    );
  }
}

class _AccountHeaderCard extends StatelessWidget {
  const _AccountHeaderCard({required this.profile});

  final CurrentUserProfile profile;

  @override
  Widget build(BuildContext context) {
    final locationLabel = [
      if ((profile.region ?? '').trim().isNotEmpty)
        _formatLocation(profile.region!.trim()),
      if ((profile.countryCode ?? '').trim().isNotEmpty)
        localizedEuropeanCountryName(
          AppLocalizations.of(context)!,
          profile.countryCode!,
        ),
    ].join(', ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black20, width: 1),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SellerAvatar(
              imageUrl: profile.profileImageUrl,
              initials: profile.initials,
              size: 58,
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.displayName,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(profile.email, style: AppTextStyles.bodySmall),
                  if (locationLabel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.black50,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationLabel,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.black80,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerProgressCard extends StatelessWidget {
  const _SellerProgressCard({
    required this.sellerStatus,
    required this.sellerStripeReady,
    required this.region,
  });

  final String sellerStatus;
  final bool sellerStripeReady;
  final String? region;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';
    final isPending = sellerStatus == 'pending';
    final isApproved = sellerStatus == 'approved';
    if (isApproved && sellerStripeReady) {
      return _PublishTruffleCard(
        label: isItalian ? 'Pubblica un tartufo' : 'Publish a truffle',
        subtitle: isItalian
            ? 'Condividi i tuoi tartufi freschi'
            : 'Share your fresh truffles',
        onTap: () => Navigator.of(
          context,
        ).push(buildPublishTruffleRoute(initialRegion: region)),
      );
    }

    final title = switch ((isPending, sellerStripeReady)) {
      (true, _) =>
        isItalian ? 'Richiesta in revisione' : 'Request under review',
      (false, false) when isApproved =>
        isItalian
            ? 'Completa il tuo Account Stripe'
            : 'Complete your Stripe account',
      _ => isItalian ? 'Richiesta venditore' : 'Seller request',
    };
    final body = switch ((isPending, sellerStripeReady)) {
      (true, _) =>
        isItalian
            ? 'Grazie per la tua richiesta. L\'abbiamo ricevuta e verra analizzata il prima possibile.'
            : 'Thanks for your request. We received it and it will be reviewed as soon as possible.',
      (false, false) when isApproved =>
        isItalian
            ? 'Stripe gestisce i pagamenti e i bonifici in sicurezza. Completa la registrazione per iniziare a vendere.'
            : 'Stripe handles payments and payouts securely. Complete registration to start selling.',
      (false, true) when isApproved =>
        isItalian
            ? 'Il tuo account e pronto. Ora puoi pubblicare nuovi tartufi su Truffly.'
            : 'Your account is ready. You can publish new truffles on Truffly.',
      _ =>
        isItalian
            ? 'Stato venditore non disponibile.'
            : 'Seller status unavailable.',
    };
    final icon = switch ((isPending, sellerStripeReady)) {
      (true, _) => Icons.hourglass_bottom_rounded,
      (false, false) when isApproved => Icons.account_balance_wallet_outlined,
      (false, true) when isApproved => Icons.add_circle_outline_rounded,
      _ => Icons.storefront_outlined,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.black, size: 21),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    softWrap: true,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXXS),
                  Text(
                    body,
                    softWrap: true,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                  if (isApproved && !sellerStripeReady) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    FilledButton(
                      onPressed: () =>
                          context.push(AppRoutes.accountBecomeSeller),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black,
                        minimumSize: const Size(0, 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.spacingM,
                          vertical: 14,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        isItalian ? 'Registrati' : 'Register',
                        style: AppTextStyles.buttonText.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublishTruffleCard extends StatelessWidget {
  const _PublishTruffleCard({
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(10),
          boxShadow: AppShadows.authField,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingS,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXXS),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.78),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountErrorState extends StatelessWidget {
  const _AccountErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _text(
                context,
                it: 'Impossibile caricare il profilo account in questo momento.',
                en: 'Unable to load your account profile right now.',
              ),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            FilledButton(
              onPressed: onRetry,
              child: Text(_text(context, it: 'Riprova', en: 'Retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDestination {
  const _AccountDestination({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}

bool _isItalian(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'it';
}

String _text(BuildContext context, {required String it, required String en}) {
  return _isItalian(context) ? it : en;
}

String _formatLocation(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return trimmed;
  final normalized = trimmed.toLowerCase();
  return normalized[0].toUpperCase() + normalized.substring(1);
}
