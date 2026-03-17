import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class TruffleListingSkeletonGrid extends StatelessWidget {
  const TruffleListingSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.spacingXS,
        crossAxisSpacing: AppSpacing.spacingXS,
        childAspectRatio: 0.66,
      ),
      itemBuilder: (context, index) => const _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.authBorderRadius,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ShaderMask(
              shaderCallback: (bounds) {
                final width = bounds.width;
                final slide = (_controller.value * 2 * width) - width;
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    AppColors.softGrey,
                    AppColors.white,
                    AppColors.softGrey,
                  ],
                  stops: const [0.1, 0.5, 0.9],
                  transform: _SlidingGradientTransform(slide),
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.softGrey,
                      borderRadius: BorderRadius.circular(AppRadii.auth),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                Container(height: 16, color: AppColors.softGrey),
                const SizedBox(height: AppSpacing.spacingXS),
                Container(height: 14, color: AppColors.softGrey),
                const SizedBox(height: AppSpacing.spacingM),
                Container(height: 14, color: AppColors.softGrey),
                const SizedBox(height: AppSpacing.spacingXS),
                Container(height: 12, width: 60, color: AppColors.softGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.slidePercent);

  final double slidePercent;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(slidePercent, 0, 0);
  }
}
