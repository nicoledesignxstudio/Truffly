import 'dart:io';

import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_image_draft.dart';

class PublishTruffleImageSection extends StatelessWidget {
  const PublishTruffleImageSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.addPhotoLabel,
    required this.removePhotoLabel,
    required this.images,
    required this.onAddPressed,
    required this.onRemovePressed,
    this.errorText,
  });

  final String title;
  final String subtitle;
  final String addPhotoLabel;
  final String removePhotoLabel;
  final List<PublishTruffleImageDraft> images;
  final Future<void> Function() onAddPressed;
  final ValueChanged<int> onRemovePressed;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final canAddMore = images.length < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: AppSpacing.spacingXS),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: AppSpacing.spacingM),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: canAddMore ? images.length + 1 : images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.spacingS,
            crossAxisSpacing: AppSpacing.spacingS,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            if (canAddMore && index == images.length) {
              return _AddPhotoCard(
                label: addPhotoLabel,
                onPressed: onAddPressed,
              );
            }

            final image = images[index];
            return _SelectedPhotoCard(
              image: image,
              removeLabel: removePhotoLabel,
              onRemovePressed: () => onRemovePressed(index),
            );
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPressed(),
          borderRadius: AppRadii.authBorderRadius,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: AppRadii.authBorderRadius,
              border: Border.all(color: AppColors.black10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                  const SizedBox(height: AppSpacing.spacingS),
                  Text(
                    label,
                    style: AppTextStyles.bodySmall,
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

class _SelectedPhotoCard extends StatelessWidget {
  const _SelectedPhotoCard({
    required this.image,
    required this.removeLabel,
    required this.onRemovePressed,
  });

  final PublishTruffleImageDraft image;
  final String removeLabel;
  final VoidCallback onRemovePressed;

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(image.localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(
                  color: AppColors.softGrey,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined),
                  ),
                );
              },
            ),
            Positioned(
              right: AppSpacing.spacingXS,
              top: AppSpacing.spacingXS,
              child: IconButton.filledTonal(
                onPressed: onRemovePressed,
                icon: const Icon(Icons.close_rounded),
                tooltip: removeLabel,
              ),
            ),
            Positioned(
              left: AppSpacing.spacingXS,
              right: AppSpacing.spacingXS,
              bottom: AppSpacing.spacingXS,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacingS,
                    vertical: AppSpacing.spacingXS,
                  ),
                  child: Text(
                    image.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.micro.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
