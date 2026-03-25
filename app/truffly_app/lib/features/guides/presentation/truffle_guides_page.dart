import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/guides/application/truffle_guides_providers.dart';
import 'package:truffly_app/features/guides/presentation/widgets/truffle_guide_list_card.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class TruffleGuidesPage extends ConsumerWidget {
  const TruffleGuidesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = Localizations.localeOf(context).languageCode == 'en'
        ? 'en'
        : 'it';
    final guidesAsync = ref.watch(truffleGuidesListProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
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
          l10n.guidesPageTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(truffleGuidesListProvider),
        child: guidesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _GuidesError(
            message: l10n.guidesLoadError,
            retryLabel: l10n.guidesRetry,
            onRetry: () => ref.invalidate(truffleGuidesListProvider),
          ),
          data: (guides) {
            if (guides.isEmpty) {
              return _GuidesEmpty(message: l10n.guidesEmpty);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacingM,
                AppSpacing.spacingS,
                AppSpacing.spacingM,
                AppSpacing.spacingL,
              ),
              itemBuilder: (context, index) {
                final guide = guides[index];
                return TruffleGuideListCard(
                  guide: guide,
                  localeCode: localeCode,
                  imageAssetPath: guide.truffleType.guideAssetImagePath,
                  onTap: () => context.push(
                    AppRoutes.truffleGuidePath(guide.truffleType.dbValue),
                  ),
                );
              },
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.spacingS),
              itemCount: guides.length,
            );
          },
        ),
      ),
    );
  }
}

class _GuidesError extends StatelessWidget {
  const _GuidesError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.spacingM),
            TextButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}

class _GuidesEmpty extends StatelessWidget {
  const _GuidesEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}
