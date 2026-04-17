import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/auth_callback_context.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/create_password_screen.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    required this.callbackContext,
    super.key,
  });

  final AuthCallbackContext callbackContext;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

enum _RecoverySessionStatus {
  checking,
  ready,
  invalid,
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  static const _sessionResolutionTimeout = Duration(seconds: 4);

  _RecoverySessionStatus _status = _RecoverySessionStatus.checking;
  StreamSubscription<AuthState>? _authStateSub;
  Timer? _resolutionTimeout;

  @override
  void initState() {
    super.initState();
    _startRecoverySessionCheck();
  }

  @override
  void dispose() {
    unawaited(_authStateSub?.cancel());
    _resolutionTimeout?.cancel();
    super.dispose();
  }

  void _startRecoverySessionCheck() {
    if (!widget.callbackContext.hasValidRecoveryContext) {
      _setStatus(_RecoverySessionStatus.invalid);
      return;
    }

    if (_hasUsableRecoverySession()) {
      _setStatus(_RecoverySessionStatus.ready);
      return;
    }

    _authStateSub = ref.read(supabaseClientProvider).auth.onAuthStateChange.listen((
      _,
    ) {
      if (_hasUsableRecoverySession()) {
        _setStatus(_RecoverySessionStatus.ready);
      }
    });

    _resolutionTimeout = Timer(_sessionResolutionTimeout, () {
      if (!_hasUsableRecoverySession()) {
        _setStatus(_RecoverySessionStatus.invalid);
      }
    });
  }

  bool _hasUsableRecoverySession() {
    final session = ref.read(supabaseClientProvider).auth.currentSession;
    if (session == null) return false;

    final accessToken = session.accessToken.trim();
    final userId = session.user.id.trim();
    return accessToken.isNotEmpty && userId.isNotEmpty;
  }

  void _setStatus(_RecoverySessionStatus nextStatus) {
    if (!mounted || _status == nextStatus) return;

    if (nextStatus != _RecoverySessionStatus.checking) {
      _resolutionTimeout?.cancel();
      _resolutionTimeout = null;
      unawaited(_authStateSub?.cancel());
      _authStateSub = null;
    }

    setState(() {
      _status = nextStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      _RecoverySessionStatus.ready => const CreatePasswordScreen(),
      _RecoverySessionStatus.checking => const _RecoverySessionCheckingView(),
      _RecoverySessionStatus.invalid => const _RecoverySessionInvalidView(),
    };
  }
}

class _RecoverySessionCheckingView extends StatelessWidget {
  const _RecoverySessionCheckingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      children: [
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: AppSpacing.authGroupGap),
        AuthTextBlock(
          child: Text(
            l10n.authResetPasswordTitle,
            style: AppTextStyles.authScreenTitle,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthTextBlock(
          child: Text(
            l10n.authResetPasswordSubtitle,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _RecoverySessionInvalidView extends StatelessWidget {
  const _RecoverySessionInvalidView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      children: [
        AuthTextBlock(
          child: Text(
            l10n.authResetPasswordTitle,
            style: AppTextStyles.authScreenTitle,
          ),
        ),
        const SizedBox(height: AppSpacing.authFieldGap),
        AuthErrorMessage(
          message: l10n.authResetPasswordInvalidRecoverySession,
        ),
        const SizedBox(height: AppSpacing.authGroupGap),
        AuthPrimaryButton(
          label: l10n.authForgotPasswordButton,
          onPressed: () => context.go(AppRoutes.forgotPassword),
        ),
      ],
    );
  }
}
