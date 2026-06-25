import 'dart:io';

import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
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
    required this.onReorderPressed,
    this.errorText,
  });

  final String title;
  final String subtitle;
  final String addPhotoLabel;
  final String removePhotoLabel;
  final List<PublishTruffleImageDraft> images;
  final Future<void> Function() onAddPressed;
  final ValueChanged<int> onRemovePressed;
  final void Function(int oldIndex, int newIndex) onReorderPressed;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final canAddMore = images.length < 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: AppSpacing.spacingXS),
        Text(subtitle, style: AppTextStyles.bodySmall),
        const SizedBox(height: AppSpacing.spacingM),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: canAddMore ? images.length + 1 : images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.spacingXS,
            crossAxisSpacing: AppSpacing.spacingXS,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            if (canAddMore && index == images.length) {
              return _AddPhotoCard(
                label: addPhotoLabel,
                onPressed: onAddPressed,
              );
            }

            final image = images[index];
            return _ReorderablePhotoCard(
              index: index,
              image: image,
              removeLabel: removePhotoLabel,
              isCover: index == 0,
              onRemovePressed: () => onRemovePressed(index),
              onReorderPressed: (oldIndex) => onReorderPressed(oldIndex, index),
            );
          },
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.spacingXS),
          Text(
            errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _AddPhotoCard extends StatelessWidget {
  const _AddPhotoCard({required this.label, required this.onPressed});

  static const double _cardRadius = 10;

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        boxShadow: AppShadows.authField,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onPressed(),
          borderRadius: const BorderRadius.all(Radius.circular(_cardRadius)),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.all(
                Radius.circular(_cardRadius),
              ),
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
    required this.isCover,
    required this.isTargeted,
  });

  static const double _cardRadius = 10;

  final PublishTruffleImageDraft image;
  final String removeLabel;
  final VoidCallback onRemovePressed;
  final bool isCover;
  final bool isTargeted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(_cardRadius)),
        boxShadow: AppShadows.authField,
        border: Border.all(
          color: isTargeted ? AppColors.accent : AppColors.black10,
          width: isTargeted ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(_cardRadius)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(image.localPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const ColoredBox(
                  color: AppColors.softGrey,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                );
              },
            ),
            if (isCover)
              Positioned(
                left: AppSpacing.spacingXS,
                top: AppSpacing.spacingXS,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.72),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: Icon(
                      Icons.star_rounded,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: AppSpacing.spacingXS,
              top: AppSpacing.spacingXS,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.black,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onRemovePressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 26,
                    height: 26,
                  ),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.white,
                    size: 16,
                  ),
                  tooltip: removeLabel,
                ),
              ),
            ),
            const Positioned(
              left: AppSpacing.spacingXS,
              bottom: AppSpacing.spacingXS,
              child: Icon(
                Icons.drag_indicator_rounded,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderablePhotoCard extends StatelessWidget {
  const _ReorderablePhotoCard({
    required this.index,
    required this.image,
    required this.removeLabel,
    required this.isCover,
    required this.onRemovePressed,
    required this.onReorderPressed,
  });

  final int index;
  final PublishTruffleImageDraft image;
  final String removeLabel;
  final bool isCover;
  final VoidCallback onRemovePressed;
  final ValueChanged<int> onReorderPressed;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorderPressed(details.data),
      builder: (context, candidateData, rejectedData) {
        final isTargeted = candidateData.isNotEmpty;

        return Draggable<int>(
          data: index,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          ignoringFeedbackPointer: true,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 116,
              height: 128,
              child: _SelectedPhotoCard(
                image: image,
                removeLabel: removeLabel,
                onRemovePressed: onRemovePressed,
                isCover: isCover,
                isTargeted: false,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.35,
            child: _SelectedPhotoCard(
              image: image,
              removeLabel: removeLabel,
              onRemovePressed: onRemovePressed,
              isCover: isCover,
              isTargeted: isTargeted,
            ),
          ),
          child: _SelectedPhotoCard(
            image: image,
            removeLabel: removeLabel,
            onRemovePressed: onRemovePressed,
            isCover: isCover,
            isTargeted: isTargeted,
          ),
        );
      },
    );
  }
}
