import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class SeasonalHighlightDots extends StatelessWidget {
  const SeasonalHighlightDots({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.spacingXXS),
          width: index == currentIndex ? 18 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: index == currentIndex ? AppColors.accent : AppColors.black20,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}
