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
    final state = ref.watch(accountDetailsNotifierProvider);
    final notifier = ref.read(accountDetailsNotifierProvider.notifier);
    final form = state.form;

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
                child: AuthPrimaryButton(
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
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : form == null
                ? _AccountDetailsLoadError(
                    message: _submitMessage(
                      l10n,
                      state.errorMessage ?? 'unknown',
                    ),
                    onRetry: () => ref
                        .read(accountDetailsNotifierProvider.notifier)
                        .reload(),
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
                            Text(
                              l10n.accountDetailsSubtitle,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.black80,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacingL),
                            if (form.isSeller) ...[
                              _SellerPhotoSection(
                                form: form,
                                localImageFile: _pendingProfileImageFile,
                                isSaving: state.isSaving,
                                initials: _buildInitials(form),
                                onChangePhoto: _handleChangePhoto,
                                onRemovePhoto: _handleRemovePhoto,
                              ),
                              const SizedBox(height: AppSpacing.spacingM),
                            ],
                            _PlainSectionCard(
                              children: [
                                _SectionField(
                                  label: l10n.onboardingFirstNameLabel,
                                  child: AuthTextField(
                                    controller: _firstNameController,
                                    labelText: '',
                                    enabled: !state.isSaving,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
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
                                    controller: _lastNameController,
                                    labelText: '',
                                    enabled: !state.isSaving,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
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
                                  child: form.isSeller
                                      ? _LockedValueField(
                                          value: localizedEuropeanCountryName(
                                            l10n,
                                            'IT',
                                          ),
                                          helperText: l10n
                                              .accountDetailsSellerCountryLockedHelper,
                                        )
                                      : OnboardingDropdownField<String>(
                                          initialValue: form.countryCode.isEmpty
                                              ? null
                                              : form.countryCode,
                                          hintText:
                                              l10n.onboardingCountryLabel,
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
                                                l10n
                                                    .onboardingCountryPlaceholder,
                                              ),
                                            ),
                                            for (final option
                                                in _countryOptionsFor(form))
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
                                                    .updateCountryCode(
                                                      value ?? '',
                                                    ),
                                        ),
                                ),
                                const _SectionDivider(),
                                _SectionField(
                                  label: l10n.onboardingRegionLabel,
                                  child: form.requiresRegion
                                      ? OnboardingDropdownField<String>(
                                          initialValue: form.region,
                                          hintText:
                                              l10n.onboardingRegionLabel,
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
                                                  l10n
                                                      .onboardingRegionPlaceholder,
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
                                              : (value) => notifier
                                                    .updateRegion(value),
                                        )
                                      : _LockedValueField(
                                          value: l10n
                                              .accountDetailsRegionHiddenHelper,
                                        ),
                                ),
                              ],
                            ),
                            if (form.isSeller) ...[
                              const SizedBox(height: AppSpacing.spacingM),
                              _PlainSectionCard(
                                children: [
                                  _SectionField(
                                    label: l10n.accountDetailsBioSectionTitle,
                                    child: _CompactTextField(
                                      controller: _bioController,
                                      enabled: !state.isSaving,
                                      maxLines: 5,
                                      hintText:
                                          l10n.accountDetailsBioPlaceholder,
                                      textInputAction:
                                          TextInputAction.newline,
                                      onChanged: notifier.updateBio,
                                      errorText: _fieldError(
                                        l10n,
                                        notifier.errorFor(
                                          AccountDetailsField.bio,
                                        ),
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

    ref.invalidate(currentUserAccountProfileProvider);
    _showSuccessMessage(l10n.accountDetailsEmailVerificationSent);

    setState(() {
      _isEditingEmail = false;
    });

    await ref.read(authNotifierProvider.notifier).refreshAuthState();
  }

  void _cancelEmailEdit() {
    final baseline = ref.read(accountDetailsNotifierProvider).initialForm;
    if (baseline == null) return;

    _emailController.text = baseline.email;
    ref.read(accountDetailsNotifierProvider.notifier).updateEmail(baseline.email);
    setState(() {
      _isEditingEmail = false;
    });
  }

  Future<void> _handleChangePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await _showImageSourceSheet(l10n);
    if (!mounted || source == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (!mounted || pickedFile == null) return;
      if (pickedFile.path.trim().isEmpty) {
        _showTransientMessage(l10n.publishTruffleImagePickerUnavailable);
        return;
      }

      setState(() {
        _pendingProfileImageFile = File(pickedFile.path);
      });

      // TODO: connect selected profile photo to a dedicated storage/upload flow.
      _showTransientMessage(l10n.accountDetailsPhotoUploadPending);
    } on PlatformException {
      _showTransientMessage(l10n.publishTruffleImagePickerUnavailable);
    } on Exception {
      _showTransientMessage(l10n.publishTruffleImagePickerUnavailable);
    }
  }

  void _handleRemovePhoto() {
    setState(() {
      _pendingProfileImageFile = null;
    });
    ref.read(accountDetailsNotifierProvider.notifier).removeProfileImage();
  }

  Future<ImageSource?> _showImageSourceSheet(AppLocalizations l10n) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF178A42),
              size: 20,
            ),
            const SizedBox(width: AppSpacing.spacingS),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasProfileChanges(AccountDetailsState state) {
    final form = state.form;
    final initialForm = state.initialForm;
    if (form == null || initialForm == null) return false;

    return form.copyWith(email: initialForm.email).hasChangesComparedTo(
          initialForm.copyWith(email: initialForm.email),
        );
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
    required this.initials,
    required this.onChangePhoto,
    required this.onRemovePhoto,
  });

  final AccountDetailsFormData form;
  final File? localImageFile;
  final bool isSaving;
  final String initials;
  final Future<void> Function() onChangePhoto;
  final VoidCallback onRemovePhoto;

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
              Center(
                child: _ProfileImagePreview(
                  networkImageUrl: form.profileImageUrl,
                  localImageFile: localImageFile,
                  initials: initials,
                ),
              ),
              const SizedBox(height: AppSpacing.spacingM),
              Row(
                children: [
                  Expanded(
                    child: AuthPrimaryButton(
                      label: l10n.accountDetailsChangePhotoCta,
                      backgroundColor: AppColors.accent,
                      enabled: !isSaving,
                      onPressed: isSaving ? null : onChangePhoto,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingXXS),
                  Expanded(
                    child: _SecondaryActionButton(
                      label: l10n.accountDetailsRemovePhotoCta,
                      onPressed: isSaving ||
                              (form.profileImageUrl == null &&
                                  localImageFile == null)
                          ? null
                          : onRemovePhoto,
                    ),
                  ),
                ],
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      emailController.text.trim(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacingS),
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
                  backgroundColor: AppColors.accent,
                  enabled: hasEmailChange && emailError == null && !isSaving,
                  isLoading: isSaving,
                  onPressed:
                      hasEmailChange && emailError == null && !isSaving
                          ? onSaveNewEmail
                          : null,
                ),
                const SizedBox(height: AppSpacing.spacingXS),
                Align(
                  alignment: Alignment.centerLeft,
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
  const _SectionField({
    required this.label,
    required this.child,
  });

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
  const _PlainSectionCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.black10,
          width: 1.2,
        ),
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
  const _SecondaryActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(55),
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
  });

  final String? networkImageUrl;
  final File? localImageFile;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: localImageFile != null
                ? Container(
                    width: 168,
                    height: 168,
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
                    size: 168,
                  ),
          ),
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
  const _VerificationBadge({
    required this.label,
    required this.isVerified,
  });

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
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedValueField extends StatelessWidget {
  const _LockedValueField({
    required this.value,
    this.helperText,
  });

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
          Text(
            value,
            style: AppTextStyles.bodyLarge,
          ),
          if (helperText != null) ...[
            const SizedBox(height: AppSpacing.spacingXS),
            Text(
              helperText!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.black80,
              ),
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
