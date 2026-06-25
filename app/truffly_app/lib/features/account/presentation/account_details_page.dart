import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/support/european_countries.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_radii.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/account/application/account_details_notifier.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/account/domain/account_details_form_data.dart';
import 'package:truffly_app/features/account/domain/account_details_state.dart';
import 'package:truffly_app/features/account/data/profile_image_service.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_country_options.dart';
import 'package:truffly_app/features/onboarding/presentation/supporting/onboarding_region_options.dart';
import 'package:truffly_app/features/onboarding/presentation/widgets/onboarding_input_field.dart';
import 'package:truffly_app/features/profile/presentation/widgets/seller_avatar.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class AccountDetailsPage extends ConsumerStatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  AccountDetailsFormData? _hydratedForm;
  File? _pendingProfileImageFile;
  bool _isEditingEmail = false;
  bool _isUploadingProfileImage = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(currentUserAccountProfileProvider);
    final state = ref.watch(accountDetailsNotifierProvider);
    final notifier = ref.read(accountDetailsNotifierProvider.notifier);
    final form = state.form;
    final hasStartedSellerJourney = profileAsync.maybeWhen(
      data: (profile) =>
          profile.isSeller || profile.sellerStatus != 'not_requested',
      orElse: () => form?.hasStartedSellerJourney ?? false,
    );

    if (form != null && _hydratedForm != state.initialForm) {
      _hydrateControllers(form);
      _hydratedForm = state.initialForm;
      if (!_isEditingEmail) {
        _emailController.text = form.email;
      }
    }

    final hasProfileChanges = _hasProfileChanges(state);
    final hasEmailChange = _hasEmailChange(state);
    final emailError = _fieldError(
      l10n,
      notifier.errorFor(AccountDetailsField.email),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.account);
              }
            },
          ),
        ),
        title: Text(
          l10n.accountDetailsTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      bottomNavigationBar: form == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingM,
                ),
                child: SizedBox(
                  height: AppSpacing.authControlHeight,
                  child: AuthPrimaryButton(
                    key: const Key('account_save_button'),
                    label: l10n.accountDetailsSaveCta,
                    backgroundColor: AppColors.black,
                    enabled: hasProfileChanges && !state.isSaving,
                    isLoading: state.isSaving,
                    onPressed: hasProfileChanges && !state.isSaving
                        ? _handleProfileSubmit
                        : null,
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : form == null
            ? _AccountDetailsLoadError(
                message: _submitMessage(l10n, state.errorMessage ?? 'unknown'),
                onRetry: () =>
                    ref.read(accountDetailsNotifierProvider.notifier).reload(),
              )
            : SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.spacingM,
                  AppSpacing.spacingS,
                  AppSpacing.spacingM,
                  AppSpacing.spacingXXL,
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.spacingXS),
                        if (form.isSeller) ...[
                          _SellerPhotoSection(
                            form: form,
                            localImageFile: _pendingProfileImageFile,
                            isSaving:
                                state.isSaving || _isUploadingProfileImage,
                            isUploading: _isUploadingProfileImage,
                            initials: _buildInitials(form),
                            onChangePhoto: _handleChangePhoto,
                          ),
                          const SizedBox(height: AppSpacing.spacingM),
                        ],
                        _PlainSectionCard(
                          children: [
                            _SectionField(
                              label: l10n.onboardingFirstNameLabel,
                              child: AuthTextField(
                                key: const Key('account_first_name_field'),
                                controller: _firstNameController,
                                labelText: '',
                                enabled: !state.isSaving,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                onChanged: notifier.updateFirstName,
                                errorText: _fieldError(
                                  l10n,
                                  notifier.errorFor(
                                    AccountDetailsField.firstName,
                                  ),
                                ),
                              ),
                            ),
                            const _SectionDivider(),
                            _SectionField(
                              label: l10n.onboardingLastNameLabel,
                              child: AuthTextField(
                                key: const Key('account_last_name_field'),
                                controller: _lastNameController,
                                labelText: '',
                                enabled: !state.isSaving,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                onChanged: notifier.updateLastName,
                                errorText: _fieldError(
                                  l10n,
                                  notifier.errorFor(
                                    AccountDetailsField.lastName,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.spacingM),
                        _EmailSection(
                          emailController: _emailController,
                          isSaving: state.isSaving,
                          isEditingEmail: _isEditingEmail,
                          isVerified:
                              ref.watch(authNotifierProvider)
                                  is AuthAuthenticatedReady,
                          emailError: emailError,
                          hasEmailChange: hasEmailChange,
                          onStartEdit: () {
                            setState(() {
                              _isEditingEmail = true;
                            });
                          },
                          onCancel: _cancelEmailEdit,
                          onChanged: notifier.updateEmail,
                          onSaveNewEmail: _handleEmailSubmit,
                        ),
                        const SizedBox(height: AppSpacing.spacingM),
                        _PlainSectionCard(
                          children: [
                            _SectionField(
                              label: l10n.onboardingCountryLabel,
                              child: hasStartedSellerJourney
                                  ? _LockedValueField(
                                      value: localizedEuropeanCountryName(
                                        l10n,
                                        'IT',
                                      ),
                                      helperText: l10n
                                          .accountDetailsSellerCountryLockedHelper,
                                    )
                                  : OnboardingDropdownField<String>(
                                      key: const Key('account_country_field'),
                                      initialValue: form.countryCode.isEmpty
                                          ? null
                                          : form.countryCode,
                                      hintText: l10n.onboardingCountryLabel,
                                      errorText: _fieldError(
                                        l10n,
                                        notifier.errorFor(
                                          AccountDetailsField.countryCode,
                                        ),
                                      ),
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: null,
                                          child: Text(
                                            l10n.onboardingCountryPlaceholder,
                                          ),
                                        ),
                                        for (final option in _countryOptionsFor(
                                          form,
                                        ))
                                          DropdownMenuItem<String>(
                                            value: option.code,
                                            child: Text(
                                              localizedEuropeanCountryName(
                                                l10n,
                                                option.code,
                                              ),
                                            ),
                                          ),
                                      ],
                                      onChanged: state.isSaving
                                          ? (_) {}
                                          : (value) => notifier
                                                .updateCountryCode(value ?? ''),
                                    ),
                            ),
                            if (form.requiresRegion) ...[
                              const _SectionDivider(),
                              _SectionField(
                                label: l10n.onboardingRegionLabel,
                                child: OnboardingDropdownField<String>(
                                  key: const Key('account_region_field'),
                                  initialValue: form.region,
                                  hintText: l10n.onboardingRegionLabel,
                                  errorText: _fieldError(
                                    l10n,
                                    notifier.errorFor(
                                      AccountDetailsField.region,
                                    ),
                                  ),
                                  items: [
                                    if (!form.isSeller)
                                      DropdownMenuItem<String>(
                                        value: null,
                                        child: Text(
                                          l10n.onboardingRegionPlaceholder,
                                        ),
                                      ),
                                    for (final option
                                        in onboardingRegionOptions)
                                      DropdownMenuItem<String>(
                                        value: option.value,
                                        child: Text(
                                          _regionLabel(
                                            l10n,
                                            option.localizationKey,
                                          ),
                                        ),
                                      ),
                                  ],
                                  onChanged: state.isSaving
                                      ? (_) {}
                                      : (value) => notifier.updateRegion(value),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (form.isSeller) ...[
                          const SizedBox(height: AppSpacing.spacingM),
                          _PlainSectionCard(
                            children: [
                              _SectionField(
                                label: l10n.accountDetailsBioSectionTitle,
                                child: _CompactTextField(
                                  key: const Key('account_bio_field'),
                                  controller: _bioController,
                                  enabled: !state.isSaving,
                                  maxLines: 5,
                                  hintText: l10n.accountDetailsBioPlaceholder,
                                  textInputAction: TextInputAction.newline,
                                  onChanged: notifier.updateBio,
                                  errorText: _fieldError(
                                    l10n,
                                    notifier.errorFor(AccountDetailsField.bio),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleProfileSubmit() async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(accountDetailsNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final result = await notifier.submitProfileChanges();
    final currentState = ref.read(accountDetailsNotifierProvider);

    if (!mounted) return;

    if (result == null) {
      final errorMessage = currentState.errorMessage;
      final pendingEmail = currentState.form?.email.trim() ?? '';
      if (pendingEmail.isNotEmpty &&
          (errorMessage == 'email_not_verified' || errorMessage == 'unknown')) {
        ref.invalidate(currentUserAccountProfileProvider);
        _showSuccessMessage(l10n.accountDetailsEmailVerificationSent);

        setState(() {
          _isEditingEmail = false;
        });

        context.go(
          AppRoutes.verifyEmailWithPrefill(pendingEmail, manualFlow: true),
        );
        return;
      }

      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_submitMessage(l10n, errorMessage))),
        );
      }
      return;
    }

    ref.invalidate(currentUserAccountProfileProvider);
    _showSuccessMessage(l10n.accountDetailsSaveSuccess);
  }

  Future<void> _handleEmailSubmit() async {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(accountDetailsNotifierProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final result = await notifier.submitEmailChange();
    final currentState = ref.read(accountDetailsNotifierProvider);

    if (!mounted) return;

    if (result == null) {
      final errorMessage = currentState.errorMessage;
      if (errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_submitMessage(l10n, errorMessage))),
        );
      }
      return;
    }

    final newEmail = currentState.form?.email.trim() ?? '';
    ref.invalidate(currentUserAccountProfileProvider);
    _showSuccessMessage(l10n.accountDetailsEmailVerificationSent);

    setState(() {
      _isEditingEmail = false;
    });

    if (newEmail.isNotEmpty) {
      context.go(AppRoutes.verifyEmailWithPrefill(newEmail, manualFlow: true));
    }
  }

  void _cancelEmailEdit() {
    final baseline = ref.read(accountDetailsNotifierProvider).initialForm;
    if (baseline == null) return;

    _emailController.text = baseline.email;
    ref
        .read(accountDetailsNotifierProvider.notifier)
        .updateEmail(baseline.email);
    setState(() {
      _isEditingEmail = false;
    });
  }

  Future<void> _handleChangePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isUploadingProfileImage) return;

    final source = await _showImageSourceSheet(l10n);
    if (!mounted || source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (!mounted || pickedFile == null) return;
      if (pickedFile.path.trim().isEmpty) {
        _showTransientMessage(l10n.accountDetailsPhotoPickerUnavailable);
        return;
      }

      final validationError = await _validateProfileImageSelection(pickedFile);
      if (validationError != null) {
        _showTransientMessage(validationError);
        return;
      }

      setState(() {
        _pendingProfileImageFile = File(pickedFile.path);
        _isUploadingProfileImage = true;
      });

      final service = ref.read(profileImageServiceProvider);
      final previousProfileImageUrl = ref
          .read(accountDetailsNotifierProvider)
          .form
          ?.profileImageUrl;
      final uploadedUrl = await service.uploadProfileImage(
        imageFile: File(pickedFile.path),
        fileName: pickedFile.name,
        contentType: _guessImageMimeType(pickedFile.name),
        previousProfileImageUrl: previousProfileImageUrl,
      );

      if (!mounted) return;

      ref
          .read(accountDetailsNotifierProvider.notifier)
          .syncProfileImageUrl(uploadedUrl);
      ref.invalidate(currentUserAccountProfileProvider);

      setState(() {
        _pendingProfileImageFile = null;
      });

      _showSuccessMessage(l10n.accountDetailsPhotoUploadSuccess);
    } on PlatformException catch (error) {
      if (!mounted) return;
      _handleProfileImageError(error, l10n: l10n, source: source);
    } on ProfileImageUploadException catch (error) {
      if (!mounted) return;
      _showTransientMessage(_profileImageErrorMessage(l10n, error.failure));
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfileImage = false;
          if (_pendingProfileImageFile != null) {
            _pendingProfileImageFile = null;
          }
        });
      }
    }
  }

  Future<String?> _validateProfileImageSelection(XFile pickedFile) async {
    final l10n = AppLocalizations.of(context)!;
    final path = pickedFile.path.trim();
    if (path.isEmpty) {
      return l10n.accountDetailsPhotoPickerUnavailable;
    }

    final file = File(path);
    if (!await file.exists()) {
      return l10n.accountDetailsPhotoFileNotFoundError;
    }

    final length = await file.length();
    if (length > 5 * 1024 * 1024) {
      return l10n.accountDetailsPhotoTooLargeError;
    }

    final extension = _extractFileExtension(pickedFile.name);
    final supportedExtensions = {'jpg', 'jpeg', 'png', 'webp'};
    if (!supportedExtensions.contains(extension)) {
      return l10n.accountDetailsPhotoUnsupportedFormatError;
    }

    return null;
  }

  void _handleProfileImageError(
    PlatformException error, {
    required AppLocalizations l10n,
    required ImageSource source,
  }) {
    final code = error.code.trim().toLowerCase();
    if (code.contains('denied') || code.contains('restricted')) {
      _showTransientMessage(l10n.accountDetailsPhotoPermissionDeniedError);
      return;
    }
    if (source == ImageSource.camera &&
        (code.contains('camera') || code.contains('available'))) {
      _showTransientMessage(l10n.accountDetailsPhotoCameraUnavailableError);
      return;
    }
    if (source == ImageSource.gallery &&
        (code.contains('photo') ||
            code.contains('gallery') ||
            code.contains('available'))) {
      _showTransientMessage(l10n.accountDetailsPhotoGalleryUnavailableError);
      return;
    }
    _showTransientMessage(l10n.accountDetailsPhotoPickerUnavailable);
  }

  String _profileImageErrorMessage(
    AppLocalizations l10n,
    ProfileImageUploadFailure failure,
  ) {
    return switch (failure) {
      ProfileImageUploadFailure.unauthenticated =>
        l10n.accountDetailsSessionExpired,
      ProfileImageUploadFailure.fileTooLarge =>
        l10n.accountDetailsPhotoTooLargeError,
      ProfileImageUploadFailure.unsupportedFormat =>
        l10n.accountDetailsPhotoUnsupportedFormatError,
      ProfileImageUploadFailure.invalidImage =>
        l10n.accountDetailsPhotoInvalidFileError,
      ProfileImageUploadFailure.uploadFailed =>
        l10n.accountDetailsPhotoUploadFailedError,
      ProfileImageUploadFailure.permissionDenied =>
        l10n.accountDetailsPhotoPermissionDeniedError,
      ProfileImageUploadFailure.deleteFailed =>
        l10n.accountDetailsPhotoDeleteFailedError,
      ProfileImageUploadFailure.unknown =>
        l10n.accountDetailsPhotoUploadFailedError,
    };
  }

  String _guessImageMimeType(String fileName) {
    final extension = _extractFileExtension(fileName);
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
  }

  String? _extractFileExtension(String fileName) {
    final trimmed = fileName.trim();
    if (trimmed.isEmpty) return null;

    final dotIndex = trimmed.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == trimmed.length - 1) return null;
    return trimmed.substring(dotIndex + 1).toLowerCase();
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
                  label: l10n.accountDetailsTakePhotoOption,
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                _SheetActionTile(
                  icon: Icons.photo_library_outlined,
                  label: l10n.accountDetailsChooseFromGalleryOption,
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                _SheetActionTile(
                  isLast: true,
                  icon: Icons.close,
                  label: l10n.accountDetailsPhotoSourceCancelOption,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTransientMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF178A42), size: 20),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  bool _hasProfileChanges(AccountDetailsState state) {
    final form = state.form;
    final initialForm = state.initialForm;
    if (form == null || initialForm == null) return false;

    return form
        .copyWith(email: initialForm.email)
        .hasChangesComparedTo(initialForm.copyWith(email: initialForm.email));
  }

  bool _hasEmailChange(AccountDetailsState state) {
    final form = state.form;
    final initialForm = state.initialForm;
    if (form == null || initialForm == null) return false;
    return form.normalized().email != initialForm.normalized().email;
  }

  void _hydrateControllers(AccountDetailsFormData form) {
    _firstNameController.text = form.firstName;
    _lastNameController.text = form.lastName;
    _emailController.text = form.email;
    _bioController.text = form.bio ?? '';
  }

  String _buildInitials(AccountDetailsFormData form) {
    final parts = [
      form.firstName.trim(),
      form.lastName.trim(),
    ].where((value) => value.isNotEmpty).toList();

    if (parts.isNotEmpty) {
      return parts.take(2).map((value) => value[0].toUpperCase()).join();
    }

    final email = form.email.trim();
    return email.isEmpty ? 'T' : email[0].toUpperCase();
  }
}

class _SellerPhotoSection extends StatelessWidget {
  const _SellerPhotoSection({
    required this.form,
    required this.localImageFile,
    required this.isSaving,
    required this.isUploading,
    required this.initials,
    required this.onChangePhoto,
  });

  final AccountDetailsFormData form;
  final File? localImageFile;
  final bool isSaving;
  final bool isUploading;
  final String initials;
  final Future<void> Function() onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _PlainSectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingS),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isSaving ? null : onChangePhoto,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _ProfileImagePreview(
                          networkImageUrl: form.profileImageUrl,
                          localImageFile: localImageFile,
                          initials: initials,
                          size: 52,
                          showOverlay: false,
                        ),
                        const SizedBox(width: AppSpacing.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.accountDetailsChangePhotoCta,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              if (isUploading) ...[
                                const SizedBox(height: 2),
                                Text(
                                  l10n.accountDetailsPhotoUploadPending,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.black80,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.spacingXS),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.black50,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailSection extends StatelessWidget {
  const _EmailSection({
    required this.emailController,
    required this.isSaving,
    required this.isEditingEmail,
    required this.isVerified,
    required this.emailError,
    required this.hasEmailChange,
    required this.onStartEdit,
    required this.onCancel,
    required this.onChanged,
    required this.onSaveNewEmail,
  });

  final TextEditingController emailController;
  final bool isSaving;
  final bool isEditingEmail;
  final bool isVerified;
  final String? emailError;
  final bool hasEmailChange;
  final VoidCallback onStartEdit;
  final VoidCallback onCancel;
  final ValueChanged<String> onChanged;
  final Future<void> Function() onSaveNewEmail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _PlainSectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: AppSpacing.spacingS,
                runSpacing: AppSpacing.spacingXS,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    emailController.text.trim(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _VerificationBadge(
                    label: isVerified
                        ? l10n.accountDetailsEmailVerified
                        : l10n.authVerifyEmailNotYetVerified,
                    isVerified: isVerified,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacingS),
              Text(
                l10n.accountDetailsEmailHelper,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.black80,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              if (isEditingEmail) ...[
                _CompactTextField(
                  key: const Key('account_email_field'),
                  controller: emailController,
                  enabled: !isSaving,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.singleLineFormatter,
                  ],
                  onChanged: onChanged,
                  errorText: emailError,
                ),
                const SizedBox(height: AppSpacing.spacingS),
                AuthPrimaryButton(
                  label: l10n.accountDetailsSaveNewEmailCta,
                  backgroundColor: AppColors.black,
                  enabled: hasEmailChange && emailError == null && !isSaving,
                  isLoading: isSaving,
                  onPressed: hasEmailChange && emailError == null && !isSaving
                      ? onSaveNewEmail
                      : null,
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Center(
                  child: TextButton(
                    onPressed: isSaving ? null : onCancel,
                    child: Text(l10n.accountDetailsCancelEmailChangeCta),
                  ),
                ),
              ] else
                _SecondaryActionButton(
                  label: l10n.accountDetailsChangeEmailCta,
                  onPressed: isSaving ? null : onStartEdit,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionField extends StatelessWidget {
  const _SectionField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.micro.copyWith(
              color: AppColors.black50,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: AppSpacing.spacingXS),
          child,
        ],
      ),
    );
  }
}

class _PlainSectionCard extends StatelessWidget {
  const _PlainSectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F151618),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.authControlHeight),
          foregroundColor: AppColors.black,
          side: const BorderSide(color: AppColors.black20),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadii.authBorderRadius,
          ),
          textStyle: AppTextStyles.buttonText,
        ),
        child: Text(label),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.black10);
  }
}

