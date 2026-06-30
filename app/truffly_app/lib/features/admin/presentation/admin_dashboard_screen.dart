import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';
import 'package:truffly_app/features/admin/data/admin_application_dto.dart';
import 'package:truffly_app/features/admin/data/admin_repository.dart';
import 'package:truffly_app/features/admin/presentation/admin_access_denied_screen.dart';
import 'package:truffly_app/features/admin/presentation/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(currentUserIsAdminProvider)) {
      return const AdminAccessDeniedScreen();
    }

    final applicationsAsync = ref.watch(adminSellerApplicationsProvider);
    return AccountSubpageScaffold(
      title: _text(context, it: 'Admin Dashboard', en: 'Admin Dashboard'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminSellerApplicationsProvider);
          await ref.read(adminSellerApplicationsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingL,
          ),
          children: [
            applicationsAsync.when(
              data: (applications) {
                if (applications.isEmpty) {
                  return _AdminMessageState(
                    icon: Icons.inbox_outlined,
                    message: _text(
                      context,
                      it: 'Nessuna richiesta in attesa',
                      en: 'No pending requests',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final application in applications) ...[
                      _ApplicationCard(application: application),
                      const SizedBox(height: AppSpacing.spacingS),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _AdminMessageState(
                icon: Icons.error_outline_rounded,
                message: _friendlyError(context, error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application});

  final AdminSellerApplication application;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black20),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    application.displayName,
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 17),
                  ),
                ),
                _PendingBadge(
                  label: _text(context, it: 'In attesa', en: 'Pending'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _InfoLine(
              icon: Icons.location_on_outlined,
              text: _valueOrDash(application.region),
            ),
            _InfoLine(
              icon: Icons.schedule_outlined,
              text: _formatDate(context, application.uploadedAt),
            ),
            const SizedBox(height: AppSpacing.spacingM),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: AppColors.white,
                ),
                onPressed: () => context.push(
                  AppRoutes.adminSellerApplicationPath(application.userId),
                ),
                child: Text(
                  _text(context, it: 'Apri richiesta', en: 'Open request'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.black50),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.black10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(label, style: AppTextStyles.micro),
      ),
    );
  }
}

class _AdminMessageState extends StatelessWidget {
  const _AdminMessageState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(icon, color: AppColors.black50, size: 40),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        ],
      ),
    );
  }
}

String _friendlyError(BuildContext context, Object error) {
  if (error is AdminRepositoryException &&
      error.failure == AdminRepositoryFailure.forbidden) {
    return _text(
      context,
      it: 'Non hai accesso alla dashboard admin.',
      en: 'You do not have access to the admin dashboard.',
    );
  }
  return _text(
    context,
    it: 'Impossibile caricare le richieste in questo momento.',
    en: 'Unable to load requests right now.',
  );
}

String _formatDate(BuildContext context, DateTime? value) {
  if (value == null) return '-';
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
}

String _valueOrDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}

bool _isItalian(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'it';
}

String _text(BuildContext context, {required String it, required String en}) {
  return _isItalian(context) ? it : en;
}
