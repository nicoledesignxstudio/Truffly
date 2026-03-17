import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_block.dart';
import 'package:truffly_app/features/onboarding/application/onboarding_providers.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_draft.dart';
import 'package:truffly_app/features/onboarding/domain/onboarding_validation_failure.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class SellerDocumentsPage extends ConsumerStatefulWidget {
  const SellerDocumentsPage({super.key});

  @override
  ConsumerState<SellerDocumentsPage> createState() =>
      _SellerDocumentsPageState();
}

class _SellerDocumentsPageState extends ConsumerState<SellerDocumentsPage> {
  static const _supportedExtensions = {'png', 'jpg', 'jpeg'};

  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _tesserinoNumberController;
  late final FocusNode _tesserinoNumberFocusNode;
  late final ProviderSubscription<String> _tesserinoNumberSubscription;
  String? _identityDocumentError;
  String? _tesserinoDocumentError;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(onboardingNotifierProvider);
    _tesserinoNumberFocusNode = FocusNode();
    _tesserinoNumberController = TextEditingController(
      text: initialState.draft.tesserinoNumber,
    );
    _tesserinoNumberSubscription = ref.listenManual<String>(
      onboardingNotifierProvider.select((state) => state.draft.tesserinoNumber),
      (_, next) => _syncController(next),
    );
  }

  @override
  void dispose() {
    _tesserinoNumberSubscription.close();
    _tesserinoNumberFocusNode.dispose();
    _tesserinoNumberController.dispose();
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
                        l10n.onboardingSellerDocumentsTitle,
                        style: AppTextStyles.authScreenTitle,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    AuthTextBlock(
                      alignment: Alignment.centerLeft,
                      maxWidth: 440,
                      child: Text(
                        l10n.onboardingSellerDocumentsSubtitle,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.black80,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.authGroupGap),
                    OnboardingTextField(
                      controller: _tesserinoNumberController,
                      focusNode: _tesserinoNumberFocusNode,
                      textInputAction: TextInputAction.done,
                      hintText: l10n.onboardingTesserinoNumberLabel,
                      errorText: onboardingState.validationFailures.contains(
                        OnboardingValidationFailure.tesserinoNumberRequired,
                      )
                          ? l10n.onboardingTesserinoNumberRequiredError
                          : null,
                      onChanged: notifier.updateTesserinoNumber,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    _DocumentSelectorCard(
                      title: l10n.onboardingIdentityDocumentTitle,
                      selectedDocument: onboardingState.draft.identityDocument,
                      pickLabel: onboardingState.draft.identityDocument == null
                          ? l10n.onboardingDocumentPickButton
                          : l10n.onboardingDocumentReplaceButton,
                      removeLabel: l10n.onboardingDocumentRemoveButton,
                      errorText: _identityDocumentError ??
                          (onboardingState.validationFailures.contains(
                            OnboardingValidationFailure.identityDocumentRequired,
                          )
                              ? l10n.onboardingIdentityDocumentRequiredError
                              : null),
                      onPickPressed: () => _pickDocument(_DocumentSlot.identity),
                      onRemovePressed:
                          onboardingState.draft.identityDocument == null
                          ? null
                          : () {
                              _clearDocumentError(_DocumentSlot.identity);
                              notifier.clearIdentityDocument();
                            },
                    ),
                    const SizedBox(height: AppSpacing.authFieldGap),
                    _DocumentSelectorCard(
                      title: l10n.onboardingTesserinoDocumentTitle,
                      selectedDocument: onboardingState.draft.tesserinoDocument,
                      pickLabel: onboardingState.draft.tesserinoDocument == null
                          ? l10n.onboardingDocumentPickButton
                          : l10n.onboardingDocumentReplaceButton,
                      removeLabel: l10n.onboardingDocumentRemoveButton,
                      errorText: _tesserinoDocumentError ??
                          (onboardingState.validationFailures.contains(
                            OnboardingValidationFailure.tesserinoDocumentRequired,
                          )
                              ? l10n.onboardingTesserinoDocumentRequiredError
                              : null),
                      onPickPressed: () => _pickDocument(_DocumentSlot.tesserino),
                      onRemovePressed:
                          onboardingState.draft.tesserinoDocument == null
                          ? null
                          : () {
                              _clearDocumentError(_DocumentSlot.tesserino);
                              notifier.clearTesserinoDocument();
                            },
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

  void _syncController(String value) {
    if (_tesserinoNumberController.text == value) return;
    _tesserinoNumberController.value = _tesserinoNumberController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  Future<void> _pickDocument(_DocumentSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(onboardingNotifierProvider.notifier);
    final source = await _showDocumentSourceSheet(l10n);
    if (!mounted || source == null) {
      return;
    }

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (!mounted || pickedFile == null) {
        return;
      }

      final path = pickedFile.path;
      if (path.trim().isEmpty) {
        _setDocumentError(slot, l10n.onboardingDocumentFileNotFoundError);
        return;
      }

      final extension = _extractExtension(path);
      if (!_supportedExtensions.contains(extension)) {
        _setDocumentError(slot, l10n.onboardingDocumentUnsupportedFormatError);
        return;
      }

      final localFile = File(path);
      if (!await localFile.exists()) {
        _setDocumentError(slot, l10n.onboardingDocumentFileNotFoundError);
        return;
      }

      final length = await localFile.length();
      if (length <= 0) {
        _setDocumentError(slot, l10n.onboardingDocumentEmptyFileError);
        return;
      }

      _clearDocumentError(slot);

      final document = OnboardingLocalDocument(
        localPath: path,
        fileName: pickedFile.name,
      );

      if (slot == _DocumentSlot.identity) {
        notifier.setIdentityDocument(document);
      } else {
        notifier.setTesserinoDocument(document);
      }
    } on PlatformException catch (error) {
      _setDocumentError(slot, _platformErrorMessage(source, error, l10n));
    } on Exception {
      _setDocumentError(slot, l10n.onboardingDocumentPickerUnavailableError);
    }
  }

  Future<ImageSource?> _showDocumentSourceSheet(AppLocalizations l10n) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.auth)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                _SheetActionTile(
                  isFirst: true,
                  icon: Icons.photo_camera_outlined,
                  label: l10n.onboardingDocumentTakePhotoOption,
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                _SheetActionTile(
                  icon: Icons.photo_library_outlined,
                  label: l10n.onboardingDocumentChooseFromGalleryOption,
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                _SheetActionTile(
                  isLast: true,
                  icon: Icons.close,
                  label: l10n.onboardingDocumentSourceCancelOption,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _extractExtension(String path) {
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == path.length - 1) {
      return '';
    }
    return path.substring(lastDotIndex + 1).toLowerCase();
  }

  void _setDocumentError(_DocumentSlot slot, String message) {
    if (!mounted) return;
    setState(() {
      if (slot == _DocumentSlot.identity) {
        _identityDocumentError = message;
      } else {
        _tesserinoDocumentError = message;
      }
    });
  }

  void _clearDocumentError(_DocumentSlot slot) {
    if (!mounted) return;
    setState(() {
      if (slot == _DocumentSlot.identity) {
        _identityDocumentError = null;
      } else {
        _tesserinoDocumentError = null;
      }
    });
  }

  String _platformErrorMessage(
    ImageSource source,
    PlatformException error,
    AppLocalizations l10n,
  ) {
    final code = error.code.trim().toLowerCase();
    if (code.contains('denied') || code.contains('restricted')) {
      return l10n.onboardingDocumentPermissionDeniedError;
    }
    if (source == ImageSource.camera &&
        (code.contains('camera') || code.contains('available'))) {
      return l10n.onboardingDocumentCameraUnavailableError;
    }
    if (source == ImageSource.gallery &&
        (code.contains('photo') ||
            code.contains('gallery') ||
            code.contains('available'))) {
      return l10n.onboardingDocumentGalleryUnavailableError;
    }
    return l10n.onboardingDocumentPickerUnavailableError;
  }
}

enum _DocumentSlot {
  identity,
  tesserino,
}

class _DocumentSelectorCard extends StatelessWidget {
  const _DocumentSelectorCard({
    required this.title,
    required this.selectedDocument,
    required this.pickLabel,
    required this.removeLabel,
    required this.onPickPressed,
    this.onRemovePressed,
    this.errorText,
  });

  final String title;
  final OnboardingLocalDocument? selectedDocument;
  final String pickLabel;
  final String removeLabel;
  final Future<void> Function() onPickPressed;
  final VoidCallback? onRemovePressed;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadii.authBorderRadius,
        boxShadow: AppShadows.authField,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.black10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPickPressed,
                borderRadius: AppRadii.authBorderRadius,
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: AppRadii.authBorderRadius,
                    border: Border.all(color: AppColors.black10),
                  ),
                  child: CustomPaint(
                    painter: _DashedBorderPainter(),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.spacingM),
                      child: Column(
                        children: [
                          Icon(
                            selectedDocument == null
                                ? Icons.upload_file_outlined
                                : Icons.image_outlined,
                            color: AppColors.accent,
                            size: 28,
                          ),
                          const SizedBox(height: AppSpacing.spacingS),
                          Text(
                            selectedDocument?.fileName ??
                                title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: AppSpacing.spacingXS),
                          Text(
                            pickLabel,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.black50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (errorText != null) ...[
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            if (selectedDocument != null && onRemovePressed != null) ...[
              const SizedBox(height: AppSpacing.spacingXS),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onRemovePressed,
                  child: Text(removeLabel),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isFirst ? AppRadii.auth : 0),
        bottom: Radius.circular(isLast ? AppRadii.auth : 0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? AppRadii.auth : 0),
          bottom: Radius.circular(isLast ? AppRadii.auth : 0),
        ),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(isFirst ? AppRadii.auth : 0),
              bottom: Radius.circular(isLast ? AppRadii.auth : 0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D151618),
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: isFirst ? Colors.transparent : AppColors.black10,
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

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = Radius.circular(AppRadii.auth);
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    final borderPaint = Paint()
      ..color = AppColors.black20
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next),
          borderPaint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
