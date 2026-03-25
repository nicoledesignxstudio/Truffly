import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

class TruffleGuidePlaceholderPage extends StatelessWidget {
  const TruffleGuidePlaceholderPage({
    super.key,
    required this.truffleType,
  });

  final TruffleType truffleType;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return Scaffold(
      bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.guide),
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
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: Text(
          isItalian ? 'Guida tartufo' : 'Truffle guide',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.black10),
              boxShadow: AppShadows.authField,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isItalian
                        ? 'La guida dettagliata per questa tipologia arrivera presto.'
                        : 'A detailed guide for this truffle type is coming soon.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Text(
                    truffleType.latinName,
                    style: AppTextStyles.cardTitle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
