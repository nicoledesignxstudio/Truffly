import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_providers.dart';
import 'package:truffly_app/features/truffle/application/publish_truffle_notifier.dart';
import 'package:truffly_app/features/truffle/data/publish_truffle_image_validation_service.dart';
import 'package:truffly_app/features/truffle/domain/italian_region.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_state.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_submission_failure.dart';
import 'package:truffly_app/features/truffle/domain/publish_truffle_validation_failure.dart';
import 'package:truffly_app/features/truffle/domain/truffle_harvest_date_bounds.dart';
import 'package:truffly_app/features/truffle/domain/truffle_quality.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/publish_truffle_image_section.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/publish_truffle_pricing_section.dart';
import 'package:truffly_app/features/truffle/presentation/widgets/truffle_ui_formatters.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

Route<bool> buildPublishTruffleRoute({String? initialRegion}) {
  return PageRouteBuilder<bool>(
    fullscreenDialog: true,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return PublishTrufflePage(initialRegion: initialRegion);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      );
    },
  );
}

class PublishTrufflePage extends ConsumerStatefulWidget {
  const PublishTrufflePage({
    super.key,
    this.initialRegion,
  });

  final String? initialRegion;

  @override
  ConsumerState<PublishTrufflePage> createState() => _PublishTrufflePageState();
}

class _PublishTrufflePageState extends ConsumerState<PublishTrufflePage> {
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _latinNameController;
  late final TextEditingController _harvestDateController;
  late final TextEditingController _weightController;
  late final TextEditingController _priceController;
  late final TextEditingController _shippingItalyController;
  late final TextEditingController _shippingAbroadController;

  @override
  void initState() {
    super.initState();
    _latinNameController = TextEditingController();
    _harvestDateController = TextEditingController();
    _weightController = TextEditingController();
    _priceController = TextEditingController();
    _shippingItalyController = TextEditingController();
    _shippingAbroadController = TextEditingController();

    Future.microtask(() {
      ref
          .read(publishTruffleNotifierProvider.notifier)
          .initialize(defaultRegion: widget.initialRegion);
    });
  }