class _CompactTextField extends StatelessWidget {
  const _CompactTextField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onChanged,
    this.errorText,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.accent,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.fieldLabel,
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacingM,
          vertical: AppSpacing.spacingM,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.black20),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.black20),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.black20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        errorText: errorText,
      ),
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({
    required this.networkImageUrl,
    required this.localImageFile,
    required this.initials,
    this.size = 176,
    this.showOverlay = true,
  });

  final String? networkImageUrl;
  final File? localImageFile;
  final String initials;
  final double size;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: localImageFile != null
                ? Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(localImageFile!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SellerAvatar(
                    imageUrl: networkImageUrl,
                    initials: initials,
                    size: size,
                  ),
          ),
          if (showOverlay)
            Positioned(
              right: 8,
              bottom: 10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.black,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.label, required this.isVerified});

  final String label;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    const verifiedGreen = Color(0xFF178A42);
    final color = isVerified ? verifiedGreen : AppColors.black50;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingS,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFE9F8EF) : AppColors.softGrey,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.info_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedValueField extends StatelessWidget {
  const _LockedValueField({required this.value, this.helperText});

  final String value;
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppColors.softGrey.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.black10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.bodyLarge),
          if (helperText != null) ...[
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              helperText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black80),
            ),
          ],
        ],
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
                Expanded(child: Text(label, style: AppTextStyles.bodyLarge)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountDetailsLoadError extends StatelessWidget {
  const _AccountDetailsLoadError({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            AuthPrimaryButton(
              label: l10n.truffleRetry,
              backgroundColor: AppColors.accent,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

List<OnboardingCountryOption> _countryOptionsFor(AccountDetailsFormData form) {
  if (form.isSeller) {
    return onboardingCountryOptions
        .where((option) => option.code == 'IT')
        .toList();
  }
  return onboardingCountryOptions;
}

String? _fieldError(AppLocalizations l10n, String? code) {
  if (code == null) return null;

  return switch (code) {
    'required' => l10n.accountDetailsRequiredFieldError,
    'email_required' => l10n.emailRequired,
    'invalid_email' => l10n.invalidEmail,
    'country_required' => l10n.onboardingCountryRequiredError,
    'country_invalid' => l10n.onboardingCountryInvalidError,
    'seller_country_invalid' => l10n.accountDetailsSellerCountryError,
    'region_required' => l10n.onboardingRegionRequiredError,
    'invalid_image_url' => l10n.accountDetailsInvalidImageUrlError,
    _ => l10n.authErrorUnknown,
  };
}

String _submitMessage(AppLocalizations l10n, String code) {
  return switch (code) {
    'network' => l10n.authErrorNetwork,
    'timeout' => l10n.authErrorTimeout,
    'rate_limited' => l10n.authErrorEmailResendRateLimited,
    'delivery_restricted' => l10n.authErrorEmailDeliveryRestricted,
    'email_already_used' => l10n.authErrorEmailAlreadyUsed,
    'invalid_credentials' => l10n.authErrorInvalidCredentials,
    'unauthenticated' => l10n.accountDetailsSessionExpired,
    'email_not_verified' => l10n.accountDetailsEmailVerificationSent,
    'profile_missing' => l10n.accountDetailsLoadError,
    _ => l10n.accountDetailsSaveError,
  };
}

String _regionLabel(AppLocalizations l10n, String localizationKey) {
  return switch (localizationKey) {
    'onboardingRegionAbruzzo' => l10n.onboardingRegionAbruzzo,
    'onboardingRegionBasilicata' => l10n.onboardingRegionBasilicata,
    'onboardingRegionCalabria' => l10n.onboardingRegionCalabria,
    'onboardingRegionCampania' => l10n.onboardingRegionCampania,
    'onboardingRegionEmiliaRomagna' => l10n.onboardingRegionEmiliaRomagna,
    'onboardingRegionFriuliVeneziaGiulia' =>
      l10n.onboardingRegionFriuliVeneziaGiulia,
    'onboardingRegionLazio' => l10n.onboardingRegionLazio,
    'onboardingRegionLiguria' => l10n.onboardingRegionLiguria,
    'onboardingRegionLombardia' => l10n.onboardingRegionLombardia,
    'onboardingRegionMarche' => l10n.onboardingRegionMarche,
    'onboardingRegionMolise' => l10n.onboardingRegionMolise,
    'onboardingRegionPiemonte' => l10n.onboardingRegionPiemonte,
    'onboardingRegionPuglia' => l10n.onboardingRegionPuglia,
    'onboardingRegionSardegna' => l10n.onboardingRegionSardegna,
    'onboardingRegionSicilia' => l10n.onboardingRegionSicilia,
    'onboardingRegionToscana' => l10n.onboardingRegionToscana,
    'onboardingRegionTrentinoAltoAdige' =>
      l10n.onboardingRegionTrentinoAltoAdige,
    'onboardingRegionUmbria' => l10n.onboardingRegionUmbria,
    'onboardingRegionValleDaosta' => l10n.onboardingRegionValleDaosta,
    'onboardingRegionVeneto' => l10n.onboardingRegionVeneto,
    _ => localizationKey,
  };
}
