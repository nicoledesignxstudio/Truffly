import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';

class AdminAccessDeniedScreen extends StatelessWidget {
  const AdminAccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountSubpageScaffold(
      title: _text(context, it: 'Accesso negato', en: 'Access denied'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.black50,
                size: 42,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                _text(
                  context,
                  it: 'Questa sezione e riservata agli admin.',
                  en: 'This section is reserved for admins.',
                ),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              FilledButton(
                onPressed: () => context.go(AppRoutes.account),
                child: Text(
                  _text(
                    context,
                    it: 'Torna all account',
                    en: 'Back to account',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isItalian(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'it';
}

String _text(BuildContext context, {required String it, required String en}) {
  return _isItalian(context) ? it : en;
}
