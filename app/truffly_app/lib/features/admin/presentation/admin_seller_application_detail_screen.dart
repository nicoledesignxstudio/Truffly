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
import 'package:url_launcher/url_launcher.dart';

class AdminSellerApplicationDetailScreen extends ConsumerStatefulWidget {
  const AdminSellerApplicationDetailScreen({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<AdminSellerApplicationDetailScreen> createState() =>
      _AdminSellerApplicationDetailScreenState();
}

class _AdminSellerApplicationDetailScreenState
    extends ConsumerState<AdminSellerApplicationDetailScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(currentUserIsAdminProvider)) {
      return const AdminAccessDeniedScreen();
    }

    final application = ref.watch(
      adminSellerApplicationProvider(widget.userId),
    );
    final documentsAsync = ref.watch(
      adminSellerApplicationDocumentsProvider(widget.userId),
    );

    return AccountSubpageScaffold(
      title: _text(context, it: 'Richiesta venditore', en: 'Seller request'),
      bottomNavigationBar: _ActionBar(
        isSubmitting: _isSubmitting,
        onApprove: () => _approve(application),
        onReject: () => _reject(application),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.spacingM,
          AppSpacing.spacingS,
          AppSpacing.spacingM,
          104,
        ),
        children: [
          _SellerDetailsCard(application: application, userId: widget.userId),
          const SizedBox(height: AppSpacing.spacingM),
          Text(
            _text(context, it: 'Documenti', en: 'Documents'),
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          documentsAsync.when(
            data: (documents) => Column(
              children: [
                _DocumentPreview(
                  title: _text(
                    context,
                    it: 'Documento identita',
                    en: 'Identity document',
                  ),
                  url: documents.identityDocumentUrl,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                _DocumentPreview(
                  title: _text(context, it: 'Tesserino', en: 'Tesserino'),
                  url: documents.tesserinoDocumentUrl,
                ),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 60),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _DetailMessage(
              icon: Icons.error_outline_rounded,
              message: _friendlyError(context, error),
              onRetry: () {
                ref.invalidate(
                  adminSellerApplicationDocumentsProvider(widget.userId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(AdminSellerApplication? application) async {
    if (_isSubmitting) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _text(context, it: 'Approvare venditore?', en: 'Approve seller?'),
        ),
        content: Text(
          _text(
            context,
            it: 'Vuoi approvare questo venditore?',
            en: 'Do you want to approve this seller?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(_text(context, it: 'Annulla', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(_text(context, it: 'Approva', en: 'Approve')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _runAction(
      () => ref.read(adminRepositoryProvider).approveSeller(widget.userId),
      successMessage: _text(
        context,
        it: 'Venditore approvato',
        en: 'Seller approved',
      ),
    );
  }

  Future<void> _reject(AdminSellerApplication? application) async {
    if (_isSubmitting) return;
    final reason = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      builder: (context) => _RejectSellerSheet(),
    );
    if (reason == null || !mounted) return;

    await _runAction(
      () => ref
          .read(adminRepositoryProvider)
          .rejectSeller(widget.userId, reason: reason),
      successMessage: _text(
        context,
        it: 'Richiesta rifiutata',
        en: 'Request rejected',
      ),
    );
  }

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await action();
      if (!mounted) return;
      ref.invalidate(adminSellerApplicationsProvider);
      ref.invalidate(adminSellerApplicationDocumentsProvider(widget.userId));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      context.go(AppRoutes.accountAdmin);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_friendlyError(context, error))));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}

class _SellerDetailsCard extends StatelessWidget {
  const _SellerDetailsCard({required this.application, required this.userId});

  final AdminSellerApplication? application;
  final String userId;

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
            Text(
              application?.displayName ??
                  _text(context, it: 'Seller', en: 'Seller'),
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            _DetailRow(label: 'ID', value: userId),
            _DetailRow(
              label: _text(context, it: 'Email', en: 'Email'),
              value: _valueOrDash(application?.email),
            ),
            _DetailRow(
              label: _text(context, it: 'Regione', en: 'Region'),
              value: _valueOrDash(application?.region),
            ),
            _DetailRow(
              label: _text(
                context,
                it: 'Numero tesserino',
                en: 'Tesserino number',
              ),
              value: _valueOrDash(application?.tesserinoNumber),
            ),
            _DetailRow(
              label: _text(context, it: 'Data invio', en: 'Submitted'),
              value: _formatDate(context, application?.uploadedAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 126,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black50),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

class _DocumentPreview extends StatelessWidget {
  const _DocumentPreview({required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.black20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingS),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
            const SizedBox(height: AppSpacing.spacingS),
            GestureDetector(
              onTap: () => _showDocumentViewer(context, url),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColoredBox(
                  color: AppColors.black10,
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, _, _) {
                        return _OpenDocumentFallback(url: url);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showDocumentViewer(BuildContext context, String url) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.spacingM),
        backgroundColor: AppColors.white,
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.spacingM),
                child: Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      errorBuilder: (context, _, _) {
                        return _OpenDocumentFallback(url: url);
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OpenDocumentFallback extends StatelessWidget {
  const _OpenDocumentFallback({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.black10,
      child: Center(
        child: FilledButton.icon(
          onPressed: () =>
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
          icon: const Icon(Icons.open_in_new_rounded, size: 18),
          label: Text(
            _text(context, it: 'Apri documento', en: 'Open document'),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.isSubmitting,
    required this.onApprove,
    required this.onReject,
  });

  final bool isSubmitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.black20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.black20),
                  ),
                  onPressed: isSubmitting ? null : onReject,
                  child: Text(_text(context, it: 'Rifiuta', en: 'Reject')),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.black,
                    foregroundColor: AppColors.white,
                  ),
                  onPressed: isSubmitting ? null : onApprove,
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_text(context, it: 'Approva', en: 'Approve')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectSellerSheet extends StatefulWidget {
  @override
  State<_RejectSellerSheet> createState() => _RejectSellerSheetState();
}

class _RejectSellerSheetState extends State<_RejectSellerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.spacingM,
        AppSpacing.spacingM,
        AppSpacing.spacingM,
        AppSpacing.spacingM + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _text(context, it: 'Rifiuta richiesta', en: 'Reject request'),
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 19),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _text(
                context,
                it: 'Motivo opzionale',
                en: 'Optional reason',
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.spacingM),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: Text(
                _text(context, it: 'Conferma rifiuto', en: 'Confirm rejection'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({
    required this.icon,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 54),
      child: Column(
        children: [
          Icon(icon, color: AppColors.black50, size: 38),
          const SizedBox(height: AppSpacing.spacingS),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.spacingS),
          TextButton(
            onPressed: onRetry,
            child: Text(_text(context, it: 'Riprova', en: 'Retry')),
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
      it: 'Non hai accesso a questa richiesta.',
      en: 'You do not have access to this request.',
    );
  }
  if (error is AdminRepositoryException &&
      error.failure == AdminRepositoryFailure.notFound) {
    return _text(
      context,
      it: 'Richiesta o documenti non disponibili.',
      en: 'Request or documents unavailable.',
    );
  }
  return _text(
    context,
    it: 'Operazione non riuscita. Riprova tra poco.',
    en: 'The operation failed. Please try again shortly.',
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
