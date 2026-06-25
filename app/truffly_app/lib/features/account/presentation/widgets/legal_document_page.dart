import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_subpage_scaffold.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final blocks = content
        .split('\n\n')
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .toList(growable: false);

    return AccountSubpageScaffold(
      title: title,
      body: SelectionArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingL,
          ),
          itemCount: blocks.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.spacingS),
          itemBuilder: (context, index) {
            final block = blocks[index];
            final isHeading = _isHeading(block);

            return isHeading
                ? Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 0 : AppSpacing.spacingXS,
                    ),
                    child: Text(
                      block,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.black10),
                      boxShadow: AppShadows.authField,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.spacingM),
                      child: Text(
                        block,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.black80,
                          height: 1.5,
                        ),
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  bool _isHeading(String block) {
    if (block.contains('\n')) return false;
    return RegExp(r'^\d+\.\s').hasMatch(block) ||
        block == 'Platform operator' ||
        block == 'Nature of the service' ||
        block == 'Seller responsibility' ||
        block == 'Buyer responsibility' ||
        block == 'Payments' ||
        block == 'Consumer information' ||
        block == 'Account deletion and data requests' ||
        block == 'Support' ||
        block == 'Legal notices' ||
        block == 'Governing law' ||
        block == 'Gestore della piattaforma' ||
        block == 'Natura del servizio' ||
        block == 'Responsabilità del venditore' ||
        block == 'Responsabilità dell’acquirente' ||
        block == 'Pagamenti' ||
        block == 'Informazioni per i consumatori' ||
        block == 'Cancellazione dell’account e richieste sui dati' ||
        block == 'Assistenza' ||
        block == 'Note legali' ||
        block == 'Legge applicabile';
  }
}
