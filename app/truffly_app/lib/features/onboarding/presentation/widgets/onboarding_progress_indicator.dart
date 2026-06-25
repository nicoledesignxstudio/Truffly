import 'package:flutter/material.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_definition.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_step_id.dart';

class OnboardingProgressIndicator extends StatelessWidget {
  const OnboardingProgressIndicator({
    super.key,
    required this.step,
    required this.steps,
  });

  final OnboardingStepDefinition step;
  final List<OnboardingStepDefinition> steps;

  @override
  Widget build(BuildContext context) {
    final trackedSteps = steps
        .where(
          (candidate) =>
              candidate.id != OnboardingStepId.notifications &&
              candidate.id != OnboardingStepId.welcome,
        )
        .toList(growable: false);
    final stepIndex = trackedSteps.indexWhere(
      (candidate) => candidate.id == step.id,
    );
    if (stepIndex == -1 || trackedSteps.isEmpty) {
      return const SizedBox.shrink();
    }

    final progress = (stepIndex + 1) / trackedSteps.length;

    return ClipRRect(
      borderRadius: AppRadii.circularBorderRadius,
      child: LinearProgressIndicator(
        minHeight: 8,
        value: progress,
        backgroundColor: AppColors.softGrey,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.black),
      ),
    );
  }
}
