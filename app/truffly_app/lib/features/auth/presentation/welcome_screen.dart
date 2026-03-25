import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/presentation/auth_failure_message_mapper.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_google_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      scrollable: false,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/auth/welcome_screen.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AuthTextBlock(
                alignment: Alignment.centerLeft,
                maxWidth: 360,
                child: Text(
                  '${l10n.authWelcomeTitleLeading} ${l10n.authWelcomeTitleAccent}',
                  textAlign: TextAlign.left,
                  style: AppTextStyles.authHeroTitle.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPrimaryButton(
                    label: l10n.authWelcomeCreateAccountButton,
                    onPressed: () => context.go(AppRoutes.signup),
                  ),
                  const SizedBox(height: AppSpacing.authFieldGap),
                  AuthGoogleButton(
                    label: l10n.authWelcomeGoogleButton,
                    onPressed: () {},
                    enabled: true,
                  ),
                  const SizedBox(height: AppSpacing.authFieldGap),
                  AuthSecondaryButton(
                    label: l10n.authWelcomeLoginButton,
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.spacingM),
                    const _DebugQuickAccessCard(),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DebugQuickAccessCard extends ConsumerStatefulWidget {
  const _DebugQuickAccessCard();

  @override
  ConsumerState<_DebugQuickAccessCard> createState() =>
      _DebugQuickAccessCardState();
}

class _DebugQuickAccessCardState extends ConsumerState<_DebugQuickAccessCard> {
  String? _errorMessage;
  String? _pendingKey;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isItalian ? 'Accesso rapido debug' : 'Debug quick access',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              isItalian
                  ? 'Usa un profilo seedato locale e salta il flusso di creazione account.'
                  : 'Use a seeded local profile and skip the account setup flow.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              label: isItalian ? 'Entra come buyer test' : 'Continue as test buyer',
              isLoading: _pendingKey == _DevQuickProfile.buyer.key,
              enabled: _pendingKey == null,
              onPressed: () => _signIn(_DevQuickProfile.buyer),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            AuthSecondaryButton(
              label: isItalian ? 'Entra come seller test' : 'Continue as test seller',
              onPressed: _pendingKey == null
                  ? () => _signIn(_DevQuickProfile.seller)
                  : null,
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(
              isItalian
                  ? 'Seed locale: buyer@test.com e seller1@test.com'
                  : 'Local seed: buyer@test.com and seller1@test.com',
              style: AppTextStyles.micro,
            ),
            AuthErrorMessage(message: _errorMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(_DevQuickProfile profile) async {
    if (_pendingKey != null) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _pendingKey = profile.key;
      _errorMessage = null;
    });

    final result = await ref.read(authNotifierProvider.notifier).signIn(
          email: profile.email,
          password: profile.password,
        );

    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _errorMessage = loginFailureMessage(result.failureOrNull!, l10n);
      });
    }

    setState(() {
      _pendingKey = null;
    });
  }
}

final class _DevQuickProfile {
  const _DevQuickProfile._({
    required this.key,
    required this.email,
    required this.password,
  });

  static const buyer = _DevQuickProfile._(
    key: 'buyer',
    email: 'buyer@test.com',
    password: 'DevPass123!',
  );

  static const seller = _DevQuickProfile._(
    key: 'seller',
    email: 'seller1@test.com',
    password: 'DevPass123!',
  );

  final String key;
  final String email;
  final String password;
}
