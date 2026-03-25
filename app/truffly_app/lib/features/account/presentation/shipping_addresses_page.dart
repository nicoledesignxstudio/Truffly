import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/shipping_addresses_notifier.dart';
import 'package:truffly_app/features/account/domain/shipping_address.dart';
import 'package:truffly_app/features/account/presentation/widgets/account_section_card.dart';
import 'package:truffly_app/features/account/presentation/widgets/shipping_address_card.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class ShippingAddressesPage extends ConsumerWidget {
  const ShippingAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(shippingAddressesNotifierProvider);
    final notifier = ref.read(shippingAddressesNotifierProvider.notifier);

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
          l10n.shippingAddressesTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      bottomNavigationBar: state.items.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingM,
                ),
                child: AuthPrimaryButton(
                  key: const Key('shipping_add_button'),
                  label: l10n.shippingAddressesAddCta,
                  backgroundColor: AppColors.black,
                  enabled: !state.isLoading,
                  onPressed: !state.isLoading
                      ? () => _openAddPage(context, notifier)
                      : null,
                ),
              ),
            ),
      body: SafeArea(
        child: state.isLoading && state.items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null && state.items.isEmpty
                ? _ShippingAddressesErrorState(
                    message: _messageForState(l10n, state.errorMessage!),
                    onRetry: notifier.load,
                  )
                : RefreshIndicator(
                    onRefresh: notifier.load,
                    child: state.items.isEmpty
                        ? _ShippingAddressesEmptyState(
                            onAddPressed: () => _openAddPage(context, notifier),
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.spacingM,
                              AppSpacing.spacingS,
                              AppSpacing.spacingM,
                              AppSpacing.spacingXXL,
                            ),
                            children: [
                              Text(
                                l10n.shippingAddressesSubtitle,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.black80,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.spacingM),
                              AccountSectionCard(
                                title: l10n.shippingAddressesSectionTitle,
                                children: [
                                  for (var index = 0;
                                      index < state.items.length;
                                      index++) ...[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.spacingS,
                                        AppSpacing.spacingS,
                                        AppSpacing.spacingS,
                                        AppSpacing.spacingS,
                                      ),
                                      child: ShippingAddressCard(
                                        key: Key(
                                          'shipping_address_card_${state.items[index].id}',
                                        ),
                                        address: state.items[index],
                                        onTap: () => _openEditPage(
                                          context,
                                          notifier,
                                          state.items[index],
                                        ),
                                      ),
                                    ),
                                    if (index != state.items.length - 1)
                                      const Divider(
                                        height: 1,
                                        color: AppColors.black10,
                                      ),
                                  ],
                                ],
                              ),
                              if (state.errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.spacingM),
                                Text(
                                  _messageForState(l10n, state.errorMessage!),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
      ),
    );
  }

  Future<void> _openAddPage(
    BuildContext context,
    ShippingAddressesNotifier notifier,
  ) async {
    final result = await context.push<String>(AppRoutes.accountShippingAdd);
    if (result != null) {
      await notifier.load();
      if (context.mounted) {
        _showResultMessage(context, result);
      }
    }
  }

  Future<void> _openEditPage(
    BuildContext context,
    ShippingAddressesNotifier notifier,
    ShippingAddress address,
  ) async {
    final result = await context.push<String>(
      AppRoutes.accountShippingEditPath(address.id),
    );
    if (result != null) {
      await notifier.load();
      if (context.mounted) {
        _showResultMessage(context, result);
      }
    }
  }

  void _showResultMessage(BuildContext context, String result) {
    final l10n = AppLocalizations.of(context)!;
    final message = switch (result) {
      'saved' => l10n.shippingAddressSavedSuccess,
      'deleted' => l10n.shippingAddressDeletedSuccess,
      _ => null,
    };

    if (message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF178A42),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ShippingAddressesEmptyState extends StatelessWidget {
  const _ShippingAddressesEmptyState({
    required this.onAddPressed,
  });

  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.spacingL),
      children: [
        const SizedBox(height: 72),
        Text(
          l10n.shippingAddressesEmptyTitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
        ),
        const SizedBox(height: AppSpacing.spacingS),
        Text(
          l10n.shippingAddressesEmptySubtitle,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.black80,
          ),
        ),
        const SizedBox(height: AppSpacing.spacingL),
        AuthPrimaryButton(
          key: const Key('shipping_empty_add_button'),
          label: l10n.shippingAddressesAddCta,
          backgroundColor: AppColors.black,
          onPressed: onAddPressed,
        ),
      ],
    );
  }
}

class _ShippingAddressesErrorState extends StatelessWidget {
  const _ShippingAddressesErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              label: l10n.truffleRetry,
              backgroundColor: AppColors.accent,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

String _messageForState(AppLocalizations l10n, String code) {
  return switch (code) {
    'network' => l10n.shippingAddressesNetworkError,
    'unauthorized' => l10n.shippingAddressesUnauthorizedError,
    'not_found' => l10n.shippingAddressesNotFoundError,
    'validation' => l10n.shippingAddressesValidationError,
    _ => l10n.shippingAddressesLoadError,
  };
}
