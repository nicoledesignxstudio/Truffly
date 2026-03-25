import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleTypeChips extends StatelessWidget {
  const TruffleTypeChips({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final TruffleType? selectedType;
  final ValueChanged<TruffleType?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StyledTypeChip(
            label: l10n.truffleFilterAll,
            selected: selectedType == null,
            onTap: () => onSelected(null),
          ),
          for (final type in TruffleType.valuesInUiOrder) ...[
            const SizedBox(width: AppSpacing.spacingXS),
            _StyledTypeChip(
              label: type.localizedName(l10n),
              selected: selectedType == type,
              onTap: () => onSelected(type),
            ),
          ],
        ],
      ),
    );
  }
}

class _StyledTypeChip extends StatelessWidget {
  const _StyledTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.black : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(color: selected ? AppColors.black : AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.authBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM + 2,
              vertical: AppSpacing.spacingS,
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.black80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
