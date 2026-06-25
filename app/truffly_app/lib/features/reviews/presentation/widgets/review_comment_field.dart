import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class ReviewCommentField extends StatelessWidget {
  const ReviewCommentField({
    super.key,
    required this.controller,
    required this.maxLength,
    required this.label,
    required this.placeholder,
    required this.counterText,
    this.enabled = true,
  });

  final TextEditingController controller;
  final int maxLength;
  final String label;
  final String placeholder;
  final String counterText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        TextField(
          controller: controller,
          enabled: enabled,
          maxLength: maxLength,
          minLines: 4,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: counterText,
            filled: true,
            fillColor: const Color(0xFFFFF8F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFFFD7C6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFFFFD7C6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}
