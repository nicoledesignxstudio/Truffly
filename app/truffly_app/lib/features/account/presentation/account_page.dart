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
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
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
              await ref.read(currentUserAccountProfileProvider.future);
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
      builder: (context) =>
          _LogoutConfirmationDialog(isItalian: _isItalian(context)),
    );

    if (!mounted || shouldLogout != true) return;

    setState(() {
      _isSigningOut = true;
    });

    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;

    setState(() {
      _isSigningOut = false;
    });
  }
}

class _AccountContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final businessItems = profile.isSeller
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
            _AccountDestination(
              label: _text(
                context,
                it: 'Diventa venditore',
                en: 'Become a seller',
              ),
              icon: Icons.workspace_premium_outlined,
              onTap: () => context.push(AppRoutes.accountBecomeSeller),
            ),
          ];

    final personalItems = profile.isSeller
        ? [
            _AccountDestination(
              label: _text(
                context,
                it: 'Articoli preferiti',
                en: 'Favorite items',
              ),
              icon: Icons.favorite_border_rounded,
              onTap: () => context.push(AppRoutes.accountFavorites),
            ),
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
              label: _text(context, it: 'Pagamenti', en: 'Payments'),
              icon: Icons.credit_card_outlined,
              onTap: () => context.push(AppRoutes.accountPayments),
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
              label: _text(context, it: 'Pagamenti', en: 'Payments'),
              icon: Icons.credit_card_outlined,
              onTap: () => context.push(AppRoutes.accountPayments),
            ),
          ];

    final supportItems = [
      _AccountDestination(
        label: _text(context, it: 'Guida a Truffly', en: 'Guide to Truffly'),
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
          const SizedBox(height: AppSpacing.spacingL),
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
    final roleLabel = profile.isSeller
        ? _text(context, it: 'Venditore', en: 'Seller')
        : _text(context, it: 'Acquirente', en: 'Buyer');

    final locationLabel = [
      if ((profile.region ?? '').trim().isNotEmpty) profile.region!.trim(),
      if ((profile.countryCode ?? '').trim().isNotEmpty)
        localizedEuropeanCountryName(
          AppLocalizations.of(context)!,
          profile.countryCode!,
        ),
    ].join(' - ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
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
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Wrap(
                    spacing: AppSpacing.spacingXS,
                    runSpacing: AppSpacing.spacingXS,
                    children: [
                      _HeaderPill(label: roleLabel, isAccent: profile.isSeller),
                      if (locationLabel.isNotEmpty)
                        _HeaderPill(label: locationLabel),
                    ],
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

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, this.isAccent = false});

  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isAccent ? const Color(0xFFFFEEE8) : AppColors.softGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingS,
          vertical: AppSpacing.spacingXS,
        ),
        child: Text(
          label,
          style: AppTextStyles.micro.copyWith(
            color: isAccent ? AppColors.accent : AppColors.black80,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _LogoutConfirmationDialog extends StatelessWidget {
  const _LogoutConfirmationDialog({required this.isItalian});

  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isItalian ? 'Vuoi uscire?' : 'Log out?'),
      content: Text(
        isItalian
            ? 'Verrai reindirizzato al flusso di accesso.'
            : 'You will be redirected to the sign-in flow.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(isItalian ? 'Annulla' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(isItalian ? 'Esci' : 'Log out'),
        ),
      ],
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
