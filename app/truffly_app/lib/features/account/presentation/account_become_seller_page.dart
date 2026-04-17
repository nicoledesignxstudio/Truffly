import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/data/seller_stripe_onboarding_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_providers.dart';

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
    final title = isItalian ? 'Diventa venditore' : 'Become a seller';

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
          title,
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
    if (!profile.isSeller) {
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
            ? "La tua richiesta seller e' ancora in revisione. Lo step Stripe si sblocca solo dopo approvazione."
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

    return RefreshIndicator(
      onRefresh: _refreshStripeStatus,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        children: [
          _CenteredMessageCard(
            title: isItalian ? 'Stripe Express onboarding' : 'Stripe Express onboarding',
            description: isItalian
                ? 'Apri il flusso Stripe nel browser di sistema, completa i dati richiesti e torna in app. Truffly verifica sempre lo stato lato backend prima di sbloccare la pubblicazione.'
                : 'Open the Stripe flow in the system browser, complete the required data, and return to the app. Truffly always verifies the status server-side before unlocking publishing.',
          ),
          const SizedBox(height: AppSpacing.spacingM),
          _buildStatusCard(isItalian: isItalian),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.spacingM),
            _InlineErrorBanner(message: _errorMessage!),
          ],
          const SizedBox(height: AppSpacing.spacingM),
          FilledButton(
            key: const Key('seller_stripe_open_button'),
            onPressed: _isOpeningOnboarding || _isLoadingStatus
                ? null
                : _openStripeOnboarding,
            child: Text(
              _isOpeningOnboarding
                  ? (isItalian ? 'Apertura in corso...' : 'Opening...')
                  : (isItalian ? 'Apri Stripe' : 'Open Stripe'),
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          OutlinedButton(
            key: const Key('seller_stripe_refresh_button'),
            onPressed: _isRefreshing || _isLoadingStatus
                ? null
                : _refreshStripeStatus,
            child: Text(
              _isRefreshing
                  ? (isItalian ? 'Verifica in corso...' : 'Checking...')
                  : (isItalian ? 'Verifica stato' : 'Refresh status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({required bool isItalian}) {
    final status = _stripeStatus;
    final title = switch (status?.readiness) {
      SellerStripeReadinessStatus.notConnected => isItalian
          ? 'Non collegato'
          : 'Not connected',
      SellerStripeReadinessStatus.onboardingInProgress => isItalian
          ? 'Onboarding in corso'
          : 'Onboarding in progress',
      SellerStripeReadinessStatus.verificationPending => isItalian
          ? 'Verifica in attesa'
          : 'Verification pending',
      SellerStripeReadinessStatus.ready => isItalian ? 'Pronto' : 'Ready',
      null => isItalian ? 'Stato Stripe' : 'Stripe status',
    };

    final description = switch (status?.readiness) {
      SellerStripeReadinessStatus.notConnected => isItalian
          ? 'Non esiste ancora un account Stripe collegato per il tuo profilo seller.'
          : 'No connected Stripe account exists yet for your seller profile.',
      SellerStripeReadinessStatus.onboardingInProgress => isItalian
          ? "L'account esiste, ma Stripe non ha ancora ricevuto tutti i dati richiesti."
          : 'The account exists, but Stripe has not received all the required data yet.',
      SellerStripeReadinessStatus.verificationPending => isItalian
          ? 'I dettagli sono stati inviati, ma Stripe non considera ancora il profilo pronto alla pubblicazione.'
          : 'Details were submitted, but Stripe does not consider the profile ready for publishing yet.',
      SellerStripeReadinessStatus.ready => isItalian
          ? 'Il seller risulta Stripe-ready. Il gate publish server-side puo ora confermare la pubblicazione.'
          : 'The seller is Stripe-ready. The server-side publish gate can now confirm publishing.',
      null when _isLoadingStatus || _isRefreshing => isItalian
          ? 'Stiamo caricando lo stato Stripe del seller.'
          : 'Loading the seller Stripe status.',
      null when _errorMessage != null => isItalian
          ? 'Non siamo riusciti a verificare lo stato Stripe del seller.'
          : 'We could not verify the seller Stripe status.',
      null => isItalian
          ? 'Lo stato Stripe del seller sara disponibile qui.'
          : 'The seller Stripe status will appear here.',
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
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
              description,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.black80,
              ),
            ),
            if (_isLoadingStatus || _isRefreshing) ...[
              const SizedBox(height: AppSpacing.spacingM),
              const LinearProgressIndicator(),
            ],
            if (_stripeStatus?.accountId case final accountId?) ...[
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                'Stripe ID: $accountId',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialStatus() async {
    final callbackHint = widget.stripeCallbackHint?.trim().toLowerCase();
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
            it: 'Non siamo riusciti ad aprire il browser di sistema.',
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
        _errorMessage = null;
      });

      ref.invalidate(currentSellerPublishAccessProvider);
    } on SellerStripeOnboardingServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _messageForFailure(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatus = false;
          _isRefreshing = false;
        });
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
          it: 'Questo profilo seller non puo ancora usare Stripe onboarding.',
          en: 'This seller profile cannot use Stripe onboarding yet.',
        ),
      SellerStripeOnboardingFailure.network => _text(
          context,
          it: error.backendMessage ??
              "La verifica Stripe non e' disponibile in questo momento. Riprova tra poco.",
          en: error.backendMessage ??
              'Stripe verification is unavailable right now. Please try again soon.',
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

String _text(BuildContext context, {required String it, required String en}) {
  return Localizations.localeOf(context).languageCode == 'it' ? it : en;
}

