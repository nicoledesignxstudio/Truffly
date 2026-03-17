import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/application/auth_validators.dart';
import 'package:truffly_app/features/auth/domain/auth_failure.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
      _infoMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    final result = await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
    if (!mounted) return;

    setState(() {
      if (result.isSuccess) {
        _infoMessage = l10n.authForgotPasswordSuccess;
      } else {
        _errorMessage = _failureMessage(result.failureOrNull!, l10n);
      }
      _isSubmitting = false;
    });
  }

  String _failureMessage(AuthFailure failure, AppLocalizations l10n) {
    return switch (failure) {
      NetworkErrorFailure() => l10n.authErrorNetwork,
      TimeoutFailure() => l10n.authErrorTimeout,
      _ => l10n.authForgotPasswordErrorFallback,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      children: [
        AuthBackButton(
          onPressed: () => context.go(AppRoutes.login),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        AuthTextBlock(
          child: Text(
            l10n.authForgotPasswordTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthTextBlock(
          child: Text(
            l10n.authForgotPasswordSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _emailController,
                labelText: l10n.authEmailLabel,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                validator: (value) => AuthValidators.validateEmail(value, l10n),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              if (_infoMessage != null) ...[
                Text(
                  _infoMessage!,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: AppSpacing.authFieldGap),
              ],
              AuthErrorMessage(message: _errorMessage),
              const SizedBox(height: AppSpacing.authGroupGap),
              AuthPrimaryButton(
                label: l10n.authForgotPasswordButton,
                isLoading: _isSubmitting,
                enabled: !_isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
