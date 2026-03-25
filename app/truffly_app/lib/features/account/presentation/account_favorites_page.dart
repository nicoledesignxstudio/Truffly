import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_favorites_providers.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/marketplace/presentation/widgets/truffle_listing_card.dart';
import 'package:truffly_app/features/truffle/application/truffle_providers.dart';

class AccountFavoritesPage extends ConsumerWidget {
  const AccountFavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIdsState = ref.watch(favoriteIdsNotifierProvider);
    final favoriteNotifier = ref.read(favoriteIdsNotifierProvider.notifier);
    final favoritesAsync = ref.watch(accountFavoriteTrufflesProvider);
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

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
          isItalian ? 'Preferiti' : 'Favorites',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(favoriteIdsNotifierProvider.notifier).load();
          ref.invalidate(accountFavoriteTrufflesProvider);
          await ref.read(accountFavoriteTrufflesProvider.future);
        },
        child: favoritesAsync.when(
          data: (items) {
            if (favoriteIdsState.isLoading && items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (favoriteIdsState.failure != null && items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                children: [
                  const SizedBox(height: AppSpacing.spacingXXL),
                  Text(
                    isItalian
                        ? 'Impossibile caricare i preferiti in questo momento.'
                        : 'Unable to load favorites right now.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  AuthPrimaryButton(
                    label: isItalian ? 'Riprova' : 'Retry',
                    onPressed: () async {
                      await ref.read(favoriteIdsNotifierProvider.notifier).load();
                      ref.invalidate(accountFavoriteTrufflesProvider);
                    },
                  ),
                ],
              );
            }

            if (items.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.spacingL),
                children: [
                  const SizedBox(height: AppSpacing.spacingXXL),
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 48,
                    color: AppColors.black50,
                  ),
                  const SizedBox(height: AppSpacing.spacingM),
                  Text(
                    isItalian
                        ? 'Non hai ancora tartufi preferiti.'
                        : 'You do not have favorite truffles yet.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.sectionTitle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacingXS),
                  Text(
                    isItalian
                        ? 'Salva i tartufi che ti interessano e li ritroverai qui.'
                        : 'Save the truffles you like and you will find them here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.spacingL),
                  AuthPrimaryButton(
                    label: isItalian ? 'Vai ai tartufi' : 'Go to truffles',
                    onPressed: () => context.go(AppRoutes.truffles),
                  ),
                ],
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacingM,
                AppSpacing.spacingS,
                AppSpacing.spacingM,
                AppSpacing.spacingL,
              ),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.spacingXS,
                crossAxisSpacing: AppSpacing.spacingXS,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return TruffleListingCard(
                  item: item,
                  isFavorite: favoriteIdsState.ids.contains(item.id),
                  isFavoritePending: favoriteIdsState.pendingIds.contains(item.id),
                  onTap: () => context.push(AppRoutes.truffleDetailPath(item.id)),
                  onFavoriteTap: () async {
                    await favoriteNotifier.toggleFavorite(item.id);
                    ref.invalidate(accountFavoriteTrufflesProvider);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => ListView(
            padding: const EdgeInsets.all(AppSpacing.spacingL),
            children: [
              const SizedBox(height: AppSpacing.spacingXXL),
              Text(
                isItalian
                    ? 'Impossibile caricare i preferiti in questo momento.'
                    : 'Unable to load favorites right now.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.spacingM),
              AuthPrimaryButton(
                label: isItalian ? 'Riprova' : 'Retry',
                onPressed: () {
                  ref.invalidate(accountFavoriteTrufflesProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
