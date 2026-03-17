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
import 'package:truffly_app/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_success_dialog.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;
    final result = await ref.read(authNotifierProvider.notifier).updatePassword(
          newPassword: _newPasswordController.text.trim(),
        );
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isSubmitting = false);
      await AuthSuccessDialog.show(
        context: context,
        title: l10n.authResetPasswordSuccessTitle,
        message: l10n.authResetPasswordSuccessMessage,
        buttonLabel: l10n.authResetPasswordSuccessButton,
        onPressed: () => context.go(AppRoutes.login),
      );
      return;
    }

    setState(() {
      _errorMessage = _failureMessage(result.failureOrNull!, l10n);
      _isSubmitting = false;
    });
  }

  String _failureMessage(AuthFailure failure, AppLocalizations l10n) {
    return switch (failure) {
      ResetLinkInvalidFailure() => l10n.authResetPasswordInvalidLink,
      UnauthenticatedFailure() => l10n.authResetPasswordInvalidRecoverySession,
      NetworkErrorFailure() => l10n.authErrorNetwork,
      TimeoutFailure() => l10n.authErrorTimeout,
      _ => l10n.authResetPasswordErrorFallback,
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
            l10n.authResetPasswordTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthTextBlock(
          child: Text(
            l10n.authResetPasswordSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthPasswordField(
                controller: _newPasswordController,
                labelText: l10n.authResetPasswordNewPasswordLabel,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => AuthValidators.validatePassword(value, l10n),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              AuthPasswordField(
                controller: _confirmPasswordController,
                labelText: l10n.authConfirmPasswordLabel,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => AuthValidators.validateConfirmPassword(
                  value,
                  _newPasswordController.text.trim(),
                  l10n,
                ),
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              AuthErrorMessage(message: _errorMessage),
              const SizedBox(height: AppSpacing.authGroupGap),
              AuthPrimaryButton(
                label: l10n.authResetPasswordButton,
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
