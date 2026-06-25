import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class AccountMenuRow extends StatelessWidget {
  const AccountMenuRow({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingXS,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Text(
                  label,
                  softWrap: true,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDestructive
                        ? AppColors.error
                        : isEnabled
                        ? AppColors.black80
                        : AppColors.black50,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingXS),
              if (isEnabled)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive ? AppColors.error : AppColors.black50,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