  @override
  void dispose() {
    _latinNameController.dispose();
    _harvestDateController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _shippingItalyController.dispose();
    _shippingAbroadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(publishTruffleNotifierProvider);
    final notifier = ref.read(publishTruffleNotifierProvider.notifier);

    _syncController(_latinNameController, state.latinName);
    _syncController(
      _harvestDateController,
      state.harvestDate == null ? '' : formatShortDate(context, state.harvestDate!),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.publishTruffleTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            AppSpacing.spacingS,
            AppSpacing.spacingM,
            AppSpacing.spacingL,
          ),
          children: [
            PublishTruffleImageSection(
              title: l10n.publishTrufflePhotosTitle,
              subtitle: l10n.publishTrufflePhotosSubtitle,
              addPhotoLabel: l10n.publishTruffleAddPhoto,
              removePhotoLabel: l10n.publishTruffleRemovePhoto,
              images: state.images,
              errorText: _imageErrorText(l10n, state),
              onAddPressed: _handleAddImage,
              onRemovePressed: notifier.removeImageAt,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            _SectionTitle(title: l10n.publishTruffleQualityLabel),
            const SizedBox(height: AppSpacing.spacingS),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var index = 0; index < TruffleQuality.values.length; index++) ...[
                    if (index > 0) const SizedBox(width: AppSpacing.spacingXS),
                    _PublishChoiceChip(
                      label: TruffleQuality.values[index].choiceLabel(l10n),
                      selected: state.quality == TruffleQuality.values[index],
                      onTap: () => notifier.updateQuality(TruffleQuality.values[index]),
                    ),
                  ],
                ],
              ),
            ),
            if (_qualityErrorText(l10n, state) != null) ...[
              const SizedBox(height: AppSpacing.spacingXS),
              Text(
                _qualityErrorText(l10n, state)!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spacingL),
            _SectionTitle(title: l10n.publishTruffleTypeLabel),
            const SizedBox(height: AppSpacing.spacingS),
            OnboardingDropdownField<TruffleType>(
              initialValue: state.truffleType,
              hintText: l10n.publishTruffleTypePlaceholder,
              errorText: _typeErrorText(l10n, state),
              items: [
                DropdownMenuItem<TruffleType>(
                  value: null,
                  child: Text(l10n.publishTruffleTypePlaceholder),
                ),
                for (final type in TruffleType.valuesInUiOrder)
                  DropdownMenuItem<TruffleType>(
                    value: type,
                    child: Text(type.localizedName(l10n)),
                  ),
              ],
              onChanged: notifier.updateTruffleType,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthTextField(
              controller: _latinNameController,
              labelText: l10n.publishTruffleLatinNameLabel,
              readOnly: true,
            ),
            const SizedBox(height: AppSpacing.spacingL),
            _SectionTitle(title: l10n.publishTrufflePricingTitle),
            const SizedBox(height: AppSpacing.spacingS),
            PublishTrufflePricingSection(
              weightController: _weightController,
              totalPriceController: _priceController,
              shippingItalyController: _shippingItalyController,
              shippingAbroadController: _shippingAbroadController,
              weightLabel: l10n.publishTruffleWeightLabel,
              totalPriceLabel: l10n.publishTruffleTotalPriceLabel,
              shippingItalyLabel: l10n.publishTruffleShippingItalyLabel,
              shippingAbroadLabel: l10n.publishTruffleShippingAbroadLabel,
              shippingTitle: 'Shipping',
              previewLabel: l10n.publishTrufflePricePerKgPreviewLabel,
              previewValue: state.pricePerKgPreview == null
                  ? l10n.publishTrufflePricePerKgPreviewPlaceholder
                  : formatEuro(state.pricePerKgPreview!),
              onWeightChanged: notifier.updateWeightInput,
              onTotalPriceChanged: notifier.updatePriceInput,
              onShippingItalyChanged: notifier.updateShippingItalyInput,
              onShippingAbroadChanged: notifier.updateShippingAbroadInput,
              weightErrorText: _weightErrorText(l10n, state),
              totalPriceErrorText: _totalPriceErrorText(l10n, state),
              shippingItalyErrorText: _shippingItalyErrorText(l10n, state),
              shippingAbroadErrorText: _shippingAbroadErrorText(l10n, state),
            ),
            const SizedBox(height: AppSpacing.spacingL),
            _SectionTitle(title: l10n.publishTruffleRegionLabel),
            const SizedBox(height: AppSpacing.spacingS),
            OnboardingDropdownField<String>(
              initialValue: state.region,
              hintText: l10n.publishTruffleRegionPlaceholder,
              errorText: _regionErrorText(l10n, state),
              items: [
                DropdownMenuItem<String>(
                  value: null,
                  child: Text(l10n.publishTruffleRegionPlaceholder),
                ),
                for (final region in ItalianRegions.values)
                  DropdownMenuItem<String>(
                    value: region,
                    child: Text(ItalianRegions.localizedLabel(l10n, region)),
                  ),
              ],
              onChanged: notifier.updateRegion,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthTextField(
              controller: _harvestDateController,
              labelText: l10n.publishTruffleHarvestDateLabel,
              readOnly: true,
              onTap: () => _handlePickHarvestDate(),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              errorText: _harvestDateErrorText(l10n, state),
            ),
            if (state.submitFailure != null) ...[
              const SizedBox(height: AppSpacing.spacingM),
              Text(
                _submitFailureText(l10n, state.submitFailure!),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.spacingXL),
            AuthPrimaryButton(
              label: l10n.publishTruffleCta,
              isLoading: state.isSubmitting,
              onPressed: () => _handlePublishPressed(),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _handleAddImage() async {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.read(publishTruffleNotifierProvider);
    if (state.hasReachedImageLimit) return;

    final source = await _showImageSourceSheet(l10n);
    if (!mounted || source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
      );
      if (!mounted || pickedFile == null) return;

      final preparedImage = await ref
          .read(publishTruffleImageValidationServiceProvider)
          .prepareSelectedImage(pickedFile);

      ref.read(publishTruffleNotifierProvider.notifier).addImages([
        preparedImage,
      ]);
    } on PlatformException {
      _showTransientMessage(l10n.publishTruffleImagePickerUnavailable);
    } on PublishTruffleImagePreparationException catch (error) {
      _showTransientMessage(_imagePreparationErrorText(l10n, error.failure));
    } on Exception {
      _showTransientMessage(l10n.publishTruffleImagePickerUnavailable);
    }
  }

  Future<void> _handlePickHarvestDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate =
        ref.read(publishTruffleNotifierProvider).harvestDate ?? today;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(today) ? today : initialDate,
      firstDate: TruffleHarvestDateBounds.earliestAllowedDate,
      lastDate: today,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.white,
              surfaceTintColor: AppColors.white,
              cancelButtonStyle: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingS,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.authBorderRadius,
                ),
                foregroundColor: AppColors.black,
                backgroundColor: AppColors.softGrey,
              ),
              confirmButtonStyle: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.spacingM,
                  vertical: AppSpacing.spacingS,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.authBorderRadius,
                ),
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.accent,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingS),
            child: child!,
          ),
        );
      },
    );

    if (!mounted || pickedDate == null) return;
    ref.read(publishTruffleNotifierProvider.notifier).updateHarvestDate(pickedDate);
  }

  Future<void> _handlePublishPressed() async {
    final notifier = ref.read(publishTruffleNotifierProvider.notifier);
    notifier.clearSubmitFailure();
    if (!notifier.revealValidationErrors()) {
      return;
    }

    final shouldPublish = await showDialog<bool>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          insetPadding: const EdgeInsets.all(AppSpacing.spacingM),
          titlePadding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            30,
            AppSpacing.spacingM,
            8,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            0,
            AppSpacing.spacingM,
            20,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.spacingM,
            0,
            AppSpacing.spacingM,
            30,
          ),
          title: Text(
            l10n.publishTruffleConfirmTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            l10n.publishTruffleConfirmMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.black80,
            ),
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AuthPrimaryButton(
                  label: l10n.publishTruffleConfirmAction,
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: AppSpacing.spacingS),
                AuthSecondaryButton(
                  label: l10n.publishTruffleCancelAction,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (shouldPublish != true || !mounted) return;

    final didPublish = await notifier.submit();
    if (!mounted) return;
    if (didPublish) {
      Navigator.of(context).pop(true);
    }
  }

  Future<ImageSource?> _showImageSourceSheet(AppLocalizations l10n) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.auth),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacingM,
              AppSpacing.spacingS,
              AppSpacing.spacingM,
              AppSpacing.spacingM,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.black20,
                    borderRadius: AppRadii.circularBorderRadius,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacingM),
                _ImageSourceActionTile(
                  icon: Icons.photo_camera_outlined,
                  label: l10n.publishTruffleTakePhoto,
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                _ImageSourceActionTile(
                  icon: Icons.photo_library_outlined,
                  label: l10n.publishTruffleChooseFromGallery,
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                _ImageSourceActionTile(
                  icon: Icons.close_rounded,
                  label: l10n.publishTruffleCancelAction,
                  isLast: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
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

  void _showTransientMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _imagePreparationErrorText(
    AppLocalizations l10n,
    PublishTruffleImagePreparationFailure failure,
  ) {
    return switch (failure) {
      PublishTruffleImagePreparationFailure.unsupportedFormat =>
        l10n.publishTruffleValidationImageFormat,
      PublishTruffleImagePreparationFailure.missingFile =>
        l10n.publishTruffleValidationImageMissing,
      PublishTruffleImagePreparationFailure.tooLarge =>
        l10n.publishTruffleValidationImageTooLarge,
      PublishTruffleImagePreparationFailure.processingFailed =>
        l10n.publishTruffleValidationImageProcessingFailed,
    };
  }

  String? _imageErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.imagesRequired,
    )) {
      return l10n.publishTruffleValidationImagesRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.imagesTooMany,
    )) {
      return l10n.publishTruffleValidationImagesTooMany;
    }
    return null;
  }

  String? _qualityErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.qualityRequired,
    )) {
      return l10n.publishTruffleValidationQualityRequired;
    }
    return null;
  }

  String? _typeErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.typeRequired,
    )) {
      return l10n.publishTruffleValidationTypeRequired;
    }
    return null;
  }

  String? _weightErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.weightRequired,
    )) {
      return l10n.publishTruffleValidationWeightRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.weightInvalid,
    )) {
      return l10n.publishTruffleValidationWeightInvalid;
    }
    return null;
  }

  String? _totalPriceErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.totalPriceRequired,
    )) {
      return l10n.publishTruffleValidationPriceRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.totalPriceInvalid,
    )) {
      return l10n.publishTruffleValidationPriceInvalid;
    }
    return null;
  }

  String? _shippingItalyErrorText(
    AppLocalizations l10n,
    PublishTruffleState state,
  ) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.shippingItalyRequired,
    )) {
      return l10n.publishTruffleValidationShippingItalyRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.shippingItalyInvalid,
    )) {
      return l10n.publishTruffleValidationShippingItalyInvalid;
    }
    return null;
  }

  String? _shippingAbroadErrorText(
    AppLocalizations l10n,
    PublishTruffleState state,
  ) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.shippingAbroadRequired,
    )) {
      return l10n.publishTruffleValidationShippingAbroadRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.shippingAbroadInvalid,
    )) {
      return l10n.publishTruffleValidationShippingAbroadInvalid;
    }
    return null;
  }

  String? _regionErrorText(AppLocalizations l10n, PublishTruffleState state) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.regionRequired,
    )) {
      return l10n.publishTruffleValidationRegionRequired;
    }
    return null;
  }

  String? _harvestDateErrorText(
    AppLocalizations l10n,
    PublishTruffleState state,
  ) {
    if (!state.showValidationErrors) return null;
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.harvestDateRequired,
    )) {
      return l10n.publishTruffleValidationHarvestDateRequired;
    }
    if (state.validationFailures.contains(
      PublishTruffleValidationFailure.harvestDateFuture,
    )) {
      return l10n.publishTruffleValidationHarvestDateFuture;
    }
    return null;
  }

  String _submitFailureText(
    AppLocalizations l10n,
    PublishTruffleSubmissionFailure failure,
  ) {
    return switch (failure) {
      PublishTruffleSubmissionFailure.unauthenticated =>
        l10n.publishTruffleSubmitUnauthenticated,
      PublishTruffleSubmissionFailure.notAllowed =>
        l10n.publishTruffleSubmitNotAllowed,
      PublishTruffleSubmissionFailure.validation =>
        l10n.publishTruffleSubmitValidation,
      PublishTruffleSubmissionFailure.invalidImage =>
        l10n.publishTruffleSubmitInvalidImage,
      PublishTruffleSubmissionFailure.network =>
        l10n.publishTruffleSubmitNetwork,
      PublishTruffleSubmissionFailure.imageUpload =>
        l10n.publishTruffleSubmitImageUpload,
      PublishTruffleSubmissionFailure.unknown =>
        l10n.publishTruffleSubmitUnknown,
    };
  }
}

class _PublishChoiceChip extends StatelessWidget {
  const _PublishChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? AppColors.black : AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        border: Border.all(
          color: selected ? AppColors.black : AppColors.black10,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.black10,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadii.authBorderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM + 2,
              vertical: AppSpacing.spacingS,
            ),
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: selected ? AppColors.white : AppColors.black80,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.sectionTitle,
    );
  }
}

class _ImageSourceActionTile extends StatelessWidget {
  const _ImageSourceActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D151618),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : AppColors.black10,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacingM,
              vertical: AppSpacing.spacingM,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.black),
                const SizedBox(width: AppSpacing.spacingS),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
