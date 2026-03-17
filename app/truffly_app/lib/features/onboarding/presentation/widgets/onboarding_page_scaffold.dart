import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';

class OnboardingPageScaffold extends StatelessWidget {
  const OnboardingPageScaffold({
    super.key,
    required this.body,
    this.progressIndicator,
    this.bottomActions,
  });

  final Widget body;
  final Widget? progressIndicator;
  final Widget? bottomActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (progressIndicator != null) ...[
          progressIndicator!,
          const SizedBox(height: AppSpacing.authGroupGap),
        ],
        Expanded(child: body),
        if (bottomActions != null) ...[
          const SizedBox(height: AppSpacing.authGroupGap),
          bottomActions!,
        ],
      ],
    );
  }
}
