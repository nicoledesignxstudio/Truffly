import 'package:flutter/material.dart';
import 'package:truffly_app/features/account/presentation/widgets/legal_document_page.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountTermsAndConditionsPage extends StatelessWidget {
  const AccountTermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LegalDocumentPage(
      title: l10n.accountTermsTitle,
      content: l10n.accountTermsContent,
    );
  }
}
