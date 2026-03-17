import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_google_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.48).clamp(320.0, 440.0);

    return AuthScaffold(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      scrollable: false,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: heroHeight,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: double.infinity,
                      height: heroHeight,
                      child: Image.asset(
                        'assets/images/auth/welcome_screen.webp',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.authGroupGap),
              AuthTextBlock(
                alignment: Alignment.centerLeft,
                maxWidth: 360,
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: AppTextStyles.authHeroTitle.copyWith(
                      color: AppColors.black,
                    ),
                    children: [
                      TextSpan(
                        text: l10n.authWelcomeTitleLeading,
                        style: AppTextStyles.authHeroTitle.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextSpan(
                        text: '\n${l10n.authWelcomeTitleAccent}',
                        style: AppTextStyles.authHeroTitle.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.authFieldGap),
              AuthTextBlock(
                alignment: Alignment.centerLeft,
                maxWidth: 360,
                child: Text(
                  l10n.authWelcomeSubtitle,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.black,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthPrimaryButton(
                    label: l10n.authWelcomeCreateAccountButton,
                    onPressed: () => context.go(AppRoutes.signup),
                  ),
                  const SizedBox(height: AppSpacing.authFieldGap),
                  AuthGoogleButton(
                    label: l10n.authWelcomeGoogleButton,
                    onPressed: () {},
                    enabled: true,
                  ),
                  const SizedBox(height: AppSpacing.authFieldGap),
                  AuthSecondaryButton(
                    label: l10n.authWelcomeLoginButton,
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
