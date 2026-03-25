import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
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
  });

  final String? prefilledEmail;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool _isResendingVerification = false;
  String? _errorMessage;
  String? _infoMessage;

  void _goToLogin() {
    if (_isResendingVerification) return;
    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });
    context.go(AppRoutes.login);
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

    final result = await ref
        .read(authNotifierProvider.notifier)
        .resendVerificationEmail(email: email);
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

    return AuthScaffold(
      children: [
        AuthTextBlock(
          child: Text(
            l10n.authVerifyEmailTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthTextBlock(
          child: Text(
            l10n.authVerifyEmailSubtitle,
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
          Text(
            _infoMessage!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
          ),
          const SizedBox(height: AppSpacing.authFieldGap),
        ],
        AuthErrorMessage(message: _errorMessage),
        if (_errorMessage != null) const SizedBox(height: AppSpacing.authFieldGap),
        AuthPrimaryButton(
          label: l10n.authVerifyEmailResendButton,
          isLoading: _isResendingVerification,
          enabled: !isBusy,
          onPressed: _resendVerification,
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthSecondaryButton(
          label: l10n.authVerifyEmailRecheckButton,
          enabled: !isBusy,
          onPressed: _goToLogin,
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
}
