import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';

class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List<Widget>.generate(5, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= value;
        return IconButton(
          onPressed: () => onChanged(starValue),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          iconSize: 48,
          splashRadius: 28,
          icon: Icon(
            Icons.star_rounded,
            color: isSelected ? AppColors.accent : AppColors.black20,
          ),
        );
      }),
    );
  }
}
