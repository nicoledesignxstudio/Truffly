import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';

class AccountSubpageScaffold extends StatelessWidget {
  const AccountSubpageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
  });

  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.account);
              }
            },
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(child: body),
    );
  }
}
