import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
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
          ChoiceChip(
            label: Text(l10n.truffleFilterAll),
            selected: selectedType == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final type in TruffleType.valuesInUiOrder) ...[
            const SizedBox(width: AppSpacing.spacingXS),
            ChoiceChip(
              label: Text(type.localizedName(l10n)),
              selected: selectedType == type,
              onSelected: (_) => onSelected(type),
            ),
          ],
        ],
      ),
    );
  }
}
