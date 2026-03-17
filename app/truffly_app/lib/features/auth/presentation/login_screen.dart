import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/application/auth_validators.dart';
import 'package:truffly_app/features/auth/presentation/auth_failure_message_mapper.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final result = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _errorMessage = loginFailureMessage(result.failureOrNull!, l10n);
      });
    }

    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      children: [
        AuthBackButton(
          onPressed: () => context.go(AppRoutes.welcome),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        AuthTextBlock(
          child: Text(
            l10n.authLoginTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthTextBlock(
          child: Text(
            l10n.authLoginSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black80),
          ),
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthTextField(
                  controller: _emailController,
                  labelText: l10n.authEmailLabel,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  prefixIcon: const Icon(Icons.mail_outline_rounded, size: 20),
                  validator: (value) => AuthValidators.validateEmail(value, l10n),
                ),
                const SizedBox(height: AppSpacing.authFieldGap),
                AuthPasswordField(
                  controller: _passwordController,
                  labelText: l10n.authPasswordLabel,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) =>
                      AuthValidators.validatePassword(value, l10n),
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.authFieldGap),
                AuthErrorMessage(message: _errorMessage),
                const SizedBox(height: AppSpacing.authGroupGap),
                AuthPrimaryButton(
                  label: l10n.authLoginButton,
                  isLoading: _isSubmitting,
                  enabled: !_isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed:
                _isSubmitting ? null : () => context.go(AppRoutes.forgotPassword),
            child: Text(l10n.authForgotPasswordLink),
          ),
        ),
      ],
    );
  }
}
