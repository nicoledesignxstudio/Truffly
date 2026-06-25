import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/data/seller_dashboard_service.dart';
import 'package:truffly_app/features/account/data/seller_stripe_onboarding_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_providers.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';

class AccountBecomeSellerPage extends ConsumerStatefulWidget {
  const AccountBecomeSellerPage({
    super.key,
    this.stripeCallbackHint,
  });

  final String? stripeCallbackHint;

  @override
  ConsumerState<AccountBecomeSellerPage> createState() =>
      _AccountBecomeSellerPageState();
}

class _AccountBecomeSellerPageState extends ConsumerState<AccountBecomeSellerPage>
    with WidgetsBindingObserver {
  SellerStripeStatusSnapshot? _stripeStatus;
  bool _isLoadingStatus = false;
  bool _isOpeningOnboarding = false;
  bool _isRefreshing = false;
  bool _awaitingExternalReturn = false;
  bool _hasResolvedStripeStatus = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingExternalReturn) {
      _awaitingExternalReturn = false;
      _refreshStripeStatus(showVerifyingMessage: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserAccountProfileProvider);
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Scaffold(
      backgroundColor: AppColors.white,
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
                context.go(AppRoutes.account);
              }
            },
          ),
        ),
        title: Text(
          'Stripe',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) => _buildProfileAwareBody(
            context,
            profile: profile,
            isItalian: isItalian,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _CenteredMessageCard(
            title: isItalian ? 'Profilo non disponibile' : 'Profile unavailable',
            description: isItalian
                ? 'Non siamo riusciti a caricare il tuo profilo account.'
                : 'We could not load your account profile.',
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAwareBody(
    BuildContext context, {
    required CurrentUserProfile profile,
    required bool isItalian,
  }) {
    if (!profile.isSeller && profile.sellerStatus != 'approved') {
        return _CenteredMessageCard(
        title: isItalian ? 'Richiesta seller' : 'Seller request',
        description: isItalian
            ? "Il percorso per richiedere l'approvazione seller resta separato. Questa sezione Stripe si attiva solo dopo approvazione."
            : 'The approval request flow remains separate. This Stripe section activates only after approval.',
      );
    }

    if (profile.sellerStatus != 'approved') {
      final description = switch (profile.sellerStatus) {
        'pending' => isItalian
            ? "La tua richiesta seller e' ancora in revisione. Lo step Stripe si sblocca dopo l'approvazione."
            : 'Your seller request is still under review. The Stripe step unlocks only after approval.',
        'rejected' => isItalian
            ? "La tua richiesta seller e' stata rifiutata. Stripe onboarding non e' disponibile finche' non ottieni una nuova approvazione."
            : 'Your seller request was rejected. Stripe onboarding is unavailable until you obtain a new approval.',
        _ => isItalian
            ? 'Questa sezione si attiva solo per seller approvati.'
            : 'This section is available only for approved sellers.',
      };

      return _CenteredMessageCard(
        title: isItalian ? 'Stripe non ancora disponibile' : 'Stripe not available yet',
        description: description,
      );
    }

    if (!_hasResolvedStripeStatus && _stripeStatus == null) {
      return _CenteredMessageCard(
        title: isItalian ? 'Carico Stripe...' : 'Loading Stripe...',
        description: isItalian
            ? 'Stiamo recuperando lo stato del tuo account per mostrarti la schermata corretta.'
            : 'We are loading your account status so we can show the correct screen.',
      );
    }

    final dashboardAsync = ref.watch(currentSellerDashboardSummaryProvider);
    final stripeHasAccount = _stripeStatus?.accountId?.trim().isNotEmpty == true;
    final stripeActive =
        _stripeStatus?.chargesEnabled == true && _stripeStatus?.payoutsEnabled == true;
    final stripeVerificationPending = stripeHasAccount && !stripeActive;
    final stripeRequirementsPending = _stripeStatus?.requirementsPending == true;
    final stripeNotConnected = !stripeHasAccount;
    final isVerifying = _isLoadingStatus && _stripeStatus == null;
    final showDashboard = stripeActive;

    return RefreshIndicator(
      onRefresh: _refreshStripeStatus,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingM,
          AppSpacing.spacingM,
          AppSpacing.spacingL,
        ),
        children: [
          _StripeStatusHeaderCard(
            title: isItalian ? 'Stato account' : 'Account status',
            statusTitle: isVerifying
                ? (isItalian ? 'Verifica in corso...' : 'Checking...')
                : stripeActive
                ? (isItalian ? 'Stripe attivo' : 'Stripe active')
                : stripeNotConnected
                ? (isItalian ? 'Non collegato' : 'Not connected')
                : stripeVerificationPending
                ? (isItalian ? 'In verifica' : 'Under review')
                : (isItalian ? 'Da completare' : 'Incomplete'),
            description: isVerifying
                ? (isItalian
                    ? 'Stiamo aggiornando lo stato del tuo account Stripe...'
                    : 'We are updating your Stripe account status...')
                : stripeActive
                ? (isItalian
                    ? 'Il tuo account Stripe è attivo e pronto a ricevere pagamenti.'
                    : 'Your Stripe account is active and ready to receive payments.')
                : stripeVerificationPending
                ? (isItalian
                    ? 'Stripe sta ancora verificando il tuo account. Puoi gestire la verifica da Stripe.'
                    : 'Stripe is still verifying your account. You can manage verification directly in Stripe.')
                : (isItalian
                    ? 'Completa la registrazione Stripe per ricevere i pagamenti in sicurezza.'
                    : 'Complete Stripe registration to receive payments securely.'),
            statusTone: stripeActive
                ? _StripeTone.success
                : _StripeTone.warning,
            accountId: _stripeStatus?.accountId,
            isItalian: isItalian,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.spacingM),
            _InlineErrorBanner(message: _errorMessage!),
          ],
          if (stripeRequirementsPending)
            _RequirementsNoticeCard(isItalian: isItalian),
          if (!showDashboard) ...[
            const SizedBox(height: AppSpacing.spacingM),
            _StripeActionButton(
              key: const Key('seller_stripe_open_button'),
              isPrimary: true,
              onPressed: _isOpeningOnboarding || _isLoadingStatus
                  ? null
                  : _openStripeOnboarding,
              label: _isOpeningOnboarding
                  ? (isItalian ? 'Apertura in corso...' : 'Opening...')
                  : stripeHasAccount
                  ? (isItalian ? 'Gestisci verifica Stripe' : 'Manage Stripe verification')
                  : (isItalian ? 'Completa registrazione' : 'Complete registration'),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _StripeActionButton(
              key: const Key('seller_stripe_refresh_button'),
              isPrimary: false,
              onPressed: _isRefreshing || _isLoadingStatus
                  ? null
                  : _refreshStripeStatus,
              label: _isRefreshing
                  ? (isItalian ? 'Verifica in corso...' : 'Checking...')
                  : (isItalian ? 'Aggiorna stato' : 'Refresh status'),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.spacingM),
            _SellerDashboardSummaryCard(
              summaryAsync: dashboardAsync,
              isItalian: isItalian,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _loadInitialStatus() async {
    final callbackHint = widget.stripeCallbackHint?.trim().toLowerCase();
    try {
      final cachedStatus = await ref
          .read(currentSellerStripeStatusProvider.future);
      if (!mounted) return;
      setState(() {
        if (cachedStatus.isReady) {
          _stripeStatus = cachedStatus;
          _hasResolvedStripeStatus = true;
        } else {
          _stripeStatus = null;
          _hasResolvedStripeStatus = false;
        }
        _errorMessage = null;
      });
    } catch (_) {
      // Best effort: the explicit refresh path below will surface a user-facing error if needed.
      if (mounted) {
        setState(() {
          _hasResolvedStripeStatus = true;
        });
      }
    }

    if (callbackHint == 'return') {
      await _refreshStripeStatus(showVerifyingMessage: true);
      return;
    }
    if (callbackHint == 'refresh') {
      setState(() {
        _errorMessage = _text(
          context,
          it: 'Il link Stripe era scaduto. Ne stiamo richiedendo uno nuovo...',
          en: 'The Stripe link expired. We are requesting a new one...',
        );
      });
      await _openStripeOnboarding();
      return;
    }
    await _refreshStripeStatus();
  }

  Future<void> _openStripeOnboarding() async {
    setState(() {
      _isOpeningOnboarding = true;
      _errorMessage = null;
    });

    try {
      final link = await ref
          .read(sellerStripeOnboardingServiceProvider)
          .createOnboardingLink();
      final opened = await ref
          .read(sellerStripeOnboardingLauncherServiceProvider)
          .openOnboarding(link.url);

      if (!mounted) return;

      if (!opened) {
        setState(() {
          _errorMessage = _text(
            context,
            it: 'Non siamo riusciti ad aprire il browser di sistema. Riprova.',
            en: 'We could not open the system browser.',
          );
        });
        return;
      }

      setState(() {
        _awaitingExternalReturn = true;
      });
    } on SellerStripeOnboardingServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForFailure(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isOpeningOnboarding = false;
        });
      }
    }
  }

  Future<void> _refreshStripeStatus({bool showVerifyingMessage = false}) async {
    String? snackMessage;
    Color? snackIconColor;
    IconData? snackIcon;

      setState(() {
        _isLoadingStatus = _stripeStatus == null;
        _isRefreshing = _stripeStatus != null;
        _errorMessage = showVerifyingMessage
          ? _text(
              context,
              it: 'Stiamo verificando il tuo account Stripe...',
              en: 'We are verifying your Stripe account...',
            )
          : null;
    });

    try {
      final status = await ref
          .read(sellerStripeOnboardingServiceProvider)
          .refreshSellerStripeStatus();
      if (!mounted) return;

      setState(() {
        _stripeStatus = status;
        _hasResolvedStripeStatus = true;
        _errorMessage = null;
      });

      snackMessage = _text(
        context,
        it: 'Stato aggiornato',
        en: 'Status updated',
      );
      snackIcon = Icons.check_circle_rounded;
      snackIconColor = const Color(0xFF24A148);

      ref.invalidate(currentSellerPublishAccessProvider);
      ref.invalidate(currentSellerStripeStatusProvider);
    } on SellerStripeOnboardingServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForFailure(error);
        _hasResolvedStripeStatus = true;
      });
      snackMessage = _text(
        context,
        it: 'Impossibile aggiornare',
        en: 'Unable to update',
      );
      snackIcon = Icons.close_rounded;
      snackIconColor = AppColors.error;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
          _isRefreshing = false;
        });

        if (snackMessage != null && snackIcon != null && snackIconColor != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.black,
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  0,
                  AppSpacing.spacingM,
                  AppSpacing.spacingL,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                content: Row(
                  children: [
                    Icon(snackIcon, color: snackIconColor, size: 18),
                    const SizedBox(width: AppSpacing.spacingS),
                    Expanded(
                      child: Text(
                        snackMessage,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
      }
    }
  }

  String _messageForFailure(SellerStripeOnboardingServiceException error) {
    return switch (error.failure) {
      SellerStripeOnboardingFailure.unauthenticated => _text(
          context,
          it: "La sessione non e' piu valida. Effettua di nuovo l'accesso.",
          en: 'Your session is no longer valid. Please sign in again.',
        ),
      SellerStripeOnboardingFailure.notAllowed => _text(
          context,
          it: 'La richiesta venditore deve essere approvata prima di configurare Stripe.',
          en: 'The seller request must be approved before configuring Stripe.',
        ),
      SellerStripeOnboardingFailure.network => _text(
          context,
          it: error.backendMessage ??
              "Non riusciamo a verificare lo stato ora. Riprova.",
          en: error.backendMessage ??
              'We cannot verify the status right now. Please try again.',
        ),
      SellerStripeOnboardingFailure.unknown => error.backendMessage ??
          _text(
            context,
            it: "Si e' verificato un errore imprevisto durante il flusso Stripe.",
            en: 'An unexpected error occurred during the Stripe flow.',
          ),
    };
  }
}

class _CenteredMessageCard extends StatelessWidget {
  const _CenteredMessageCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.black10),
            boxShadow: AppShadows.authField,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionTitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black80,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementsNoticeCard extends StatelessWidget {
  const _RequirementsNoticeCard({required this.isItalian});

  final bool isItalian;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.black50),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(
                isItalian
                    ? 'Stripe potrebbe richiedere altre informazioni.'
                    : 'Stripe may require a few more details.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StripeTone { neutral, warning, success }

class _StripeStatusHeaderCard extends StatelessWidget {
  const _StripeStatusHeaderCard({
    required this.title,
    required this.statusTitle,
    required this.description,
    required this.statusTone,
    required this.isItalian,
    this.accountId,
  });

  final String title;
  final String statusTitle;
  final String description;
  final _StripeTone statusTone;
  final bool isItalian;
  final String? accountId;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (statusTone) {
      _StripeTone.warning => AppColors.accent,
      _StripeTone.neutral => const Color(0xFF24A148),
      _StripeTone.success => const Color(0xFF24A148),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.black50,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  statusTone == _StripeTone.warning
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_rounded,
                  color: statusColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black80,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.spacingS,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusTone == _StripeTone.warning
                            ? (isItalian ? 'Da completare' : 'Incomplete')
                            : (isItalian ? 'Attivo' : 'Active'),
                        style: AppTextStyles.micro.copyWith(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (accountId case final value?) ...[
            const SizedBox(height: AppSpacing.spacingM),
            const Divider(height: 1, color: Color.fromARGB(43, 21, 22, 24)),
            const SizedBox(height: AppSpacing.spacingM),
            Row(
              children: [
                Text(
                  'Account ID',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.black50,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black80,
                      fontSize: 13,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacingXS),
                const Icon(Icons.copy_rounded, size: 18, color: AppColors.black50),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SellerDashboardSummaryCard extends StatelessWidget {
  const _SellerDashboardSummaryCard({
    required this.summaryAsync,
    required this.isItalian,
  });

  final AsyncValue<SellerDashboardSummary> summaryAsync;
  final bool isItalian;

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      loading: () => const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _CenteredMessageCard(
        title: isItalian ? 'Dashboard non disponibile' : 'Dashboard unavailable',
        description: isItalian
            ? 'Non siamo riusciti a caricare il riepilogo del seller.'
            : 'We could not load the seller summary.',
      ),
      data: (summary) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MiniMetricCard(
              title: isItalian ? 'Guadagno completato' : 'Completed earnings',
              value: formatEuro(summary.completedEarnings),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _MiniMetricGrid(
              primaryTitle: isItalian ? 'In attesa' : 'Pending',
              primaryValue: formatEuro(summary.pendingEarnings),
              secondaryTitle: isItalian ? 'Ordini in corso' : 'Orders in progress',
              secondaryValue: summary.inProgressOrdersCount.toString(),
              tertiaryTitle: isItalian ? 'Ordini completati' : 'Completed orders',
              tertiaryValue: summary.completedOrdersCount.toString(),
              quaternaryTitle: isItalian ? 'Rating medio' : 'Average rating',
              quaternaryValue: summary.reviewCount == 0
                  ? '--'
                  : summary.averageRating.toStringAsFixed(1),
            ),
          ],
        );
      },
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.micro.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              value,
              style: AppTextStyles.authScreenTitle.copyWith(
                color: AppColors.white,
                fontSize: 32,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniMetricGrid extends StatelessWidget {
  const _MiniMetricGrid({
    required this.primaryTitle,
    required this.primaryValue,
    required this.secondaryTitle,
    required this.secondaryValue,
    required this.tertiaryTitle,
    required this.tertiaryValue,
    required this.quaternaryTitle,
    required this.quaternaryValue,
  });

  final String primaryTitle;
  final String primaryValue;
  final String secondaryTitle;
  final String secondaryValue;
  final String tertiaryTitle;
  final String tertiaryValue;
  final String quaternaryTitle;
  final String quaternaryValue;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.spacingS,
      crossAxisSpacing: AppSpacing.spacingS,
      childAspectRatio: 1.9,
      children: [
        _TinyMetricTile(title: primaryTitle, value: primaryValue),
        _TinyMetricTile(title: secondaryTitle, value: secondaryValue),
        _TinyMetricTile(title: tertiaryTitle, value: tertiaryValue),
        _TinyMetricTile(title: quaternaryTitle, value: quaternaryValue),
      ],
    );
  }
}

class _TinyMetricTile extends StatelessWidget {
  const _TinyMetricTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: AppTextStyles.micro.copyWith(color: AppColors.black50),
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              value,
              style: AppTextStyles.sectionTitle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripeActionButton extends StatelessWidget {
  const _StripeActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isPrimary
          ? AuthPrimaryButton(
              label: label,
              onPressed: onPressed,
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.black,
                side: const BorderSide(color: AppColors.black10),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.authBorderRadius,
                ),
                textStyle: AppTextStyles.buttonText,
              ),
              child: Text(label),
            ),
    );
  }
}

String _text(BuildContext context, {required String it, required String en}) {
  return Localizations.localeOf(context).languageCode == 'it' ? it : en;
}

