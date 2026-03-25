import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofillHints,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.obscureText = false,
    this.focusNode,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool obscureText;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? errorText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        autofillHints: autofillHints,
        maxLines: maxLines,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        cursorColor: AppColors.accent,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: labelText,
          hintStyle: AppTextStyles.fieldLabel,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          prefixIconColor: AppColors.black50,
          suffixIconColor: AppColors.black50,
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingM,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.black20),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.black20),
          ),
          border: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.black20),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(
              color: AppColors.accent,
              width: 1.5,
            ),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.error),
          ),
          errorText: errorText,
        ),
      ),
    );
  }
}
