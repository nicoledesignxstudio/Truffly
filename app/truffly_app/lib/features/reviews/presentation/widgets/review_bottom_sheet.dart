import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/reviews/application/reviews_providers.dart';
import 'package:truffly_app/features/reviews/presentation/widgets/star_rating_input.dart';
import 'package:truffly_app/features/reviews/presentation/review_text.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ReviewBottomSheet extends ConsumerStatefulWidget {
  const ReviewBottomSheet({
    super.key,
    required this.orderId,
    required this.onSubmitted,
  });

  final String orderId;
  final Future<void> Function(int rating, String? comment) onSubmitted;

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  static const _maxCommentLength = 300;

  late final TextEditingController _commentController;
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController()
      ..addListener(_handleCommentChanged);
  }

  @override
  void dispose() {
    _commentController
      ..removeListener(_handleCommentChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSubmitting = ref.watch(
      reviewSubmissionProvider.select(
        (pending) => pending.contains(widget.orderId),
      ),
    );
    final ratingLabel = localizedReviewRatingLabel(context, _rating);
    final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxSheetHeight),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 70,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.black10,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text(
                    l10n.reviewSheetTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontSize: 22,
                      height: 1.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      l10n.reviewSheetSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.black80,
                        height: 1.35,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StarRatingInput(
                    value: _rating,
                    onChanged: isSubmitting
                        ? (_) {}
                        : (value) => setState(() {
                            _rating = value;
                          }),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBE6DF),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$ratingLabel \u2728',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReviewCommentBox(
                    controller: _commentController,
                    enabled: !isSubmitting,
                    placeholder: l10n.reviewCommentPlaceholder,
                    counterText:
                        '${_commentController.text.length}/$_maxCommentLength',
                    maxLength: _maxCommentLength,
                  ),
                  const SizedBox(height: 14),
                  _ReviewInfoCard(message: l10n.reviewWindowNote),
                  const SizedBox(height: 14),
                  AuthPrimaryButton(
                    label: l10n.reviewSubmitCta,
                    isLoading: isSubmitting,
                    onPressed: () async {
                      if (isSubmitting) return;
                      await widget.onSubmitted(_rating, _normalizedComment);
                    },
                  ),
                  const SizedBox(height: 10),
                  AuthSecondaryButton(
                    label: l10n.reviewCancelCta,
                    enabled: !isSubmitting,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? get _normalizedComment {
    final trimmed = _commentController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _handleCommentChanged() {
    setState(() {});
  }
}

class _ReviewCommentBox extends StatelessWidget {
  const _ReviewCommentBox({
    required this.controller,
    required this.enabled,
    required this.placeholder,
    required this.counterText,
    required this.maxLength,
  });

  final TextEditingController controller;
  final bool enabled;
  final String placeholder;
  final String counterText;
  final int maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
          maxLength: maxLength,
          minLines: 5,
          maxLines: 6,
          textAlignVertical: TextAlignVertical.top,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.black,
            fontSize: 15,
            height: 1.35,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            counterText: '',
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.black50,
              fontSize: 15,
              height: 1.35,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.black20),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.black20),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.black, width: 1.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.black20),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            counterText,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.black50,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewInfoCard extends StatelessWidget {
  const _ReviewInfoCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.black50, width: 1.8),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppColors.black50,
              size: 22,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.black80,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
