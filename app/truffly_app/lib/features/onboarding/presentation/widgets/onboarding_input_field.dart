import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class OnboardingTextField extends StatelessWidget {
  const OnboardingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: AppRadii.authBorderRadius,
            boxShadow: AppShadows.authField,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            cursorColor: AppColors.accent,
            style: AppTextStyles.bodyLarge,
            decoration: _baseDecoration(
              hintText: hintText,
              hasError: errorText != null,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class OnboardingDropdownField<T> extends StatefulWidget {
  const OnboardingDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.errorText,
  });

  final String hintText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? initialValue;
  final String? errorText;

  @override
  State<OnboardingDropdownField<T>> createState() =>
      _OnboardingDropdownFieldState<T>();
}

class _OnboardingDropdownFieldState<T> extends State<OnboardingDropdownField<T>> {
  final MenuController _menuController = MenuController();
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final menuWidth =
        MediaQuery.sizeOf(context).width - (AppSpacing.screenHorizontal * 2);

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: const WidgetStatePropertyAll(true),
          trackVisibility: const WidgetStatePropertyAll(true),
          thickness: const WidgetStatePropertyAll(7),
          radius: const Radius.circular(999),
          thumbColor: const WidgetStatePropertyAll(AppColors.black50),
          trackColor: const WidgetStatePropertyAll(AppColors.black10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MenuAnchor(
            controller: _menuController,
            onOpen: () => setState(() {
              _isOpen = true;
            }),
            onClose: () => setState(() {
              _isOpen = false;
            }),
            menuChildren: [
              Container(
                width: menuWidth,
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: AppRadii.authBorderRadius,
                  boxShadow: AppShadows.authField,
                ),
                child: ClipRRect(
                  borderRadius: AppRadii.authBorderRadius,
                  child: Scrollbar(
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var index = 0; index < widget.items.length; index++)
                            _DropdownMenuTile<T>(
                              item: widget.items[index],
                              isLast: index == widget.items.length - 1,
                              onTap: () {
                                widget.onChanged(widget.items[index].value);
                                _menuController.close();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            builder: (context, controller, child) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  borderRadius: AppRadii.authBorderRadius,
                  boxShadow: AppShadows.authField,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    borderRadius: AppRadii.authBorderRadius,
                    child: InputDecorator(
                      isFocused: _isOpen,
                      isEmpty: widget.initialValue == null,
                      decoration: _baseDecoration(
                        hintText: '',
                        hasError: widget.errorText != null,
                        isFocused: _isOpen,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedLabel() ?? widget.hintText,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: widget.initialValue == null
                                    ? AppColors.black50
                                    : AppColors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Icon(
                            _isOpen
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppColors.black50,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.errorText != null) ...[
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              widget.errorText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _selectedLabel() {
    for (final item in widget.items) {
      if (item.value == widget.initialValue) {
        final child = item.child;
        if (child is Text) {
          return child.data;
        }
      }
    }
    return null;
  }
}

class _DropdownMenuTile<T> extends StatelessWidget {
  const _DropdownMenuTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final DropdownMenuItem<T> item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: item.enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingM,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : AppColors.black10,
              ),
            ),
          ),
          child: DefaultTextStyle(
            style: AppTextStyles.bodyLarge.copyWith(
              color: item.enabled ? AppColors.black : AppColors.black50,
            ),
            child: item.child,
          ),
        ),
      ),
    );
  }
}

InputDecoration _baseDecoration({
  required String hintText,
  required bool hasError,
  bool isFocused = false,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: AppTextStyles.fieldLabel,
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
    errorStyle: const TextStyle(fontSize: 0, height: 0),
    border: hasError
        ? const OutlineInputBorder(
            borderRadius: AppRadii.authBorderRadius,
            borderSide: BorderSide(color: AppColors.error),
          )
        : isFocused
            ? const OutlineInputBorder(
                borderRadius: AppRadii.authBorderRadius,
                borderSide: BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              )
            : const OutlineInputBorder(
                borderRadius: AppRadii.authBorderRadius,
                borderSide: BorderSide(color: AppColors.black20),
              ),
  );
}
