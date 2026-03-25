import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

enum HomeNavTab {
  home,
  truffles,
  sellers,
  guide,
  account,
}

class HomeNavBar extends StatelessWidget {
  const HomeNavBar({
    super.key,
    required this.activeTab,
  });

  final HomeNavTab activeTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.spacingXS,
        AppSpacing.screenHorizontal,
        AppSpacing.screenHorizontal,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          boxShadow: AppShadows.authField,
          border: Border.all(color: AppColors.black10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingXS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                isActive: activeTab == HomeNavTab.home,
                onTap: () => context.go(AppRoutes.home),
              ),
              _NavItem(
                icon: Icons.eco_outlined,
                isActive: activeTab == HomeNavTab.truffles,
                onTap: () => context.go(AppRoutes.truffles),
              ),
              _NavItem(
                icon: Icons.people_outline_rounded,
                isActive: activeTab == HomeNavTab.sellers,
                onTap: () => context.go(AppRoutes.sellers),
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                isActive: activeTab == HomeNavTab.guide,
                onTap: () => context.go(AppRoutes.guides),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                isActive: activeTab == HomeNavTab.account,
                onTap: () => context.go(AppRoutes.account),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: AppColors.white,
            size: 26,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Icon(
          icon,
          color: AppColors.black80,
          size: 25,
        ),
      ),
    );
  }
}
