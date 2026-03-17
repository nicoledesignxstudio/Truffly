import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(55),
          backgroundColor: AppColors.softGrey,
          foregroundColor: AppColors.black,
          disabledBackgroundColor: AppColors.softGrey,
          disabledForegroundColor: AppColors.black50,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.authBorderRadius,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
        child: Text(label),
      ),
    );
  }
}
