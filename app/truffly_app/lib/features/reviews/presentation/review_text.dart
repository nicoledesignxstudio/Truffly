import 'package:flutter/widgets.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

String localizedAutoReviewComment(
  BuildContext context, {
  required int rating,
  required String? fallbackComment,
}) {
  final l10n = AppLocalizations.of(context)!;
  if (rating >= 5) {
    return l10n.reviewAutoCommentCompletedSuccess;
  }
  if (rating <= 2) {
    return l10n.reviewAutoCommentUnshipped48h;
  }
  final trimmedComment = fallbackComment?.trim();
  if (trimmedComment != null && trimmedComment.isNotEmpty) {
    return trimmedComment;
  }
  return l10n.reviewAutoLabel;
}

String localizedReviewRatingLabel(BuildContext context, int rating) {
  final locale = Localizations.localeOf(context).languageCode;
  return switch (rating) {
    5 => locale == 'it' ? 'Eccellente' : 'Excellent',
    4 => locale == 'it' ? 'Ottimo' : 'Great',
    3 => locale == 'it' ? 'Buono' : 'Good',
    2 => locale == 'it' ? 'Discreto' : 'Fair',
    _ => locale == 'it' ? 'Scarso' : 'Poor',
  };
}
