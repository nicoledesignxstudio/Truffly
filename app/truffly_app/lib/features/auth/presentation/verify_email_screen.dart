import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({
    super.key,
    this.prefilledEmail,
    this.manualVerificationFlow = false,
  });

  final String? prefilledEmail;
  final bool manualVerificationFlow;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResendingVerification = false;
  String? _errorMessage;
  String? _infoMessage;

  Future<void> _recheckVerificationStatus() async {
    if (_isResendingVerification) return;

    if (!widget.manualVerificationFlow) {
      context.go(AppRoutes.login);
      return;
    }

    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });

    final expectedEmail = _resolveEmail(ref.read(authNotifierProvider));
    if (expectedEmail.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.authVerifyEmailMissingEmail;
      });
      return;
    }

    final result = await ref
        .read(authNotifierProvider.notifier)
        .completeEmailChange(expectedEmail: expectedEmail);
    if (!mounted) return;

    if (result.isSuccess) {
      context.go(AppRoutes.login);
      return;
    }

    setState(() {
      _errorMessage = _failureMessage(
        result.failureOrNull!,
        AppLocalizations.of(context)!,
      );
    });
  }

  Future<void> _resendVerification() async {
    if (_isResendingVerification) return;

    final l10n = AppLocalizations.of(context)!;
    final authState = ref.read(authNotifierProvider);
    final email = _resolveEmail(authState);
    if (email.isEmpty) {
      setState(() {
        _errorMessage = l10n.authVerifyEmailMissingEmail;
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _infoMessage = null;
      _isResendingVerification = true;
    });

    final notifier = ref.read(authNotifierProvider.notifier);
    final result = widget.manualVerificationFlow
        ? await notifier.resendEmailChangeVerification(email: email)
        : await notifier.resendVerificationEmail(email: email);
    if (!mounted) return;

    setState(() {
      if (result.isSuccess) {
        _infoMessage = l10n.authVerifyEmailResendSuccess;
      } else {
        _errorMessage = _failureMessage(result.failureOrNull!, l10n);
      }
      _isResendingVerification = false;
    });
  }

  String _failureMessage(AuthFailure failure, AppLocalizations l10n) {
    return switch (failure) {
      UnauthenticatedFailure() => l10n.authVerifyEmailSessionExpired,
      EmailNotVerifiedFailure() => l10n.authVerifyEmailNotYetVerified,
      EmailResendRateLimitedFailure() => l10n.authErrorEmailResendRateLimited,
      EmailDeliveryRestrictedFailure() => l10n.authErrorEmailDeliveryRestricted,
      NetworkErrorFailure() => l10n.authErrorNetwork,
      TimeoutFailure() => l10n.authErrorTimeout,
      UnknownAuthFailure() => l10n.authErrorUnknown,
      _ => l10n.authErrorUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final resolvedEmail = _resolveEmail(authState);
    final userEmail = resolvedEmail.isEmpty ? null : resolvedEmail;
    final isBusy = _isResendingVerification;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (!mounted) return;
      if (next is AuthAuthenticatedOnboardingRequired) {
        context.go(AppRoutes.onboarding);
      } else if (next is AuthAuthenticatedReady &&
          !widget.manualVerificationFlow) {
        context.go(AppRoutes.home);
      }
    });

    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        20,
        AppSpacing.screenHorizontal,
        0,
      ),
      children: [
        AuthBackButton(
          onPressed: () => _goBackToEmailEdit(context, resolvedEmail),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        AuthTextBlock(
          child: Text(
            l10n.authVerifyEmailTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authTitleSubtitleGap),
        AuthTextBlock(
          child: Text(
            widget.manualVerificationFlow
                ? l10n.accountDetailsEmailVerificationSent
                : l10n.authVerifyEmailSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
        ),
        if (userEmail != null && userEmail.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.spacingS),
          AuthTextBlock(
            child: Text(
              '${l10n.authVerifyEmailCurrentEmail}: $userEmail',
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.authGroupGap),
        Center(
          child: SizedBox(
            width: 90,
            height: 90,
            child: Image.asset(
              'assets/images/auth/email_verification.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        if (_infoMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              borderRadius: AppRadii.dialogBorderRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 18,
                    color: AppColors.black80,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _infoMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.black80,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.authFieldGap),
        ],
        AuthErrorMessage(message: _errorMessage),
        if (_errorMessage != null)
          const SizedBox(height: AppSpacing.authFieldGap),
        AuthPrimaryButton(
          label: l10n.authVerifyEmailResendButton,
          isLoading: _isResendingVerification,
          enabled: !isBusy,
          onPressed: _resendVerification,
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthSecondaryButton(
          label: widget.manualVerificationFlow
              ? l10n.authVerifyEmailRecheckButton
              : l10n.authForgotPasswordBackToLogin,
          enabled: !isBusy,
          onPressed: _recheckVerificationStatus,
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: Text(
            l10n.authVerifyEmailSpamHint,
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  String _resolveEmail(AuthState authState) {
    if (authState is AuthAuthenticatedUnverified) {
      return authState.email.trim();
    }

    final prefilledEmail = widget.prefilledEmail?.trim();
    if (prefilledEmail != null && prefilledEmail.isNotEmpty) {
      return prefilledEmail;
    }

    return '';
  }

  void _goBackToEmailEdit(BuildContext context, String email) {
    if (widget.manualVerificationFlow) {
      context.go(AppRoutes.accountDetails);
      return;
    }

    if (email.trim().isNotEmpty) {
      context.go(AppRoutes.signupWithPrefill(email));
      return;
    }

    context.go(AppRoutes.signup);
  }
}
