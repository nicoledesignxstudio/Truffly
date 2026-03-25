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
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingS,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: Icon(
                    icon,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingS),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: isDestructive ? AppColors.error : AppColors.black80,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacingXS),
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
