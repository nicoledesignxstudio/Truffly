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
  /// **'Second choice'**
  String get truffleQualitySecond;

  /// No description provided for @truffleQualityThird.
  ///
  /// In en, this message translates to:
  /// **'Third choice'**
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

  /// No description provided for @truffleTypeMacrosporum.
  ///
  /// In en, this message translates to:
  /// **'Smooth Black Truffle'**
  String get truffleTypeMacrosporum;

  /// No description provided for @truffleTypeBrumaleMoschatum.
  ///
  /// In en, this message translates to:
  /// **'Musky Brumal Truffle'**
  String get truffleTypeBrumaleMoschatum;

  /// No description provided for @truffleTypeMesentericum.
  ///
  /// In en, this message translates to:
  /// **'Mesenteric Truffle'**
  String get truffleTypeMesentericum;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreetingPrefix.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get homeGreetingPrefix;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the home screen right now.'**
  String get homeLoadError;

  /// No description provided for @homeSeasonalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seasonal Highlight'**
  String get homeSeasonalSectionTitle;

  /// No description provided for @homeSeasonalInSeasonLabel.
  ///
  /// In en, this message translates to:
  /// **'In season'**
  String get homeSeasonalInSeasonLabel;

  /// No description provided for @homeSeasonalComingSoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get homeSeasonalComingSoonLabel;

  /// No description provided for @homeSeasonalLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading seasonal highlights...'**
  String get homeSeasonalLoadingLabel;

  /// No description provided for @homeSeasonalCountdownLine.
  ///
  /// In en, this message translates to:
  /// **'{days} days left until {truffleName} season begins'**
  String homeSeasonalCountdownLine(int days, Object truffleName);

  /// No description provided for @homeSeasonalEmptyText.
  ///
  /// In en, this message translates to:
  /// **'No seasonal highlight is available right now.'**
  String get homeSeasonalEmptyText;

  /// No description provided for @homeSeasonalErrorText.
  ///
  /// In en, this message translates to:
  /// **'Unable to load seasonal information.'**
  String get homeSeasonalErrorText;

  /// No description provided for @homeSeasonalRetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeSeasonalRetryLabel;

  /// No description provided for @homeLatestNewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest News'**
  String get homeLatestNewsTitle;

  /// No description provided for @homeTopSellersTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Truffle Hunters'**
  String get homeTopSellersTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeLatestNewsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No truffles are available right now.'**
  String get homeLatestNewsEmpty;

  /// No description provided for @homeTopSellersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No truffle hunters are available right now.'**
  String get homeTopSellersEmpty;

  /// No description provided for @homeSectionErrorText.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this section right now.'**
  String get homeSectionErrorText;

  /// No description provided for @homeSellerOrdersInProgress.
  ///
  /// In en, this message translates to:
  /// **'Orders in progress'**
  String get homeSellerOrdersInProgress;

  /// No description provided for @homeSellerActiveTruffles.
  ///
  /// In en, this message translates to:
  /// **'Active truffles'**
  String get homeSellerActiveTruffles;

  /// No description provided for @seasonalTruffleNameMagnatum.
  ///
  /// In en, this message translates to:
  /// **'White Truffle'**
  String get seasonalTruffleNameMagnatum;

  /// No description provided for @seasonalTruffleNameMelanosporum.
  ///
  /// In en, this message translates to:
  /// **'Black Winter Truffle'**
  String get seasonalTruffleNameMelanosporum;

  /// No description provided for @seasonalTruffleNameAestivum.
  ///
  /// In en, this message translates to:
  /// **'Summer Truffle'**
  String get seasonalTruffleNameAestivum;

  /// No description provided for @seasonalTruffleNameUncinatum.
  ///
  /// In en, this message translates to:
  /// **'Uncinatum Truffle'**
  String get seasonalTruffleNameUncinatum;

  /// No description provided for @seasonalTruffleNameBorchii.
  ///
  /// In en, this message translates to:
  /// **'Bianchetto'**
  String get seasonalTruffleNameBorchii;

  /// No description provided for @seasonalTruffleNameBrumale.
  ///
  /// In en, this message translates to:
  /// **'Brumale'**
  String get seasonalTruffleNameBrumale;

  /// No description provided for @seasonalTruffleNameMacrosporum.
  ///
  /// In en, this message translates to:
  /// **'Smooth Black Truffle'**
  String get seasonalTruffleNameMacrosporum;

  /// No description provided for @seasonalTruffleNameBrumaleMoschatum.
  ///
  /// In en, this message translates to:
  /// **'Musky Brumal Truffle'**
  String get seasonalTruffleNameBrumaleMoschatum;

  /// No description provided for @seasonalTruffleNameMesentericum.
  ///
  /// In en, this message translates to:
  /// **'Mesenteric Truffle'**
  String get seasonalTruffleNameMesentericum;

  /// No description provided for @guidesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffle Guides'**
  String get guidesPageTitle;

  /// No description provided for @guidesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load guides right now.'**
  String get guidesLoadError;

  /// No description provided for @guidesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get guidesRetry;

  /// No description provided for @guidesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No guides are available right now.'**
  String get guidesEmpty;

  /// No description provided for @guidesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get guidesDescription;

  /// No description provided for @guidesAroma.
  ///
  /// In en, this message translates to:
  /// **'Aroma'**
  String get guidesAroma;

  /// No description provided for @guidesPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get guidesPriceRange;

  /// No description provided for @guidesRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get guidesRarity;

  /// No description provided for @guidesSymbioticPlants.
  ///
  /// In en, this message translates to:
  /// **'Symbiotic plants'**
  String get guidesSymbioticPlants;

  /// No description provided for @guidesSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get guidesSoil;

  /// No description provided for @guidesSoilComposition.
  ///
  /// In en, this message translates to:
  /// **'Composition'**
  String get guidesSoilComposition;

  /// No description provided for @guidesSoilStructure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get guidesSoilStructure;

  /// No description provided for @guidesSoilPh.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get guidesSoilPh;

  /// No description provided for @guidesSoilAltitude.
  ///
  /// In en, this message translates to:
  /// **'Altitude'**
  String get guidesSoilAltitude;

  /// No description provided for @guidesSoilHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get guidesSoilHumidity;

  /// No description provided for @guidesSoilHelper.
  ///
  /// In en, this message translates to:
  /// **'Discover the characteristics of the environment where this truffle grows: humidity, altitude, and soil type.'**
  String get guidesSoilHelper;

  /// No description provided for @guidesHarvestPeriod.
  ///
  /// In en, this message translates to:
  /// **'Harvest period'**
  String get guidesHarvestPeriod;

  /// No description provided for @guidesTruffleQualityMetric.
  ///
  /// In en, this message translates to:
  /// **'Truffle quality'**
  String get guidesTruffleQualityMetric;

  /// No description provided for @guidesPriceRangeMetric.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get guidesPriceRangeMetric;

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

  /// No description provided for @sellerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Sellers'**
  String get sellerPageTitle;

  /// No description provided for @sellerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by first or last name'**
  String get sellerSearchHint;

  /// No description provided for @sellerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load sellers right now. Please try again.'**
  String get sellerLoadError;

  /// No description provided for @sellerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No sellers are available right now'**
  String get sellerEmptyTitle;

  /// No description provided for @sellerEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check back later to discover more verified profiles.'**
  String get sellerEmptySubtitle;

  /// No description provided for @sellerEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No sellers match your current filters'**
  String get sellerEmptyFilteredTitle;

  /// No description provided for @sellerEmptyFilteredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try removing a filter or changing your search.'**
  String get sellerEmptyFilteredSubtitle;

  /// No description provided for @sellerResetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get sellerResetFilters;

  /// No description provided for @sellerFilterRatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sellerFilterRatingTitle;

  /// No description provided for @sellerFilterCompletedOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Completed orders'**
  String get sellerFilterCompletedOrdersTitle;

  /// No description provided for @sellerFilterRatingThreePlus.
  ///
  /// In en, this message translates to:
  /// **'3+ stars'**
  String get sellerFilterRatingThreePlus;

  /// No description provided for @sellerFilterRatingFourPlus.
  ///
  /// In en, this message translates to:
  /// **'4+ stars'**
  String get sellerFilterRatingFourPlus;

  /// No description provided for @sellerFilterRatingFive.
  ///
  /// In en, this message translates to:
  /// **'5 stars'**
  String get sellerFilterRatingFive;

  /// No description provided for @sellerFilterCompletedOrdersFivePlus.
  ///
  /// In en, this message translates to:
  /// **'5+ orders'**
  String get sellerFilterCompletedOrdersFivePlus;

  /// No description provided for @sellerFilterCompletedOrdersTwentyPlus.
  ///
  /// In en, this message translates to:
  /// **'20+ orders'**
  String get sellerFilterCompletedOrdersTwentyPlus;

  /// No description provided for @sellerFilterCompletedOrdersFiftyPlus.
  ///
  /// In en, this message translates to:
  /// **'50+ orders'**
  String get sellerFilterCompletedOrdersFiftyPlus;

  /// No description provided for @sellerRatingNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get sellerRatingNew;

  /// No description provided for @sellerRegionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Region unavailable'**
  String get sellerRegionUnavailable;

  /// No description provided for @sellerActiveSearchFilter.
  ///
  /// In en, this message translates to:
  /// **'Search: {query}'**
  String sellerActiveSearchFilter(Object query);

  /// No description provided for @sellerReviewsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {No reviews} =1 {1 review} other {{count} reviews}}'**
  String sellerReviewsCount(int count);

  /// No description provided for @sellerCompletedOrdersShort.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 orders} =1 {1 order} other {{count} orders}}'**
  String sellerCompletedOrdersShort(int count);

  /// No description provided for @accountDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetailsTitle;

  /// No description provided for @accountDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account information up to date. Email changes require a new verification step.'**
  String get accountDetailsSubtitle;

  /// No description provided for @accountDetailsSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get accountDetailsSaveCta;

  /// No description provided for @accountDetailsPersonalSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get accountDetailsPersonalSectionTitle;

  /// No description provided for @accountDetailsEmailSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountDetailsEmailSectionTitle;

  /// No description provided for @accountDetailsLocationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get accountDetailsLocationSectionTitle;

  /// No description provided for @accountDetailsPhotoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile image'**
  String get accountDetailsPhotoSectionTitle;

  /// No description provided for @accountDetailsBioSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get accountDetailsBioSectionTitle;

  /// No description provided for @accountDetailsBioPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell buyers a little more about you'**
  String get accountDetailsBioPlaceholder;

  /// No description provided for @accountDetailsEmailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get accountDetailsEmailVerified;

  /// No description provided for @accountDetailsEmailHelper.
  ///
  /// In en, this message translates to:
  /// **'If you change your email, we will send a new verification link and the app will bring you back to the email verification screen.'**
  String get accountDetailsEmailHelper;

  /// No description provided for @accountDetailsChangeEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get accountDetailsChangeEmailCta;

  /// No description provided for @accountDetailsSaveNewEmailCta.
  ///
  /// In en, this message translates to:
  /// **'Save new email'**
  String get accountDetailsSaveNewEmailCta;

  /// No description provided for @accountDetailsCancelEmailChangeCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountDetailsCancelEmailChangeCta;

  /// No description provided for @accountDetailsPhotoHelper.
  ///
  /// In en, this message translates to:
  /// **'You can update the seller avatar from camera or gallery. If you remove the current photo, the profile falls back to initials.'**
  String get accountDetailsPhotoHelper;

  /// No description provided for @accountDetailsPhotoPendingHelper.
  ///
  /// In en, this message translates to:
  /// **'You selected a new photo locally. The final upload connection will be added in the next step without polluting the current data model.'**
  String get accountDetailsPhotoPendingHelper;

  /// No description provided for @accountDetailsChangePhotoCta.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get accountDetailsChangePhotoCta;

  /// No description provided for @accountDetailsRemovePhotoCta.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get accountDetailsRemovePhotoCta;

  /// No description provided for @accountDetailsTakePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get accountDetailsTakePhotoOption;

  /// No description provided for @accountDetailsChooseFromGalleryOption.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get accountDetailsChooseFromGalleryOption;

  /// No description provided for @accountDetailsPhotoSourceCancelOption.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountDetailsPhotoSourceCancelOption;

  /// No description provided for @accountDetailsPhotoUploadPending.
  ///
  /// In en, this message translates to:
  /// **'The new photo is ready as a local preview. We will connect the final upload in the next technical step.'**
  String get accountDetailsPhotoUploadPending;

  /// No description provided for @accountDetailsSellerCountryLockedHelper.
  ///
  /// In en, this message translates to:
  /// **'Seller accounts stay linked to Italy according to the current domain rules.'**
  String get accountDetailsSellerCountryLockedHelper;

  /// No description provided for @accountDetailsRegionHiddenHelper.
  ///
  /// In en, this message translates to:
  /// **'Region is only required when the selected country is Italy. Saving with another country will clear the region.'**
  String get accountDetailsRegionHiddenHelper;

  /// No description provided for @accountDetailsRequiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get accountDetailsRequiredFieldError;

  /// No description provided for @accountDetailsSellerCountryError.
  ///
  /// In en, this message translates to:
  /// **'Seller accounts must keep Italy as country.'**
  String get accountDetailsSellerCountryError;

  /// No description provided for @accountDetailsInvalidImageUrlError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid image URL.'**
  String get accountDetailsInvalidImageUrlError;

  /// No description provided for @accountDetailsSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again to continue.'**
  String get accountDetailsSessionExpired;

  /// No description provided for @accountDetailsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your account details right now.'**
  String get accountDetailsLoadError;

  /// No description provided for @accountDetailsSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save your account details right now. Please try again.'**
  String get accountDetailsSaveError;

  /// No description provided for @accountDetailsSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account details updated successfully.'**
  String get accountDetailsSaveSuccess;

  /// No description provided for @accountDetailsEmailVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to your new email address. Verify your email to continue.'**
  String get accountDetailsEmailVerificationSent;

  /// No description provided for @shippingAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping addresses'**
  String get shippingAddressesTitle;

  /// No description provided for @shippingAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose which address to keep ready for checkout and update it whenever your delivery details change.'**
  String get shippingAddressesSubtitle;

  /// No description provided for @shippingAddressesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved addresses'**
  String get shippingAddressesSectionTitle;

  /// No description provided for @shippingAddressesAddCta.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get shippingAddressesAddCta;

  /// No description provided for @shippingAddressesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get shippingAddressesEmptyTitle;

  /// No description provided for @shippingAddressesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first shipping address so it is ready to use during checkout.'**
  String get shippingAddressesEmptySubtitle;

  /// No description provided for @shippingAddressesDefaultBadge.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get shippingAddressesDefaultBadge;

  /// No description provided for @shippingAddressesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your shipping addresses right now.'**
  String get shippingAddressesLoadError;

  /// No description provided for @shippingAddressesNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error while loading shipping addresses. Please try again.'**
  String get shippingAddressesNetworkError;

  /// No description provided for @shippingAddressesUnauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again to manage shipping addresses.'**
  String get shippingAddressesUnauthorizedError;

  /// No description provided for @shippingAddressesNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This shipping address could not be found anymore.'**
  String get shippingAddressesNotFoundError;

  /// No description provided for @shippingAddressesValidationError.
  ///
  /// In en, this message translates to:
  /// **'Some shipping address data is invalid. Please review the form and try again.'**
  String get shippingAddressesValidationError;

  /// No description provided for @shippingAddressAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get shippingAddressAddTitle;

  /// No description provided for @shippingAddressEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get shippingAddressEditTitle;

  /// No description provided for @shippingAddressFormSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a dedicated shipping address for deliveries. The default address will be highlighted and ready for future checkout flows.'**
  String get shippingAddressFormSubtitle;

  /// No description provided for @shippingAddressSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get shippingAddressSaveCta;

  /// No description provided for @shippingAddressDeleteCta.
  ///
  /// In en, this message translates to:
  /// **'Delete address'**
  String get shippingAddressDeleteCta;

  /// No description provided for @shippingAddressDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this address?'**
  String get shippingAddressDeleteDialogTitle;

  /// No description provided for @shippingAddressDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This shipping address will be removed from your saved list.'**
  String get shippingAddressDeleteDialogMessage;

  /// No description provided for @shippingAddressDeleteDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get shippingAddressDeleteDialogCancel;

  /// No description provided for @shippingAddressDeleteDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get shippingAddressDeleteDialogConfirm;

  /// No description provided for @shippingAddressFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get shippingAddressFullNameLabel;

  /// No description provided for @shippingAddressFullNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get shippingAddressFullNamePlaceholder;

  /// No description provided for @shippingAddressStreetLabel.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get shippingAddressStreetLabel;

  /// No description provided for @shippingAddressStreetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Street and house number'**
  String get shippingAddressStreetPlaceholder;

  /// No description provided for @shippingAddressCityLabel.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get shippingAddressCityLabel;

  /// No description provided for @shippingAddressCityPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get shippingAddressCityPlaceholder;

  /// No description provided for @shippingAddressPostalCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get shippingAddressPostalCodeLabel;

  /// No description provided for @shippingAddressPostalCodePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter postal code'**
  String get shippingAddressPostalCodePlaceholder;

  /// No description provided for @shippingAddressCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get shippingAddressCountryLabel;

  /// No description provided for @shippingAddressCountryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select a country'**
  String get shippingAddressCountryPlaceholder;

  /// No description provided for @shippingAddressPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get shippingAddressPhoneLabel;

  /// No description provided for @shippingAddressPhonePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get shippingAddressPhonePlaceholder;

  /// No description provided for @shippingAddressDefaultToggleLabel.
  ///
  /// In en, this message translates to:
  /// **'Set as default address'**
  String get shippingAddressDefaultToggleLabel;

  /// No description provided for @shippingAddressDefaultToggleHelper.
  ///
  /// In en, this message translates to:
  /// **'Default addresses are highlighted in your list and ready for future checkout selection.'**
  String get shippingAddressDefaultToggleHelper;

  /// No description provided for @shippingAddressRequiredFieldError.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get shippingAddressRequiredFieldError;

  /// No description provided for @shippingAddressFullNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Full name is required.'**
  String get shippingAddressFullNameRequiredError;

  /// No description provided for @shippingAddressStreetRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Street is required.'**
  String get shippingAddressStreetRequiredError;

  /// No description provided for @shippingAddressCityRequiredError.
  ///
  /// In en, this message translates to:
  /// **'City is required.'**
  String get shippingAddressCityRequiredError;

  /// No description provided for @shippingAddressCityInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid city name.'**
  String get shippingAddressCityInvalidError;

  /// No description provided for @shippingAddressPostalCodeRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Postal code is required.'**
  String get shippingAddressPostalCodeRequiredError;

  /// No description provided for @shippingAddressPostalCodeInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid postal code.'**
  String get shippingAddressPostalCodeInvalidError;

  /// No description provided for @shippingAddressCountryRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Country is required.'**
  String get shippingAddressCountryRequiredError;

  /// No description provided for @shippingAddressCountryInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Select a valid country.'**
  String get shippingAddressCountryInvalidError;

  /// No description provided for @shippingAddressPhoneRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Phone is required.'**
  String get shippingAddressPhoneRequiredError;

  /// No description provided for @shippingAddressPhoneInvalidError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number with prefix.'**
  String get shippingAddressPhoneInvalidError;

  /// No description provided for @shippingAddressValidationFallback.
  ///
  /// In en, this message translates to:
  /// **'Review this field and try again.'**
  String get shippingAddressValidationFallback;

  /// No description provided for @shippingAddressSaveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save this shipping address right now. Please try again.'**
  String get shippingAddressSaveError;

  /// No description provided for @shippingAddressSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shipping address saved successfully.'**
  String get shippingAddressSavedSuccess;

  /// No description provided for @shippingAddressDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Shipping address deleted successfully.'**
  String get shippingAddressDeletedSuccess;

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

  /// No description provided for @publishTruffleSubmitInProgress.
  ///
  /// In en, this message translates to:
  /// **'A publish request for this truffle is already in progress. Please wait a few seconds and try again.'**
  String get publishTruffleSubmitInProgress;

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

  /// No description provided for @sellerMyTrufflesTitle.
  ///
  /// In en, this message translates to:
  /// **'My truffles'**
  String get sellerMyTrufflesTitle;

  /// No description provided for @sellerMyTrufflesTabPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing'**
  String get sellerMyTrufflesTabPublishing;

  /// No description provided for @sellerMyTrufflesTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get sellerMyTrufflesTabActive;

  /// No description provided for @sellerMyTrufflesTabReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get sellerMyTrufflesTabReserved;

  /// No description provided for @sellerMyTrufflesTabSold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sellerMyTrufflesTabSold;

  /// No description provided for @sellerMyTrufflesTabExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get sellerMyTrufflesTabExpired;

  /// No description provided for @sellerMyTrufflesStatusPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing'**
  String get sellerMyTrufflesStatusPublishing;

  /// No description provided for @sellerMyTrufflesStatusReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get sellerMyTrufflesStatusReserved;

  /// No description provided for @sellerMyTrufflesEmptyPublishingTitle.
  ///
  /// In en, this message translates to:
  /// **'No truffles are publishing'**
  String get sellerMyTrufflesEmptyPublishingTitle;

  /// No description provided for @sellerMyTrufflesEmptyPublishingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publishing listings appear here until they are ready to become visible to buyers.'**
  String get sellerMyTrufflesEmptyPublishingSubtitle;

  /// No description provided for @sellerMyTrufflesEmptyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'No active truffles'**
  String get sellerMyTrufflesEmptyActiveTitle;

  /// No description provided for @sellerMyTrufflesEmptyActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a truffle and it will appear here while it is available.'**
  String get sellerMyTrufflesEmptyActiveSubtitle;

  /// No description provided for @sellerMyTrufflesEmptyReservedTitle.
  ///
  /// In en, this message translates to:
  /// **'No reserved truffles'**
  String get sellerMyTrufflesEmptyReservedTitle;

  /// No description provided for @sellerMyTrufflesEmptyReservedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Truffles with an open order in progress appear here until the sale is completed or cancelled.'**
  String get sellerMyTrufflesEmptyReservedSubtitle;

  /// No description provided for @sellerMyTrufflesEmptySoldTitle.
  ///
  /// In en, this message translates to:
  /// **'No sold truffles'**
  String get sellerMyTrufflesEmptySoldTitle;

  /// No description provided for @sellerMyTrufflesEmptySoldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed sales will appear here once a truffle has been purchased.'**
  String get sellerMyTrufflesEmptySoldSubtitle;

  /// No description provided for @sellerMyTrufflesEmptyExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'No expired truffles'**
  String get sellerMyTrufflesEmptyExpiredTitle;

  /// No description provided for @sellerMyTrufflesEmptyExpiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Expired truffles will remain visible here for quick reference.'**
  String get sellerMyTrufflesEmptyExpiredSubtitle;

  /// No description provided for @sellerMyTrufflesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load your truffles right now.'**
  String get sellerMyTrufflesLoadError;

  /// No description provided for @sellerMyTrufflesRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sellerMyTrufflesRetry;

  /// No description provided for @sellerMyTrufflesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this truffle?'**
  String get sellerMyTrufflesDeleteTitle;

  /// No description provided for @sellerMyTrufflesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. The truffle, its images, and related saves will be removed.'**
  String get sellerMyTrufflesDeleteMessage;

  /// No description provided for @sellerMyTrufflesDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sellerMyTrufflesDeleteCancel;

  /// No description provided for @sellerMyTrufflesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get sellerMyTrufflesDeleteConfirm;

  /// No description provided for @sellerMyTrufflesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Truffle deleted successfully.'**
  String get sellerMyTrufflesDeleteSuccess;

  /// No description provided for @sellerMyTrufflesDeleteForbidden.
  ///
  /// In en, this message translates to:
  /// **'This truffle can no longer be deleted.'**
  String get sellerMyTrufflesDeleteForbidden;

  /// No description provided for @sellerMyTrufflesDeleteNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection issue while deleting the truffle. Please try again.'**
  String get sellerMyTrufflesDeleteNetwork;

  /// No description provided for @sellerMyTrufflesDeleteUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again before deleting a truffle.'**
  String get sellerMyTrufflesDeleteUnauthenticated;

  /// No description provided for @sellerMyTrufflesDeleteUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete the truffle right now.'**
  String get sellerMyTrufflesDeleteUnknown;

  /// No description provided for @accountLanguageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get accountLanguageItalian;

  /// No description provided for @accountLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get accountLanguageEnglish;

  /// No description provided for @accountSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get accountSupportTitle;

  /// No description provided for @accountSupportIntro.
  ///
  /// In en, this message translates to:
  /// **'Find quick answers about orders, shipping, and delivery support.'**
  String get accountSupportIntro;

  /// No description provided for @accountSupportFaqSection.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get accountSupportFaqSection;

  /// No description provided for @accountSupportFaqOrderFlowQuestion.
  ///
  /// In en, this message translates to:
  /// **'How does an order work on Truffly?'**
  String get accountSupportFaqOrderFlowQuestion;

  /// No description provided for @accountSupportFaqOrderFlowAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose your truffle, confirm the order, and we will keep you updated until delivery.'**
  String get accountSupportFaqOrderFlowAnswer;

  /// No description provided for @accountSupportFaqShippingTimingQuestion.
  ///
  /// In en, this message translates to:
  /// **'When is the truffle shipped?'**
  String get accountSupportFaqShippingTimingQuestion;

  /// No description provided for @accountSupportFaqShippingTimingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Fresh truffles are prepared and shipped as quickly as possible after order confirmation.'**
  String get accountSupportFaqShippingTimingAnswer;

  /// No description provided for @accountSupportFaqOrderTrackingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can I follow my order status?'**
  String get accountSupportFaqOrderTrackingQuestion;

  /// No description provided for @accountSupportFaqOrderTrackingAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can check the latest order status from the My orders section in your account.'**
  String get accountSupportFaqOrderTrackingAnswer;

  /// No description provided for @accountSupportFaqCancellationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel an order?'**
  String get accountSupportFaqCancellationQuestion;

  /// No description provided for @accountSupportFaqCancellationAnswer.
  ///
  /// In en, this message translates to:
  /// **'If you need to cancel an order, contact support as soon as possible and we will review the request.'**
  String get accountSupportFaqCancellationAnswer;

  /// No description provided for @accountSupportFaqDeliveryIssueQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens if there is a delivery problem?'**
  String get accountSupportFaqDeliveryIssueQuestion;

  /// No description provided for @accountSupportFaqDeliveryIssueAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write to support with your order details and we will help you resolve the issue quickly.'**
  String get accountSupportFaqDeliveryIssueAnswer;

  /// No description provided for @accountSupportFaqContactQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can I contact support?'**
  String get accountSupportFaqContactQuestion;

  /// No description provided for @accountSupportFaqContactAnswer.
  ///
  /// In en, this message translates to:
  /// **'Use the email below to contact the Truffly team directly.'**
  String get accountSupportFaqContactAnswer;

  /// No description provided for @accountSupportContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get accountSupportContactTitle;

  /// No description provided for @accountSupportContactBody.
  ///
  /// In en, this message translates to:
  /// **'If you need help with an order or delivery, write to us and include the main details.'**
  String get accountSupportContactBody;

  /// No description provided for @accountSupportContactCta.
  ///
  /// In en, this message translates to:
  /// **'Write to support'**
  String get accountSupportContactCta;

  /// No description provided for @accountSupportEmailLaunchError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open your email app right now.'**
  String get accountSupportEmailLaunchError;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get accountSettingsTitle;

  /// No description provided for @accountSettingsIntro.
  ///
  /// In en, this message translates to:
  /// **'Manage language, notifications, and account information from one place.'**
  String get accountSettingsIntro;

  /// No description provided for @accountSettingsPreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get accountSettingsPreferencesSection;

  /// No description provided for @accountSettingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get accountSettingsLanguageLabel;

  /// No description provided for @accountSettingsNotificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountSettingsNotificationsLabel;

  /// No description provided for @accountSettingsLanguageSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a language'**
  String get accountSettingsLanguageSheetTitle;

  /// No description provided for @accountSettingsLanguageSheetBody.
  ///
  /// In en, this message translates to:
  /// **'This updates the language used across the app.'**
  String get accountSettingsLanguageSheetBody;

  /// No description provided for @accountSettingsLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get accountSettingsLegalSection;

  /// No description provided for @accountSettingsPrivacyPolicyLabel.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get accountSettingsPrivacyPolicyLabel;

  /// No description provided for @accountSettingsTermsLabel.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get accountSettingsTermsLabel;

  /// No description provided for @accountSettingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSettingsAccountSection;

  /// No description provided for @accountSettingsDeleteAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountSettingsDeleteAccountLabel;

  /// No description provided for @accountSettingsDeleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get accountSettingsDeleteAccountDialogTitle;

  /// No description provided for @accountSettingsDeleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This action is not available yet from the app. Confirm only if you want to continue as soon as the flow is ready.'**
  String get accountSettingsDeleteAccountDialogBody;

  /// No description provided for @accountSettingsDeleteAccountDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get accountSettingsDeleteAccountDialogCancel;

  /// No description provided for @accountSettingsDeleteAccountDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get accountSettingsDeleteAccountDialogConfirm;

  /// No description provided for @accountSettingsDeleteAccountPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is not available in-app yet. Contact support if you need immediate help.'**
  String get accountSettingsDeleteAccountPendingMessage;

  /// No description provided for @accountPrivacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get accountPrivacyPolicyTitle;

  /// No description provided for @accountPrivacyPolicyLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Your privacy on Truffly'**
  String get accountPrivacyPolicyLeadTitle;

  /// No description provided for @accountPrivacyPolicyLeadBody.
  ///
  /// In en, this message translates to:
  /// **'This summary explains how Truffly handles the information used to create your account, manage orders, and support your activity in the app.'**
  String get accountPrivacyPolicyLeadBody;

  /// No description provided for @accountPrivacyPolicySectionDataTitle.
  ///
  /// In en, this message translates to:
  /// **'What data we collect'**
  String get accountPrivacyPolicySectionDataTitle;

  /// No description provided for @accountPrivacyPolicySectionDataBody.
  ///
  /// In en, this message translates to:
  /// **'We may collect profile details, shipping information, order references, and messages you send to support so we can provide the service.'**
  String get accountPrivacyPolicySectionDataBody;

  /// No description provided for @accountPrivacyPolicySectionUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'How we use it'**
  String get accountPrivacyPolicySectionUsageTitle;

  /// No description provided for @accountPrivacyPolicySectionUsageBody.
  ///
  /// In en, this message translates to:
  /// **'We use this information to manage your account, process orders, improve the marketplace experience, and communicate important updates.'**
  String get accountPrivacyPolicySectionUsageBody;

  /// No description provided for @accountPrivacyPolicySectionSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'When data can be shared'**
  String get accountPrivacyPolicySectionSharingTitle;

  /// No description provided for @accountPrivacyPolicySectionSharingBody.
  ///
  /// In en, this message translates to:
  /// **'Information is shared only when necessary to complete your order, operate the platform, comply with legal obligations, or assist you with support requests.'**
  String get accountPrivacyPolicySectionSharingBody;

  /// No description provided for @accountPrivacyPolicySectionRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your choices'**
  String get accountPrivacyPolicySectionRightsTitle;

  /// No description provided for @accountPrivacyPolicySectionRightsBody.
  ///
  /// In en, this message translates to:
  /// **'You can review and update the account information available in the app. Future versions will include more tools to manage privacy requests directly.'**
  String get accountPrivacyPolicySectionRightsBody;

  /// No description provided for @accountTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get accountTermsTitle;

  /// No description provided for @accountTermsLeadTitle.
  ///
  /// In en, this message translates to:
  /// **'Using the Truffly app'**
  String get accountTermsLeadTitle;

  /// No description provided for @accountTermsLeadBody.
  ///
  /// In en, this message translates to:
  /// **'These terms summarize the basic rules for browsing the marketplace, placing orders, and interacting with sellers through Truffly.'**
  String get accountTermsLeadBody;

  /// No description provided for @accountTermsSectionOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders and availability'**
  String get accountTermsSectionOrdersTitle;

  /// No description provided for @accountTermsSectionOrdersBody.
  ///
  /// In en, this message translates to:
  /// **'Product availability can change quickly because fresh truffles are seasonal. Order confirmation depends on availability and final seller validation.'**
  String get accountTermsSectionOrdersBody;

  /// No description provided for @accountTermsSectionShippingTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping and delivery'**
  String get accountTermsSectionShippingTitle;

  /// No description provided for @accountTermsSectionShippingBody.
  ///
  /// In en, this message translates to:
  /// **'Shipping timelines may vary based on destination, freshness requirements, and courier operations. We will share relevant updates in your order flow whenever possible.'**
  String get accountTermsSectionShippingBody;

  /// No description provided for @accountTermsSectionSupportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support and issues'**
  String get accountTermsSectionSupportTitle;

  /// No description provided for @accountTermsSectionSupportBody.
  ///
  /// In en, this message translates to:
  /// **'If there is an issue with an order or delivery, contact support promptly so the team can review the situation and guide you on the next steps.'**
  String get accountTermsSectionSupportBody;

  /// No description provided for @accountTermsSectionUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Future updates'**
  String get accountTermsSectionUpdatesTitle;

  /// No description provided for @accountTermsSectionUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'These texts are an MVP version and may be updated as Truffly expands its legal and operational flows.'**
  String get accountTermsSectionUpdatesBody;
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
