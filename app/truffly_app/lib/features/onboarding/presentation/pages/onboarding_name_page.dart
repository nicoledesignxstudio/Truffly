import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class OnboardingNamePage extends ConsumerStatefulWidget {
  const OnboardingNamePage({super.key});

  @override
  ConsumerState<OnboardingNamePage> createState() => _OnboardingNamePageState();
}

class _OnboardingNamePageState extends ConsumerState<OnboardingNamePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final FocusNode _firstNameFocusNode;
  late final FocusNode _lastNameFocusNode;
  late final ProviderSubscription<String> _firstNameSubscription;
  late final ProviderSubscription<String> _lastNameSubscription;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(onboardingNotifierProvider);
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _firstNameController = TextEditingController(
      text: initialState.draft.firstName,
    );
    _lastNameController = TextEditingController(
      text: initialState.draft.lastName,
    );

    _firstNameSubscription = ref.listenManual<String>(
      onboardingNotifierProvider.select((state) => state.draft.firstName),
      (_, next) => _syncController(_firstNameController, next),
    );
    _lastNameSubscription = ref.listenManual<String>(
      onboardingNotifierProvider.select((state) => state.draft.lastName),
      (_, next) => _syncController(_lastNameController, next),
    );
  }

  @override
  void dispose() {
    _firstNameSubscription.close();
    _lastNameSubscription.close();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final notifier = ref.read(onboardingNotifierProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingNameTitle,
                        style: AppTextStyles.authScreenTitle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingNameSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.black80,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    OnboardingTextField(
                      controller: _firstNameController,
                      focusNode: _firstNameFocusNode,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      hintText: l10n.onboardingFirstNameLabel,
                      errorText: _firstNameError(
                        onboardingState.validationFailures,
                        l10n,
                      ),
                      onChanged: notifier.updateFirstName,
                      onSubmitted: (_) => _lastNameFocusNode.requestFocus(),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    OnboardingTextField(
                      controller: _lastNameController,
                      focusNode: _lastNameFocusNode,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.words,
                      hintText: l10n.onboardingLastNameLabel,
                      errorText: _lastNameError(
                        onboardingState.validationFailures,
                        l10n,
                      ),
                      onChanged: notifier.updateLastName,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }
}

String? _firstNameError(
  List<OnboardingValidationFailure> failures,
  AppLocalizations l10n,
) {
  if (failures.contains(OnboardingValidationFailure.firstNameRequired)) {
    return l10n.onboardingFirstNameRequiredError;
  }
  if (failures.contains(OnboardingValidationFailure.firstNameTooShort)) {
    return l10n.onboardingFirstNameTooShortError;
  }
  return null;
}

String? _lastNameError(
  List<OnboardingValidationFailure> failures,
  AppLocalizations l10n,
) {
  if (failures.contains(OnboardingValidationFailure.lastNameRequired)) {
    return l10n.onboardingLastNameRequiredError;
  }
  if (failures.contains(OnboardingValidationFailure.lastNameTooShort)) {
    return l10n.onboardingLastNameTooShortError;
  }
  return null;
}
