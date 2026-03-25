import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/home/application/seasonal_highlight_provider.dart';
import 'package:truffly_app/features/home/data/models/seasonal_highlight_response.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_card.dart';
import 'package:truffly_app/features/home/presentation/widgets/seasonal_highlight_dots.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SeasonalHighlightSection extends ConsumerStatefulWidget {
  const SeasonalHighlightSection({super.key});

  @override
  ConsumerState<SeasonalHighlightSection> createState() => _SeasonalHighlightSectionState();
}

class _SeasonalHighlightSectionState extends ConsumerState<SeasonalHighlightSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(seasonalHighlightProvider);

    return state.when(
      data: (data) => _buildData(context, data),
      loading: () => _LoadingCard(label: l10n.homeSeasonalLoadingLabel),
      error: (_, __) => _ErrorCard(
        message: l10n.homeSeasonalErrorText,
        retryLabel: l10n.homeSeasonalRetryLabel,
        onRetry: () => ref.read(seasonalHighlightProvider.notifier).retry(),
      ),
    );
  }

  Widget _buildData(BuildContext context, SeasonalHighlightResponse response) {
    final l10n = AppLocalizations.of(context)!;

    if (response.mode == SeasonalHighlightMode.active && response.cards.isNotEmpty) {
      final cards = response.cards;
      final safePage = _currentPage.clamp(0, cards.length - 1);
      if (safePage != _currentPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _currentPage = safePage;
          });
        });
      }

      return Column(
        children: [
          SizedBox(
            height: _estimatedActiveCardHeight(context, cards),
            child: PageView.builder(
              controller: _pageController,
              itemCount: cards.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPage = value;
                });
              },
              itemBuilder: (context, index) {
                final item = cards[index];
                return SeasonalHighlightCard(
                  title: item.title,
                  subtitle: item.subtitle,
                  badgeLabel: l10n.homeSeasonalInSeasonLabel,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.spacingS),
          SeasonalHighlightDots(
            count: cards.length,
            currentIndex: _currentPage.clamp(0, cards.length - 1),
          ),
        ],
      );
    }

    final countdown = response.countdown;
    if (countdown != null) {
      return SeasonalHighlightCard(
        title: countdown.title,
        subtitle: countdown.subtitle,
        badgeLabel: l10n.homeSeasonalComingSoonLabel,
        footnote: l10n.homeSeasonalCountdownLine(
          countdown.daysRemaining,
          countdown.truffleType.seasonalDisplayName(l10n),
        ),
      );
    }

    return _EmptyCard(message: l10n.homeSeasonalEmptyText);
  }

  double _estimatedActiveCardHeight(
    BuildContext context,
    List<SeasonalHighlightCardItem> cards,
  ) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final cardWidth = mediaWidth - (AppSpacing.screenHorizontal * 2);
    final textWidth = (cardWidth * 0.64) - (AppSpacing.spacingM * 2);

    var maxTextHeight = 0.0;
    for (final card in cards) {
      maxTextHeight = _max(maxTextHeight, _textHeight(card.title, textWidth, 18, FontWeight.w500));
      maxTextHeight = _max(maxTextHeight, _textHeight(card.subtitle, textWidth, 14, FontWeight.w400));
    }

    final estimated = (AppSpacing.spacingM * 2) + 24 + 20 + 4 + maxTextHeight + 8;
    return estimated.clamp(168.0, 240.0);
  }

  double _textHeight(
    String text,
    double maxWidth,
    double fontSize,
    FontWeight fontWeight,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTextStyles.bodySmall.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.3,
        ),
      ),
      maxLines: 4,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.height;
  }

  double _max(double a, double b) => a > b ? a : b;
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(label, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      child: Text(
        message,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
      ),
    );
  }
}
