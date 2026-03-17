import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordLettersNumbers.
  ///
  /// In en, this message translates to:
  /// **'Password must contain letters and numbers'**
  String get passwordLettersNumbers;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue buying and selling premium truffles.'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginButton;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @authNoAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccountText;

  /// No description provided for @authSignupLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignupLink;

  /// No description provided for @authSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignupTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the trusted marketplace for buying and selling premium truffles.'**
  String get authSignupSubtitle;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authSignupButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignupButton;

  /// No description provided for @authAlreadyHaveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccountText;

  /// No description provided for @authLoginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get authLoginLink;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before signing in.'**
  String get authErrorEmailNotVerified;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and retry.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get authErrorTimeout;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorUnknown;

  /// No description provided for @authErrorEmailAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use.'**
  String get authErrorEmailAlreadyUsed;

  /// No description provided for @authErrorLoginFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to sign in. Please try again.'**
  String get authErrorLoginFallback;

  /// No description provided for @authErrorSignupFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to create your account. Please try again.'**
  String get authErrorSignupFallback;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ve sent a verification link to your email address. Please confirm it to continue.'**
  String get authVerifyEmailSubtitle;

  /// No description provided for @authVerifyEmailCurrentEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authVerifyEmailCurrentEmail;

  /// No description provided for @authVerifyEmailRecheckButton.
  ///
  /// In en, this message translates to:
  /// **'I verified my email'**
  String get authVerifyEmailRecheckButton;

  /// No description provided for @authVerifyEmailNotYetVerified.
  ///
  /// In en, this message translates to:
  /// **'Your email is not verified yet.'**
  String get authVerifyEmailNotYetVerified;

  /// No description provided for @authVerifyEmailSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get authVerifyEmailSessionExpired;

  /// No description provided for @authVerifyEmailResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get authVerifyEmailResendButton;

  /// No description provided for @authVerifyEmailResendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again.'**
  String get authVerifyEmailResendSuccess;

  /// No description provided for @authVerifyEmailMissingEmail.
  ///
  /// In en, this message translates to:
  /// **'Unable to find your email for resend.'**
  String get authVerifyEmailMissingEmail;

  /// No description provided for @authVerifyEmailAutoContinueHint.
  ///
  /// In en, this message translates to:
  /// **'After clicking the link in your email, the app will continue automatically.'**
  String get authVerifyEmailAutoContinueHint;

  /// No description provided for @authVerifyEmailSignOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authVerifyEmailSignOutButton;

  /// No description provided for @authVerifyEmailSpamHint.
  ///
  /// In en, this message translates to:
  /// **'If you don’t see the email, check your spam folder.'**
  String get authVerifyEmailSpamHint;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we’ll send you a link to reset your password.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authForgotPasswordButton;

  /// No description provided for @authForgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'If the email exists, a reset link has been sent.'**
  String get authForgotPasswordSuccess;

  /// No description provided for @authForgotPasswordErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to send reset email. Please try again.'**
  String get authForgotPasswordErrorFallback;

  /// No description provided for @authForgotPasswordBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authForgotPasswordBackToLogin;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new secure password for your account.'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authResetPasswordNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authResetPasswordNewPasswordLabel;

  /// No description provided for @authResetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authResetPasswordButton;

  /// No description provided for @authResetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get authResetPasswordSuccess;

  /// No description provided for @authResetPasswordInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'This reset link is invalid or expired.'**
  String get authResetPasswordInvalidLink;

  /// No description provided for @authResetPasswordInvalidRecoverySession.
  ///
  /// In en, this message translates to:
  /// **'Recovery session is invalid. Open the reset link again.'**
  String get authResetPasswordInvalidRecoverySession;

  /// No description provided for @authResetPasswordErrorFallback.
  ///
  /// In en, this message translates to:
  /// **'Unable to reset password. Please try again.'**
  String get authResetPasswordErrorFallback;

  /// No description provided for @authResetPasswordSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get authResetPasswordSuccessTitle;

  /// No description provided for @authResetPasswordSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your password has been successfully updated.'**
  String get authResetPasswordSuccessMessage;

  /// No description provided for @authResetPasswordSuccessButton.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get authResetPasswordSuccessButton;

  /// No description provided for @authWelcomeTitleLeading.
  ///
  /// In en, this message translates to:
  /// **'Buy and sell'**
  String get authWelcomeTitleLeading;

  /// No description provided for @authWelcomeTitleAccent.
  ///
  /// In en, this message translates to:
  /// **'premium truffles'**
  String get authWelcomeTitleAccent;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a trusted marketplace built around\nquality, transparency, and real reviews.'**
  String get authWelcomeSubtitle;

  /// No description provided for @authWelcomeCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authWelcomeCreateAccountButton;

  /// No description provided for @authWelcomeGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authWelcomeGoogleButton;

  /// No description provided for @authWelcomeLoginButton.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authWelcomeLoginButton;

  /// No description provided for @onboardingNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us your name'**
  String get onboardingNameTitle;

  /// No description provided for @onboardingNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This will be used to complete your onboarding profile details.'**
  String get onboardingNameSubtitle;

  /// No description provided for @onboardingFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get onboardingFirstNameLabel;

  /// No description provided for @onboardingLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get onboardingLastNameLabel;

  /// No description provided for @onboardingFirstNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get onboardingFirstNameRequiredError;

  /// No description provided for @onboardingFirstNameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters.'**
  String get onboardingFirstNameTooShortError;

  /// No description provided for @onboardingLastNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get onboardingLastNameRequiredError;

  /// No description provided for @onboardingLastNameTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters.'**
  String get onboardingLastNameTooShortError;

  /// No description provided for @onboardingBuyerLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you buying from?'**
  String get onboardingBuyerLocationTitle;

  /// No description provided for @onboardingBuyerLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your country. If you choose Italy, region becomes required.'**
  String get onboardingBuyerLocationSubtitle;

  /// No description provided for @onboardingCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get onboardingCountryLabel;

  /// No description provided for @onboardingCountryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get onboardingCountryPlaceholder;

  /// No description provided for @onboardingCountryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Country is required.'**
  String get onboardingCountryRequiredError;

  /// No description provided for @onboardingCountryInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Select a valid country.'**
  String get onboardingCountryInvalidError;

  /// No description provided for @onboardingRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get onboardingRegionLabel;

  /// No description provided for @onboardingRegionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a region'**
  String get onboardingRegionPlaceholder;

  /// No description provided for @onboardingRegionHint.
  ///
  /// In en, this message translates to:
  /// **'TOSCANA'**
  String get onboardingRegionHint;

  /// No description provided for @onboardingRegionNotRequiredHint.
  ///
  /// In en, this message translates to:
  /// **'Not required'**
  String get onboardingRegionNotRequiredHint;

  /// No description provided for @onboardingRegionRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Region is required.'**
  String get onboardingRegionRequiredError;

  /// No description provided for @onboardingRegionAbruzzo.
  ///
  /// In en, this message translates to:
  /// **'Abruzzo'**
  String get onboardingRegionAbruzzo;

  /// No description provided for @onboardingRegionBasilicata.
  ///
  /// In en, this message translates to:
  /// **'Basilicata'**
  String get onboardingRegionBasilicata;

  /// No description provided for @onboardingRegionCalabria.
  ///
  /// In en, this message translates to:
  /// **'Calabria'**
  String get onboardingRegionCalabria;

  /// No description provided for @onboardingRegionCampania.
  ///
  /// In en, this message translates to:
  /// **'Campania'**
  String get onboardingRegionCampania;

  /// No description provided for @onboardingRegionEmiliaRomagna.
  ///
  /// In en, this message translates to:
  /// **'Emilia-Romagna'**
  String get onboardingRegionEmiliaRomagna;

  /// No description provided for @onboardingRegionFriuliVeneziaGiulia.
  ///
  /// In en, this message translates to:
  /// **'Friuli Venezia Giulia'**
  String get onboardingRegionFriuliVeneziaGiulia;

  /// No description provided for @onboardingRegionLazio.
  ///
  /// In en, this message translates to:
  /// **'Lazio'**
  String get onboardingRegionLazio;

  /// No description provided for @onboardingRegionLiguria.
  ///
  /// In en, this message translates to:
  /// **'Liguria'**
  String get onboardingRegionLiguria;

  /// No description provided for @onboardingRegionLombardia.
  ///
  /// In en, this message translates to:
  /// **'Lombardia'**
  String get onboardingRegionLombardia;

  /// No description provided for @onboardingRegionMarche.
  ///
  /// In en, this message translates to:
  /// **'Marche'**
  String get onboardingRegionMarche;

  /// No description provided for @onboardingRegionMolise.
  ///
  /// In en, this message translates to:
  /// **'Molise'**
  String get onboardingRegionMolise;

  /// No description provided for @onboardingRegionPiemonte.
  ///
  /// In en, this message translates to:
  /// **'Piemonte'**
  String get onboardingRegionPiemonte;

  /// No description provided for @onboardingRegionPuglia.
  ///
  /// In en, this message translates to:
  /// **'Puglia'**
  String get onboardingRegionPuglia;

  /// No description provided for @onboardingRegionSardegna.
  ///
  /// In en, this message translates to:
  /// **'Sardegna'**
  String get onboardingRegionSardegna;

  /// No description provided for @onboardingRegionSicilia.
  ///
  /// In en, this message translates to:
  /// **'Sicilia'**
  String get onboardingRegionSicilia;

  /// No description provided for @onboardingRegionToscana.
  ///
  /// In en, this message translates to:
  /// **'Toscana'**
  String get onboardingRegionToscana;

  /// No description provided for @onboardingRegionTrentinoAltoAdige.
  ///
  /// In en, this message translates to:
  /// **'Trentino-Alto Adige'**
  String get onboardingRegionTrentinoAltoAdige;

  /// No description provided for @onboardingRegionUmbria.
  ///
  /// In en, this message translates to:
  /// **'Umbria'**
  String get onboardingRegionUmbria;

  /// No description provided for @onboardingRegionValleDaosta.
  ///
  /// In en, this message translates to:
  /// **'Valle d\'Aosta'**
  String get onboardingRegionValleDaosta;

  /// No description provided for @onboardingRegionVeneto.
  ///
  /// In en, this message translates to:
  /// **'Veneto'**
  String get onboardingRegionVeneto;

  /// No description provided for @onboardingBuyerLocationRegionHelper.
  ///
  /// In en, this message translates to:
  /// **'Region is only required for buyers in Italy.'**
  String get onboardingBuyerLocationRegionHelper;

  /// No description provided for @onboardingSellerRegionTitle.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get onboardingSellerRegionTitle;

  /// No description provided for @onboardingSellerRegionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Seller country is treated as Italy in this onboarding flow, so only region is required here.'**
  String get onboardingSellerRegionSubtitle;

  /// No description provided for @onboardingSellerDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your seller documents'**
  String get onboardingSellerDocumentsTitle;

  /// No description provided for @onboardingSellerDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the required documents locally. Nothing is uploaded during onboarding until the final submit step.'**
  String get onboardingSellerDocumentsSubtitle;

  /// No description provided for @onboardingTesserinoNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Tesserino number'**
  String get onboardingTesserinoNumberLabel;

  /// No description provided for @onboardingTesserinoNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your tesserino number'**
  String get onboardingTesserinoNumberHint;

  /// No description provided for @onboardingTesserinoNumberRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Tesserino number is required.'**
  String get onboardingTesserinoNumberRequiredError;

  /// No description provided for @onboardingIdentityDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity document'**
  String get onboardingIdentityDocumentTitle;

  /// No description provided for @onboardingIdentityDocumentDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid identity document for verification.'**
  String get onboardingIdentityDocumentDescription;

  /// No description provided for @onboardingIdentityDocumentRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Identity document is required.'**
  String get onboardingIdentityDocumentRequiredError;

  /// No description provided for @onboardingTesserinoDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Tesserino document'**
  String get onboardingTesserinoDocumentTitle;

  /// No description provided for @onboardingTesserinoDocumentDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose your truffle license or permit document.'**
  String get onboardingTesserinoDocumentDescription;

  /// No description provided for @onboardingTesserinoDocumentRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Tesserino document is required.'**
  String get onboardingTesserinoDocumentRequiredError;

  /// No description provided for @onboardingDocumentPickButton.
  ///
  /// In en, this message translates to:
  /// **'Pick file'**
  String get onboardingDocumentPickButton;

  /// No description provided for @onboardingDocumentReplaceButton.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get onboardingDocumentReplaceButton;

  /// No description provided for @onboardingDocumentRemoveButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get onboardingDocumentRemoveButton;

  /// No description provided for @onboardingDocumentTakePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get onboardingDocumentTakePhotoOption;

  /// No description provided for @onboardingDocumentChooseFromGalleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get onboardingDocumentChooseFromGalleryOption;

  /// No description provided for @onboardingDocumentSourceCancelOption.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get onboardingDocumentSourceCancelOption;

  /// No description provided for @onboardingDocumentNotSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get onboardingDocumentNotSelected;

  /// No description provided for @onboardingDocumentPermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get onboardingDocumentPermissionDeniedError;

  /// No description provided for @onboardingDocumentCameraUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable.'**
  String get onboardingDocumentCameraUnavailableError;

  /// No description provided for @onboardingDocumentGalleryUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Gallery unavailable.'**
  String get onboardingDocumentGalleryUnavailableError;

  /// No description provided for @onboardingDocumentPickerUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Unable to select an image right now.'**
  String get onboardingDocumentPickerUnavailableError;

  /// No description provided for @onboardingSellerDocumentsLocalOnlyHelper.
  ///
  /// In en, this message translates to:
  /// **'Files stay local on this device for now. Upload happens only at final submit.'**
  String get onboardingSellerDocumentsLocalOnlyHelper;

  /// No description provided for @onboardingNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay updated with notifications'**
  String get onboardingNotificationsTitle;

  /// No description provided for @onboardingNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications help you follow the most important moments of your Truffly experience.'**
  String get onboardingNotificationsSubtitle;

  /// No description provided for @onboardingNotificationsBenefitOrderUpdates.
  ///
  /// In en, this message translates to:
  /// **'Order updates from purchase to completion.'**
  String get onboardingNotificationsBenefitOrderUpdates;

  /// No description provided for @onboardingNotificationsBenefitShippingUpdates.
  ///
  /// In en, this message translates to:
  /// **'Shipping and delivery updates for active orders.'**
  String get onboardingNotificationsBenefitShippingUpdates;

  /// No description provided for @onboardingNotificationsBenefitSellerApproval.
  ///
  /// In en, this message translates to:
  /// **'Seller approval updates if you apply to sell on Truffly.'**
  String get onboardingNotificationsBenefitSellerApproval;

  /// No description provided for @onboardingNotificationsBenefitPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment and payout related updates when relevant.'**
  String get onboardingNotificationsBenefitPayments;

  /// No description provided for @onboardingNotificationsEnableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get onboardingNotificationsEnableButton;

  /// No description provided for @onboardingNotificationsContinueWithoutButton.
  ///
  /// In en, this message translates to:
  /// **'Continue Without Notifications'**
  String get onboardingNotificationsContinueWithoutButton;

  /// No description provided for @onboardingNotificationsFooter.
  ///
  /// In en, this message translates to:
  /// **'You can always manage notifications later in settings.'**
  String get onboardingNotificationsFooter;

  /// No description provided for @onboardingNotificationsStatusIdle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not enabled yet.'**
  String get onboardingNotificationsStatusIdle;

  /// No description provided for @onboardingNotificationsStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Permission request in progress.'**
  String get onboardingNotificationsStatusPending;

  /// No description provided for @onboardingNotificationsStatusGranted.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled successfully.'**
  String get onboardingNotificationsStatusGranted;

  /// No description provided for @onboardingNotificationsStatusDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. You can continue and enable notifications later in settings.'**
  String get onboardingNotificationsStatusDenied;

  /// No description provided for @onboardingNotificationsStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'You chose to continue without notifications for now.'**
  String get onboardingNotificationsStatusSkipped;

  /// No description provided for @onboardingNotificationsPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Unable to request notification permission right now. You can continue and try again later.'**
  String get onboardingNotificationsPermissionError;

  /// No description provided for @onboardingWelcomeBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Truffly'**
  String get onboardingWelcomeBuyerTitle;

  /// No description provided for @onboardingWelcomeBuyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your buyer onboarding is complete.'**
  String get onboardingWelcomeBuyerSubtitle;

  /// No description provided for @onboardingWelcomeBuyerMessage.
  ///
  /// In en, this message translates to:
  /// **'You are ready to start exploring premium truffles, trusted sellers, and secure purchases in the app.'**
  String get onboardingWelcomeBuyerMessage;

  /// No description provided for @onboardingWelcomeSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Truffly profile is ready'**
  String get onboardingWelcomeSellerTitle;

  /// No description provided for @onboardingWelcomeSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are ready to complete seller onboarding.'**
  String get onboardingWelcomeSellerSubtitle;

  /// No description provided for @onboardingWelcomeSellerMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the app to continue with your account. We will keep the seller review flow separate from approval and update you as it progresses.'**
  String get onboardingWelcomeSellerMessage;

  /// No description provided for @onboardingWelcomeDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Truffly'**
  String get onboardingWelcomeDefaultTitle;

  /// No description provided for @onboardingWelcomeDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are almost ready to enter the app.'**
  String get onboardingWelcomeDefaultSubtitle;

  /// No description provided for @onboardingWelcomeDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Review your onboarding details and continue when you are ready.'**
  String get onboardingWelcomeDefaultMessage;

  /// No description provided for @onboardingBuyerInfo1Title.
  ///
  /// In en, this message translates to:
  /// **'Fresh truffles, selected for quality'**
  String get onboardingBuyerInfo1Title;

  /// No description provided for @onboardingBuyerInfo1Description.
  ///
  /// In en, this message translates to:
  /// **'Truffly is built for people who want access to premium truffles with a simple mobile experience focused on freshness, origin, and product quality.'**
  String get onboardingBuyerInfo1Description;

  /// No description provided for @onboardingBuyerInfo2Title.
  ///
  /// In en, this message translates to:
  /// **'Secure purchases with escrow logic'**
  String get onboardingBuyerInfo2Title;

  /// No description provided for @onboardingBuyerInfo2Description.
  ///
  /// In en, this message translates to:
  /// **'Payments are designed to follow a protected order flow. Truffly keeps the purchase experience clear and secure while the order moves from payment to shipment to completion.'**
  String get onboardingBuyerInfo2Description;

  /// No description provided for @onboardingBuyerInfo3Title.
  ///
  /// In en, this message translates to:
  /// **'Verified sellers and trust signals'**
  String get onboardingBuyerInfo3Title;

  /// No description provided for @onboardingBuyerInfo3Description.
  ///
  /// In en, this message translates to:
  /// **'Buyers can explore a marketplace built around verified sellers, transparent profiles, reviews, and a stronger sense of trust across the community.'**
  String get onboardingBuyerInfo3Description;

  /// No description provided for @onboardingSellerInfo1Title.
  ///
  /// In en, this message translates to:
  /// **'Sell your truffles to a focused market'**
  String get onboardingSellerInfo1Title;

  /// No description provided for @onboardingSellerInfo1Description.
  ///
  /// In en, this message translates to:
  /// **'Truffly helps truffle hunters reach buyers through a dedicated mobile marketplace designed around quality, trust, and clear order management.'**
  String get onboardingSellerInfo1Description;

  /// No description provided for @onboardingSellerInfo2Title.
  ///
  /// In en, this message translates to:
  /// **'A clear commission model'**
  String get onboardingSellerInfo2Title;

  /// No description provided for @onboardingSellerInfo2Description.
  ///
  /// In en, this message translates to:
  /// **'Truffly applies a 10% commission on completed sales. The goal is to keep seller economics simple and predictable from the beginning.'**
  String get onboardingSellerInfo2Description;

  /// No description provided for @onboardingSellerInfo3Title.
  ///
  /// In en, this message translates to:
  /// **'Shipping timing matters'**
  String get onboardingSellerInfo3Title;

  /// No description provided for @onboardingSellerInfo3Description.
  ///
  /// In en, this message translates to:
  /// **'Orders follow strict timing expectations. Sellers are expected to ship quickly, and the current MVP flow is built around a 48-hour shipping rule.'**
  String get onboardingSellerInfo3Description;

  /// No description provided for @onboardingSellerInfo4Title.
  ///
  /// In en, this message translates to:
  /// **'Approval, escrow, and payout expectations'**
  String get onboardingSellerInfo4Title;

  /// No description provided for @onboardingSellerInfo4Description.
  ///
  /// In en, this message translates to:
  /// **'Seller onboarding includes review and approval steps. Payments and payouts follow a structured flow, and Stripe-related setup happens only after approval.'**
  String get onboardingSellerInfo4Description;

  /// No description provided for @onboardingFlowTitleBuyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer onboarding'**
  String get onboardingFlowTitleBuyer;

  /// No description provided for @onboardingFlowTitleSeller.
  ///
  /// In en, this message translates to:
  /// **'Seller onboarding'**
  String get onboardingFlowTitleSeller;

  /// No description provided for @onboardingFlowTitleDefault.
  ///
  /// In en, this message translates to:
  /// **'Onboarding'**
  String get onboardingFlowTitleDefault;

  /// No description provided for @onboardingFlowStepCounter.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingFlowStepCounter(Object current, Object total);

  /// No description provided for @onboardingFlowSubmissionError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingFlowSubmissionError;

  /// No description provided for @onboardingSubmitNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection lost. Please try again.'**
  String get onboardingSubmitNetworkError;

  /// No description provided for @onboardingSubmitValidationError.
  ///
  /// In en, this message translates to:
  /// **'Some onboarding data is invalid. Please review your details and try again.'**
  String get onboardingSubmitValidationError;

  /// No description provided for @onboardingSubmitDocumentError.
  ///
  /// In en, this message translates to:
  /// **'A selected document could not be processed. Please review your files and try again.'**
  String get onboardingSubmitDocumentError;

  /// No description provided for @onboardingSubmitServerError.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable right now. Please try again.'**
  String get onboardingSubmitServerError;

  /// No description provided for @onboardingSubmitUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'This action is not available right now.'**
  String get onboardingSubmitUnavailableError;

  /// No description provided for @onboardingFlowBackButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingFlowBackButton;

  /// No description provided for @onboardingFlowNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingFlowNextButton;

  /// No description provided for @onboardingFlowEnterAppButton.
  ///
  /// In en, this message translates to:
  /// **'Enter App'**
  String get onboardingFlowEnterAppButton;

  /// No description provided for @onboardingFlowSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get onboardingFlowSubmitButton;

  /// No description provided for @onboardingProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Section progress: {section}'**
  String onboardingProgressLabel(Object section);

  /// No description provided for @onboardingPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Placeholder Step'**
  String get onboardingPlaceholderTitle;

  /// No description provided for @onboardingPlaceholderStepId.
  ///
  /// In en, this message translates to:
  /// **'Step ID: {stepId}'**
  String onboardingPlaceholderStepId(Object stepId);

  /// No description provided for @onboardingPlaceholderSection.
  ///
  /// In en, this message translates to:
  /// **'Section: {section}'**
  String onboardingPlaceholderSection(Object section);

  /// No description provided for @onboardingSectionAboutTruffly.
  ///
  /// In en, this message translates to:
  /// **'About Truffly'**
  String get onboardingSectionAboutTruffly;

  /// No description provided for @onboardingSectionYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Your Details'**
  String get onboardingSectionYourDetails;

  /// No description provided for @onboardingSectionDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get onboardingSectionDocuments;

  /// No description provided for @onboardingSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get onboardingSectionNotifications;

  /// No description provided for @onboardingSectionWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingSectionWelcome;

  /// No description provided for @onboardingCountryItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get onboardingCountryItaly;

  /// No description provided for @onboardingCountryFrance.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get onboardingCountryFrance;

  /// No description provided for @onboardingCountryGermany.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get onboardingCountryGermany;

  /// No description provided for @onboardingCountrySpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get onboardingCountrySpain;

  /// No description provided for @onboardingCountryUnitedKingdom.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get onboardingCountryUnitedKingdom;

  /// No description provided for @onboardingCountryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get onboardingCountryUnitedStates;

  /// No description provided for @onboardingRoleSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'How would you like to use Truffly'**
  String get onboardingRoleSelectionTitle;

  /// No description provided for @onboardingRoleSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to get started.\nYou can always change this later.'**
  String get onboardingRoleSelectionSubtitle;

  /// No description provided for @onboardingRoleSelectionBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Buy truffles'**
  String get onboardingRoleSelectionBuyerTitle;

  /// No description provided for @onboardingRoleSelectionBuyerDescription.
  ///
  /// In en, this message translates to:
  /// **'See the 7-step buyer onboarding flow.'**
  String get onboardingRoleSelectionBuyerDescription;

  /// No description provided for @onboardingRoleSelectionSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sell truffles'**
  String get onboardingRoleSelectionSellerTitle;

  /// No description provided for @onboardingRoleSelectionSellerDescription.
  ///
  /// In en, this message translates to:
  /// **'See the 9-step seller onboarding flow.'**
  String get onboardingRoleSelectionSellerDescription;

  /// No description provided for @onboardingExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave onboarding?'**
  String get onboardingExitTitle;

  /// No description provided for @onboardingExitMessage.
  ///
  /// In en, this message translates to:
  /// **'Your onboarding progress will stay saved locally for this session, but you will leave the onboarding flow.'**
  String get onboardingExitMessage;

  /// No description provided for @onboardingExitStayButton.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get onboardingExitStayButton;

  /// No description provided for @onboardingExitLeaveButton.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get onboardingExitLeaveButton;

  /// No description provided for @onboardingDocumentUnsupportedFormatError.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format. Use PNG, JPG, or JPEG.'**
  String get onboardingDocumentUnsupportedFormatError;

  /// No description provided for @onboardingDocumentFileNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The selected file could not be found.'**
  String get onboardingDocumentFileNotFoundError;

  /// No description provided for @onboardingDocumentEmptyFileError.
  ///
  /// In en, this message translates to:
  /// **'The selected file is empty.'**
  String get onboardingDocumentEmptyFileError;

  /// No description provided for @trufflePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffles'**
  String get trufflePageTitle;

  /// No description provided for @truffleDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffle detail'**
  String get truffleDetailTitle;

  /// No description provided for @truffleDetailError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this truffle right now.'**
  String get truffleDetailError;

  /// No description provided for @truffleDetailPricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price per kg'**
  String get truffleDetailPricePerKg;

  /// No description provided for @truffleSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or Latin name'**
  String get truffleSearchHint;

  /// No description provided for @truffleSearchApply.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get truffleSearchApply;

  /// No description provided for @truffleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load truffles right now. Please try again.'**
  String get truffleLoadError;

  /// No description provided for @truffleRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get truffleRetry;

  /// No description provided for @truffleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get truffleEmptyTitle;

  /// No description provided for @truffleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters or check again later.'**
  String get truffleEmptySubtitle;

  /// No description provided for @truffleFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get truffleFiltersTitle;

  /// No description provided for @truffleFiltersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get truffleFiltersReset;

  /// No description provided for @truffleFiltersApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get truffleFiltersApply;

  /// No description provided for @truffleFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get truffleFilterAll;

  /// No description provided for @truffleFilterQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get truffleFilterQuality;

  /// No description provided for @truffleFilterPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get truffleFilterPriceRange;

  /// No description provided for @truffleFilterWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get truffleFilterWeight;

  /// No description provided for @truffleFilterHarvestDate.
  ///
  /// In en, this message translates to:
  /// **'Harvest date'**
  String get truffleFilterHarvestDate;

  /// No description provided for @truffleFilterRegion.
  ///
  /// In en, this message translates to:
  /// **'Harvest region'**
  String get truffleFilterRegion;

  /// No description provided for @truffleHarvestToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get truffleHarvestToday;

  /// No description provided for @truffleHarvestLast2Days.
  ///
  /// In en, this message translates to:
  /// **'Last 2 days'**
  String get truffleHarvestLast2Days;

  /// No description provided for @truffleHarvestLast3Days.
  ///
  /// In en, this message translates to:
  /// **'Last 3 days'**
  String get truffleHarvestLast3Days;

  /// No description provided for @truffleHarvestLast5Days.
  ///
  /// In en, this message translates to:
  /// **'Last 5 days'**
  String get truffleHarvestLast5Days;

  /// No description provided for @truffleQualityFirst.
  ///
  /// In en, this message translates to:
  /// **'First choice'**
  String get truffleQualityFirst;

  /// No description provided for @truffleQualitySecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get truffleQualitySecond;

  /// No description provided for @truffleQualityThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get truffleQualityThird;

  /// No description provided for @truffleTypeMagnatum.
  ///
  /// In en, this message translates to:
  /// **'White truffle'**
  String get truffleTypeMagnatum;

  /// No description provided for @truffleTypeMelanosporum.
  ///
  /// In en, this message translates to:
  /// **'Black winter truffle'**
  String get truffleTypeMelanosporum;

  /// No description provided for @truffleTypeAestivum.
  ///
  /// In en, this message translates to:
  /// **'Scorzone'**
  String get truffleTypeAestivum;

  /// No description provided for @truffleTypeUncinatum.
  ///
  /// In en, this message translates to:
  /// **'Uncinato'**
  String get truffleTypeUncinatum;

  /// No description provided for @truffleTypeBorchii.
  ///
  /// In en, this message translates to:
  /// **'Bianchetto'**
  String get truffleTypeBorchii;

  /// No description provided for @truffleTypeBrumale.
  ///
  /// In en, this message translates to:
  /// **'Brumale'**
  String get truffleTypeBrumale;

  /// No description provided for @truffleShippingPlus.
  ///
  /// In en, this message translates to:
  /// **'+ shipping'**
  String get truffleShippingPlus;

  /// No description provided for @truffleShippingItaly.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get truffleShippingItaly;

  /// No description provided for @publishTruffleTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish truffle'**
  String get publishTruffleTitle;

  /// No description provided for @publishTrufflePhotosTitle.
  ///
  /// In en, this message translates to:
  /// **'Product photos'**
  String get publishTrufflePhotosTitle;

  /// No description provided for @publishTrufflePhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add between 1 and 3 photos. The first photo will be used as the cover image.'**
  String get publishTrufflePhotosSubtitle;

  /// No description provided for @publishTruffleAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get publishTruffleAddPhoto;

  /// No description provided for @publishTruffleRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get publishTruffleRemovePhoto;

  /// No description provided for @publishTruffleQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Truffle quality'**
  String get publishTruffleQualityLabel;

  /// No description provided for @publishTruffleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Truffle type'**
  String get publishTruffleTypeLabel;

  /// No description provided for @publishTruffleTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select truffle type'**
  String get publishTruffleTypePlaceholder;

  /// No description provided for @publishTruffleLatinNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Latin name'**
  String get publishTruffleLatinNameLabel;

  /// No description provided for @publishTrufflePricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight and prices'**
  String get publishTrufflePricingTitle;

  /// No description provided for @publishTruffleWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight in grams'**
  String get publishTruffleWeightLabel;

  /// No description provided for @publishTruffleTotalPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Total price in EUR'**
  String get publishTruffleTotalPriceLabel;

  /// No description provided for @publishTruffleShippingItalyLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping price Italy'**
  String get publishTruffleShippingItalyLabel;

  /// No description provided for @publishTruffleShippingAbroadLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping price abroad'**
  String get publishTruffleShippingAbroadLabel;

  /// No description provided for @publishTrufflePricePerKgPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Price per kg preview'**
  String get publishTrufflePricePerKgPreviewLabel;

  /// No description provided for @publishTrufflePricePerKgPreviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Fill in weight and total price'**
  String get publishTrufflePricePerKgPreviewPlaceholder;

  /// No description provided for @publishTruffleRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Harvest region'**
  String get publishTruffleRegionLabel;

  /// No description provided for @publishTruffleRegionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select harvest region'**
  String get publishTruffleRegionPlaceholder;

  /// No description provided for @publishTruffleHarvestDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Harvest date'**
  String get publishTruffleHarvestDateLabel;

  /// No description provided for @publishTruffleCta.
  ///
  /// In en, this message translates to:
  /// **'Publish truffle'**
  String get publishTruffleCta;

  /// No description provided for @publishTruffleConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish this truffle?'**
  String get publishTruffleConfirmTitle;

  /// No description provided for @publishTruffleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'After publication, the truffle will be visible in the marketplace and cannot be edited.'**
  String get publishTruffleConfirmMessage;

  /// No description provided for @publishTruffleCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get publishTruffleCancelAction;

  /// No description provided for @publishTruffleConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishTruffleConfirmAction;

  /// No description provided for @publishTruffleTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get publishTruffleTakePhoto;

  /// No description provided for @publishTruffleChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get publishTruffleChooseFromGallery;

  /// No description provided for @publishTruffleValidationImagesRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least 1 product photo.'**
  String get publishTruffleValidationImagesRequired;

  /// No description provided for @publishTruffleValidationImagesTooMany.
  ///
  /// In en, this message translates to:
  /// **'You can upload up to 3 product photos.'**
  String get publishTruffleValidationImagesTooMany;

  /// No description provided for @publishTruffleValidationQualityRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the truffle quality.'**
  String get publishTruffleValidationQualityRequired;

  /// No description provided for @publishTruffleValidationTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the truffle type.'**
  String get publishTruffleValidationTypeRequired;

  /// No description provided for @publishTruffleValidationWeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Weight is required.'**
  String get publishTruffleValidationWeightRequired;

  /// No description provided for @publishTruffleValidationWeightInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight greater than 0.'**
  String get publishTruffleValidationWeightInvalid;

  /// No description provided for @publishTruffleValidationPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Total price is required.'**
  String get publishTruffleValidationPriceRequired;

  /// No description provided for @publishTruffleValidationPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a total price greater than 0.'**
  String get publishTruffleValidationPriceInvalid;

  /// No description provided for @publishTruffleValidationShippingItalyRequired.
  ///
  /// In en, this message translates to:
  /// **'Shipping price for Italy is required.'**
  String get publishTruffleValidationShippingItalyRequired;

  /// No description provided for @publishTruffleValidationShippingItalyInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a shipping price for Italy equal to or greater than 0.'**
  String get publishTruffleValidationShippingItalyInvalid;

  /// No description provided for @publishTruffleValidationShippingAbroadRequired.
  ///
  /// In en, this message translates to:
  /// **'Shipping price for abroad is required.'**
  String get publishTruffleValidationShippingAbroadRequired;

  /// No description provided for @publishTruffleValidationShippingAbroadInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a shipping price for abroad equal to or greater than 0.'**
  String get publishTruffleValidationShippingAbroadInvalid;

  /// No description provided for @publishTruffleValidationRegionRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the harvest region.'**
  String get publishTruffleValidationRegionRequired;

  /// No description provided for @publishTruffleValidationHarvestDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Harvest date is required.'**
  String get publishTruffleValidationHarvestDateRequired;

  /// No description provided for @publishTruffleValidationHarvestDateFuture.
  ///
  /// In en, this message translates to:
  /// **'Harvest date cannot be in the future.'**
  String get publishTruffleValidationHarvestDateFuture;

  /// No description provided for @publishTruffleValidationImageFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported image format. Use PNG, JPG, or JPEG.'**
  String get publishTruffleValidationImageFormat;

  /// No description provided for @publishTruffleValidationImageMissing.
  ///
  /// In en, this message translates to:
  /// **'The selected image could not be read.'**
  String get publishTruffleValidationImageMissing;

  /// No description provided for @publishTruffleValidationImageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'The selected image is still too large after optimization.'**
  String get publishTruffleValidationImageTooLarge;

  /// No description provided for @publishTruffleValidationImageProcessingFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to prepare this image for upload.'**
  String get publishTruffleValidationImageProcessingFailed;

  /// No description provided for @publishTruffleImagePickerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to pick an image right now.'**
  String get publishTruffleImagePickerUnavailable;

  /// No description provided for @publishTruffleSubmitUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again before publishing.'**
  String get publishTruffleSubmitUnauthenticated;

  /// No description provided for @publishTruffleSubmitNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Only approved sellers with Stripe onboarding completed can publish truffles.'**
  String get publishTruffleSubmitNotAllowed;

  /// No description provided for @publishTruffleSubmitValidation.
  ///
  /// In en, this message translates to:
  /// **'Some product data is invalid. Review the form and try again.'**
  String get publishTruffleSubmitValidation;

  /// No description provided for @publishTruffleSubmitInvalidImage.
  ///
  /// In en, this message translates to:
  /// **'One or more selected images are invalid. Review them and try again.'**
  String get publishTruffleSubmitInvalidImage;

  /// No description provided for @publishTruffleSubmitNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection and try again.'**
  String get publishTruffleSubmitNetwork;

  /// No description provided for @publishTruffleSubmitImageUpload.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload one or more product images.'**
  String get publishTruffleSubmitImageUpload;

  /// No description provided for @publishTruffleSubmitUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unable to publish this truffle right now. Please try again.'**
  String get publishTruffleSubmitUnknown;

  /// No description provided for @publishTruffleAccessError.
  ///
  /// In en, this message translates to:
  /// **'Unable to verify publish permissions right now. Pull to refresh and try again.'**
  String get publishTruffleAccessError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
