import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';

class SellerAvatar extends StatelessWidget {
  const SellerAvatar({
    super.key,
    required this.imageUrl,
    required this.initials,
    this.size = 52,
  });

  final String? imageUrl;
  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final normalizedImageUrl = imageUrl?.trim();
    final canUseImage = normalizedImageUrl != null &&
        normalizedImageUrl.isNotEmpty &&
        Uri.tryParse(normalizedImageUrl)?.hasScheme == true;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: canUseImage
          ? Image.network(
              normalizedImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _SellerInitials(initials: initials);
              },
            )
          : _SellerInitials(initials: initials),
    );
  }
}

class _SellerInitials extends StatelessWidget {
  const _SellerInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: AppTextStyles.cardTitle.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
