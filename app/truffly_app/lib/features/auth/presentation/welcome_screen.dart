import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/presentation/auth_failure_message_mapper.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_error_message.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

enum _WelcomeHeroVariant { mixed, photoOnly }

const _welcomeHeroVariant = _WelcomeHeroVariant.photoOnly;

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final localeCode = ref.watch(appLocaleCodeProvider);

    return AuthScaffold(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        10,
        AppSpacing.screenHorizontal,
        30,
      ),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      scrollable: false,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final heroHeight = math
                  .min(352.0, math.max(295.0, constraints.maxHeight * 0.46))
                  .toDouble();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _WelcomeLanguageButton(
                      label: _languageLabel(l10n, localeCode),
                      onTap: () => _showLanguageSheet(context, ref),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: heroHeight,
                    child: OverflowBox(
                      alignment: Alignment.center,
                      minWidth:
                          constraints.maxWidth +
                          (AppSpacing.screenHorizontal * 2),
                      maxWidth:
                          constraints.maxWidth +
                          (AppSpacing.screenHorizontal * 2),
                      child: SizedBox(
                        width:
                            constraints.maxWidth +
                            (AppSpacing.screenHorizontal * 2),
                        height: heroHeight,
                        child: _buildWelcomeHero(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: AuthTextBlock(
                      alignment: Alignment.center,
                      maxWidth: 360,
                      child: Text(
                        l10n.authWelcomeTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.authHeroTitle.copyWith(
                          color: AppColors.black,
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          height: 1.13,
                        ),
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
                      AuthSecondaryButton(
                        label: l10n.authWelcomeLoginButton,
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.authWelcomeFooterInfo,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.micro.copyWith(
                          color: const Color(0xB3151618),
                        ),
                      ),
                      // Temporarily hidden on-device to avoid exposing the local
                      // seed-account shortcut on the public welcome screen.
                      // Re-enable these lines when we explicitly need the debug
                      // login entry point again during local development.
                      // if (kDebugMode) ...[
                      //   const SizedBox(height: AppSpacing.spacingM),
                      //   const _DebugQuickAccessCard(),
                      // ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildWelcomeHero() {
  return switch (_welcomeHeroVariant) {
    _WelcomeHeroVariant.mixed => const WelcomeHeroMarquee(),
    _WelcomeHeroVariant.photoOnly => const WelcomePhotoHeroMarquee(),
  };
}

String _languageLabel(AppLocalizations l10n, String localeCode) {
  return localeCode.trim().toLowerCase() == 'en'
      ? l10n.accountLanguageEnglish
      : l10n.accountLanguageItalian;
}

Future<void> _showLanguageSheet(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context)!;
  final currentCode = ref.read(appLocaleCodeProvider).trim().toLowerCase();

  final selectedCode = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.white,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            0,
            AppSpacing.spacingM,
            AppSpacing.spacingM,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.accountSettingsLanguageSheetTitle,
                style: AppTextStyles.authScreenTitle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                l10n.accountSettingsLanguageSheetBody,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black80,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              _WelcomeLanguageOptionTile(
                label: l10n.accountLanguageItalian,
                selected: currentCode != 'en',
                onTap: () => Navigator.of(context).pop('it'),
              ),
              const SizedBox(height: AppSpacing.spacingXS),
              _WelcomeLanguageOptionTile(
                label: l10n.accountLanguageEnglish,
                selected: currentCode == 'en',
                onTap: () => Navigator.of(context).pop('en'),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (selectedCode == null) return;
  ref.read(appLocaleProvider.notifier).setLanguageCode(selectedCode);
}

class _WelcomeLanguageButton extends StatelessWidget {
  const _WelcomeLanguageButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.black10),
            boxShadow: AppShadows.authField,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_outlined,
                color: AppColors.black,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.spacingXS),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeLanguageOptionTile extends StatelessWidget {
  const _WelcomeLanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacingM,
            vertical: AppSpacing.spacingM,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.black10,
            ),
          ),
          child: Row(
            children: [
              Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
              IgnorePointer(
                child: Checkbox(
                  value: selected,
                  onChanged: (_) {},
                  activeColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.black50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomeHeroMarquee extends StatefulWidget {
  const WelcomeHeroMarquee({super.key});

  @override
  State<WelcomeHeroMarquee> createState() => _WelcomeHeroMarqueeState();
}

class _WelcomeHeroMarqueeState extends State<WelcomeHeroMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final firstRowItems = <_WelcomeHeroItem>[
      _WelcomeTextHeroItem(
        label: l10n.welcomeFreshTrufflesHome,
        icon: Icons.local_shipping_outlined,
        iconBackgroundColor: AppColors.black,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/01.jpg'),
      _WelcomeTextHeroItem(
        label: l10n.welcomeVerifiedHunters,
        icon: Icons.verified_user_outlined,
        iconBackgroundColor: AppColors.accent,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/02.jpg'),
      _WelcomeTextHeroItem(
        label: l10n.welcomeSelectedQuality,
        icon: Icons.workspace_premium_outlined,
        iconBackgroundColor: AppColors.black,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/03.jpg'),
    ];
    final secondRowItems = <_WelcomeHeroItem>[
      _WelcomeTextHeroItem(
        label: l10n.welcomeRealFreshTruffle,
        icon: Icons.eco_outlined,
        iconBackgroundColor: AppColors.accent,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/04.jpg'),
      _WelcomeTextHeroItem(
        label: l10n.welcomeDiscoverNewFlavors,
        icon: Icons.auto_awesome_outlined,
        iconBackgroundColor: AppColors.black,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/05.jpg'),
      _WelcomeTextHeroItem(
        label: l10n.welcomeProtectedPurchases,
        icon: Icons.shield_outlined,
        iconBackgroundColor: AppColors.accent,
        backgroundColor: AppColors.white,
      ),
      const _WelcomeImageHeroItem('assets/images/welcome/06.jpg'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const rowGap = AppSpacing.spacingXS;
        final rowHeight = (constraints.maxHeight - rowGap) / 2;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.linear.transform(_controller.value);

            return ClipRect(
              child: Column(
                children: [
                  Expanded(
                    child: _WelcomeMarqueeRow(
                      items: firstRowItems,
                      height: rowHeight,
                      progress: progress,
                      direction: AxisDirection.left,
                    ),
                  ),
                  const SizedBox(height: rowGap),
                  Expanded(
                    child: _WelcomeMarqueeRow(
                      items: secondRowItems,
                      height: rowHeight,
                      progress: progress,
                      direction: AxisDirection.right,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class WelcomePhotoHeroMarquee extends StatefulWidget {
  const WelcomePhotoHeroMarquee({super.key});

  @override
  State<WelcomePhotoHeroMarquee> createState() =>
      _WelcomePhotoHeroMarqueeState();
}

class _WelcomePhotoHeroMarqueeState extends State<WelcomePhotoHeroMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _imageAssets = <String>[
    'assets/images/welcome/01.jpg',
    'assets/images/welcome/02.jpg',
    'assets/images/welcome/03.jpg',
    'assets/images/welcome/04.jpg',
    'assets/images/welcome/05.jpg',
    'assets/images/welcome/06.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rowGap = AppSpacing.spacingXS;
        final rowHeight = (constraints.maxHeight - rowGap) / 2;
        final firstRowImages = _imageAssets.take(3).toList(growable: false);
        final secondRowImages = _imageAssets
            .skip(3)
            .take(3)
            .toList(growable: false);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = Curves.linear.transform(_controller.value);

            return ClipRect(
              child: Column(
                children: [
                  Expanded(
                    child: _WelcomePhotoMarqueeRow(
                      imageAssets: firstRowImages,
                      height: rowHeight,
                      progress: progress,
                      direction: AxisDirection.left,
                    ),
                  ),
                  const SizedBox(height: rowGap),
                  Expanded(
                    child: _WelcomePhotoMarqueeRow(
                      imageAssets: secondRowImages,
                      height: rowHeight,
                      progress: progress,
                      direction: AxisDirection.right,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WelcomeMarqueeRow extends StatelessWidget {
  const _WelcomeMarqueeRow({
    required this.items,
    required this.height,
    required this.progress,
    required this.direction,
  });

  final List<_WelcomeHeroItem> items;
  final double height;
  final double progress;
  final AxisDirection direction;

  static const double _cardGap = 10;

  @override
  Widget build(BuildContext context) {
    final cardWidth = math.max(152.0, height * 0.98).toDouble();

    final cycleWidth =
        items.fold<double>(0, (sum, item) => sum + cardWidth) +
        (_cardGap * (items.length - 1));
    final marqueeWidth = (cycleWidth * 2) + _cardGap;

    final offset = switch (direction) {
      AxisDirection.left => -progress * cycleWidth,
      AxisDirection.right => -cycleWidth + (progress * cycleWidth),
      _ => 0.0,
    };

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: marqueeWidth,
        maxWidth: marqueeWidth,
        child: Transform.translate(
          offset: Offset(offset, 0),
          child: SizedBox(
            width: marqueeWidth,
            child: Row(
              children: [
                _WelcomeMarqueeSequence(
                  items: items,
                  height: height,
                  cardWidth: cardWidth,
                ),
                const SizedBox(width: _cardGap),
                _WelcomeMarqueeSequence(
                  items: items,
                  height: height,
                  cardWidth: cardWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePhotoMarqueeRow extends StatelessWidget {
  const _WelcomePhotoMarqueeRow({
    required this.imageAssets,
    required this.height,
    required this.progress,
    required this.direction,
  });

  final List<String> imageAssets;
  final double height;
  final double progress;
  final AxisDirection direction;

  static const double _cardGap = 10;

  @override
  Widget build(BuildContext context) {
    final cardWidth = math.max(135.0, height * 0.70).toDouble();
    final cycleWidth =
        (cardWidth * imageAssets.length) +
        (_cardGap * (imageAssets.length - 1));
    final marqueeWidth = (cycleWidth * 2) + _cardGap;

    final offset = switch (direction) {
      AxisDirection.left => -progress * cycleWidth,
      AxisDirection.right => -cycleWidth + (progress * cycleWidth),
      _ => 0.0,
    };

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        minWidth: marqueeWidth,
        maxWidth: marqueeWidth,
        child: Transform.translate(
          offset: Offset(offset, 0),
          child: SizedBox(
            width: marqueeWidth,
            child: Row(
              children: [
                _WelcomePhotoSequence(
                  imageAssets: imageAssets,
                  height: height,
                  cardWidth: cardWidth,
                ),
                const SizedBox(width: _cardGap),
                _WelcomePhotoSequence(
                  imageAssets: imageAssets,
                  height: height,
                  cardWidth: cardWidth,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomePhotoSequence extends StatelessWidget {
  const _WelcomePhotoSequence({
    required this.imageAssets,
    required this.height,
    required this.cardWidth,
  });

  final List<String> imageAssets;
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < imageAssets.length; index++) ...[
          SizedBox(
            width: cardWidth,
            height: height,
            child: WelcomeImageCard(assetPath: imageAssets[index]),
          ),
          if (index < imageAssets.length - 1)
            const SizedBox(width: _WelcomePhotoMarqueeRow._cardGap),
        ],
      ],
    );
  }
}

class _WelcomeMarqueeSequence extends StatelessWidget {
  const _WelcomeMarqueeSequence({
    required this.items,
    required this.height,
    required this.cardWidth,
  });

  final List<_WelcomeHeroItem> items;
  final double height;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          SizedBox(
            width: cardWidth,
            height: height,
            child: items[index].build(context),
          ),
          if (index < items.length - 1)
            const SizedBox(width: _WelcomeMarqueeRow._cardGap),
        ],
      ],
    );
  }
}

sealed class _WelcomeHeroItem {
  const _WelcomeHeroItem();

  bool get isImage;

  Widget build(BuildContext context);
}

class _WelcomeTextHeroItem extends _WelcomeHeroItem {
  const _WelcomeTextHeroItem({
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color backgroundColor;

  @override
  bool get isImage => false;

  @override
  Widget build(BuildContext context) {
    return WelcomeFeatureCard(
      label: label,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor,
      backgroundColor: backgroundColor,
    );
  }
}

class _WelcomeImageHeroItem extends _WelcomeHeroItem {
  const _WelcomeImageHeroItem(this.assetPath);

  final String assetPath;

  @override
  bool get isImage => true;

  @override
  Widget build(BuildContext context) {
    return WelcomeImageCard(assetPath: assetPath);
  }
}

class WelcomeFeatureCard extends StatelessWidget {
  const WelcomeFeatureCard({
    super.key,
    required this.label,
    required this.icon,
    required this.iconBackgroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color backgroundColor;

  static const List<BoxShadow> _heroCardShadow = [
    BoxShadow(
      color: Color(0x0D151618),
      offset: Offset(0, 2),
      blurRadius: 5,
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.black10),
        boxShadow: _heroCardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: AppColors.white),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  height: 1.22,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeImageCard extends StatelessWidget {
  const WelcomeImageCard({super.key, required this.assetPath});

  final String assetPath;

  static const List<BoxShadow> _heroCardShadow = [
    BoxShadow(
      color: Color(0x0D151618),
      offset: Offset(0, 2),
      blurRadius: 5,
      spreadRadius: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: _heroCardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

class _DebugQuickAccessCard extends ConsumerStatefulWidget {
  const _DebugQuickAccessCard();

  @override
  ConsumerState<_DebugQuickAccessCard> createState() =>
      _DebugQuickAccessCardState();
}

class _DebugQuickAccessCardState extends ConsumerState<_DebugQuickAccessCard> {
  String? _errorMessage;
  String? _pendingKey;

  @override
  Widget build(BuildContext context) {
    final isItalian = Localizations.localeOf(context).languageCode == 'it';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
        boxShadow: AppShadows.authField,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isItalian ? 'Accesso rapido debug' : 'Debug quick access',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              isItalian
                  ? 'Usa un profilo seedato locale e salta il flusso di creazione account.'
                  : 'Use a seeded local profile and skip the account setup flow.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              label: isItalian
                  ? 'Entra come buyer test'
                  : 'Continue as test buyer',
              isLoading: _pendingKey == _DevQuickProfile.buyer.key,
              enabled: _pendingKey == null,
              onPressed: () => _signIn(_DevQuickProfile.buyer),
            ),
            const SizedBox(height: AppSpacing.spacingS),
            AuthSecondaryButton(
              label: isItalian
                  ? 'Entra come seller test'
                  : 'Continue as test seller',
              onPressed: _pendingKey == null
                  ? () => _signIn(_DevQuickProfile.seller)
                  : null,
            ),
            const SizedBox(height: AppSpacing.spacingS),
            Text(
              isItalian
                  ? 'Seed locale: buyer@test.com e seller1@test.com'
                  : 'Local seed: buyer@test.com and seller1@test.com',
              style: AppTextStyles.micro,
            ),
            AuthErrorMessage(message: _errorMessage),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn(_DevQuickProfile profile) async {
    if (_pendingKey != null) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _pendingKey = profile.key;
      _errorMessage = null;
    });

    final result = await ref
        .read(authNotifierProvider.notifier)
        .signIn(email: profile.email, password: profile.password);

    if (!mounted) return;

    if (result.isFailure) {
      setState(() {
        _errorMessage = loginFailureMessage(result.failureOrNull!, l10n);
      });
    }

    setState(() {
      _pendingKey = null;
    });
  }
}

final class _DevQuickProfile {
  const _DevQuickProfile._({
    required this.key,
    required this.email,
    required this.password,
  });

  static const buyer = _DevQuickProfile._(
    key: 'buyer',
    email: 'buyer@test.com',
    password: 'DevPass123!',
  );

  static const seller = _DevQuickProfile._(
    key: 'seller',
    email: 'seller1@test.com',
    password: 'DevPass123!',
  );

  final String key;
  final String email;
  final String password;
}
