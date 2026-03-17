import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingWelcomePage extends ConsumerWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);

    final title = onboardingState.isSellerFlow
        ? l10n.onboardingWelcomeSellerTitle
        : onboardingState.isBuyerFlow
            ? l10n.onboardingWelcomeBuyerTitle
            : l10n.onboardingWelcomeDefaultTitle;
    final subtitle = onboardingState.isSellerFlow
        ? l10n.onboardingWelcomeSellerSubtitle
        : onboardingState.isBuyerFlow
            ? l10n.onboardingWelcomeBuyerSubtitle
            : l10n.onboardingWelcomeDefaultSubtitle;
    final message = onboardingState.isSellerFlow
        ? l10n.onboardingWelcomeSellerMessage
        : onboardingState.isBuyerFlow
            ? l10n.onboardingWelcomeBuyerMessage
            : l10n.onboardingWelcomeDefaultMessage;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WelcomeHero(isSellerFlow: onboardingState.isSellerFlow),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({
    required this.isSellerFlow,
  });

  final bool isSellerFlow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 168,
      height: 168,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Icon(
        isSellerFlow ? Icons.storefront_outlined : Icons.eco_outlined,
        size: 72,
        color: colorScheme.primary,
      ),
    );
  }
}
