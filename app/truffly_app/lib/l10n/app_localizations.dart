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

  /// No description provided for @authErrorEmailResendRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You requested too many verification emails. Wait a few minutes and try again.'**
  String get authErrorEmailResendRateLimited;

  /// No description provided for @authErrorEmailDeliveryRestricted.
  ///
  /// In en, this message translates to:
  /// **'We cannot send the verification email to this address. Check the email you entered or configure custom SMTP.'**
  String get authErrorEmailDeliveryRestricted;

  /// No description provided for @authPasswordResetRateLimitedError.
  ///
  /// In en, this message translates to:
  /// **'You requested too many reset links. Wait a few minutes and try again.'**
  String get authPasswordResetRateLimitedError;

  /// No description provided for @authPasswordResetDeliveryRestrictedError.
  ///
  /// In en, this message translates to:
  /// **'We cannot send the reset email to this address. Check the email you entered or configure custom SMTP.'**
  String get authPasswordResetDeliveryRestrictedError;

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

  /// No description provided for @authVerifyEmailWrongEmailCta.
  ///
  /// In en, this message translates to:
  /// **'I entered the wrong email'**
  String get authVerifyEmailWrongEmailCta;

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
  /// **'We sent you a new verification email. Check your inbox.'**
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
  /// **'Check your email: we sent you a link to reset your password.'**
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

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring the authentic taste of truffles home'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The first marketplace dedicated to fresh truffles'**
  String get authWelcomeSubtitle;

  /// No description provided for @authWelcomeCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up to Truffly'**
  String get authWelcomeCreateAccountButton;

  /// No description provided for @authWelcomeLoginButton.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get authWelcomeLoginButton;

  /// No description provided for @authWelcomeFooterInfo.
  ///
  /// In en, this message translates to:
  /// **'About Truffly: Our platform'**
  String get authWelcomeFooterInfo;

  /// No description provided for @welcomeFreshTrufflesHome.
  ///
  /// In en, this message translates to:
  /// **'Fresh truffles at your door'**
  String get welcomeFreshTrufflesHome;

  /// No description provided for @welcomeRealFreshTruffle.
  ///
  /// In en, this message translates to:
  /// **'Real fresh truffle'**
  String get welcomeRealFreshTruffle;

  /// No description provided for @welcomeDiscoverNewFlavors.
  ///
  /// In en, this message translates to:
  /// **'Discover new flavors'**
  String get welcomeDiscoverNewFlavors;

  /// No description provided for @welcomeVerifiedHunters.
  ///
  /// In en, this message translates to:
  /// **'Verified truffle hunters'**
  String get welcomeVerifiedHunters;

  /// No description provided for @welcomeSelectedQuality.
  ///
  /// In en, this message translates to:
  /// **'Selected quality'**
  String get welcomeSelectedQuality;

  /// No description provided for @welcomeProtectedPurchases.
  ///
  /// In en, this message translates to:
  /// **'Protected purchases'**
  String get welcomeProtectedPurchases;

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
  /// **'At the moment, only truffle hunters residing in Italy can sell on Truffly. By continuing, you confirm that you reside in Italy.'**
  String get onboardingSellerRegionSubtitle;

  /// No description provided for @onboardingSellerDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your seller account'**
  String get onboardingSellerDocumentsTitle;

  /// No description provided for @onboardingSellerDocumentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your ID and truffle hunting license to complete your verification and start selling on Truffly.'**
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
  /// **'Truffle license'**
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

  /// No description provided for @onboardingDocumentUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get onboardingDocumentUploadButton;

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

  /// No description provided for @onboardingDocumentRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get onboardingDocumentRequiredLabel;

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

  /// No description provided for @onboardingNotificationsBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboardingNotificationsBuyerTitle;

  /// No description provided for @onboardingNotificationsBuyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive updates about your orders, shipments, and favorite truffles.'**
  String get onboardingNotificationsBuyerSubtitle;

  /// No description provided for @onboardingNotificationsBuyerBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Order confirmations and shipping updates.'**
  String get onboardingNotificationsBuyerBenefit1;

  /// No description provided for @onboardingNotificationsBuyerBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Delivery and tracking notifications.'**
  String get onboardingNotificationsBuyerBenefit2;

  /// No description provided for @onboardingNotificationsBuyerBenefit3.
  ///
  /// In en, this message translates to:
  /// **'New truffles matching your interests.'**
  String get onboardingNotificationsBuyerBenefit3;

  /// No description provided for @onboardingNotificationsSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboardingNotificationsSellerTitle;

  /// No description provided for @onboardingNotificationsSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive updates on orders, shipments, and payments.'**
  String get onboardingNotificationsSellerSubtitle;

  /// No description provided for @onboardingNotificationsSellerBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Instant notifications for new orders.'**
  String get onboardingNotificationsSellerBenefit1;

  /// No description provided for @onboardingNotificationsSellerBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Shipping reminders for active orders.'**
  String get onboardingNotificationsSellerBenefit2;

  /// No description provided for @onboardingNotificationsSellerBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Payment and payout updates.'**
  String get onboardingNotificationsSellerBenefit3;

  /// No description provided for @onboardingNotificationsEnableButton.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get onboardingNotificationsEnableButton;

  /// No description provided for @onboardingNotificationsContinueWithoutButton.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
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

  /// No description provided for @onboardingNotificationsStatusProvisional.
  ///
  /// In en, this message translates to:
  /// **'Notifications are provisionally enabled on iOS.'**
  String get onboardingNotificationsStatusProvisional;

  /// No description provided for @onboardingNotificationsStatusNotDetermined.
  ///
  /// In en, this message translates to:
  /// **'Notification permission has not been decided yet.'**
  String get onboardingNotificationsStatusNotDetermined;

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

  /// No description provided for @notificationsOpenSystemSettingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled in your phone settings. Open Truffly notification settings and turn them on, then try again.'**
  String get notificationsOpenSystemSettingsMessage;

  /// No description provided for @onboardingWelcomeBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Your truffle journey starts here'**
  String get onboardingWelcomeBuyerTitle;

  /// No description provided for @onboardingWelcomeBuyerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your buyer onboarding is complete.'**
  String get onboardingWelcomeBuyerSubtitle;

  /// No description provided for @onboardingWelcomeBuyerMessage.
  ///
  /// In en, this message translates to:
  /// **'Discover freshly harvested truffles, meet passionate hunters, and experience the authentic world of truffles.'**
  String get onboardingWelcomeBuyerMessage;

  /// No description provided for @onboardingWelcomeBuyerReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'You\'re ready'**
  String get onboardingWelcomeBuyerReadyLabel;

  /// No description provided for @onboardingWelcomeSellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Application submitted\nsuccessfully'**
  String get onboardingWelcomeSellerTitle;

  /// No description provided for @onboardingWelcomeSellerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your seller request is under review.'**
  String get onboardingWelcomeSellerSubtitle;

  /// No description provided for @onboardingWelcomeSellerMessage.
  ///
  /// In en, this message translates to:
  /// **'Thank you! We\'ve received your application. We\'ll notify you as soon as it is updated.'**
  String get onboardingWelcomeSellerMessage;

  /// No description provided for @onboardingWelcomeSellerReviewDocumentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Document verification'**
  String get onboardingWelcomeSellerReviewDocumentsTitle;

  /// No description provided for @onboardingWelcomeSellerReviewDocumentsBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll review your ID and truffle hunting license.'**
  String get onboardingWelcomeSellerReviewDocumentsBody;

  /// No description provided for @onboardingWelcomeSellerNotifyUpdatesTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll keep you updated'**
  String get onboardingWelcomeSellerNotifyUpdatesTitle;

  /// No description provided for @onboardingWelcomeSellerNotifyUpdatesBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll receive a notification if your application is approved or if we need more information.'**
  String get onboardingWelcomeSellerNotifyUpdatesBody;

  /// No description provided for @onboardingWelcomeSellerExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the marketplace'**
  String get onboardingWelcomeSellerExploreTitle;

  /// No description provided for @onboardingWelcomeSellerExploreBody.
  ///
  /// In en, this message translates to:
  /// **'In the meantime, explore Truffly and discover available truffles.'**
  String get onboardingWelcomeSellerExploreBody;

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
  /// **'The true taste of fresh truffles'**
  String get onboardingBuyerInfo1Title;

  /// No description provided for @onboardingBuyerInfo1Description.
  ///
  /// In en, this message translates to:
  /// **'Discover the taste and aroma of freshly harvested truffles, shipped directly from truffle hunters.'**
  String get onboardingBuyerInfo1Description;

  /// No description provided for @onboardingBuyerInfo2Title.
  ///
  /// In en, this message translates to:
  /// **'Verified hunters, real reviews'**
  String get onboardingBuyerInfo2Title;

  /// No description provided for @onboardingBuyerInfo2Description.
  ///
  /// In en, this message translates to:
  /// **'Buy with confidence from verified truffle hunters and discover authentic reviews shared by other buyers.'**
  String get onboardingBuyerInfo2Description;

  /// No description provided for @onboardingBuyerInfo3Title.
  ///
  /// In en, this message translates to:
  /// **'We\'ve got the security covered'**
  String get onboardingBuyerInfo3Title;

  /// No description provided for @onboardingBuyerInfo3Description.
  ///
  /// In en, this message translates to:
  /// **'With Truffly, your payment remains protected until your order reaches its destination.'**
  String get onboardingBuyerInfo3Description;

  /// No description provided for @onboardingSellerInfo1Title.
  ///
  /// In en, this message translates to:
  /// **'Give your truffles the value they deserve'**
  String get onboardingSellerInfo1Title;

  /// No description provided for @onboardingSellerInfo1Description.
  ///
  /// In en, this message translates to:
  /// **'Sell directly to a community of truffle enthusiasts, without intermediaries. Set your own price and reach buyers ready to purchase.'**
  String get onboardingSellerInfo1Description;

  /// No description provided for @onboardingSellerInfo2Title.
  ///
  /// In en, this message translates to:
  /// **'No upfront costs'**
  String get onboardingSellerInfo2Title;

  /// No description provided for @onboardingSellerInfo2Description.
  ///
  /// In en, this message translates to:
  /// **'No registration fees and no upfront costs. We retain a 10% commission only on completed sales.'**
  String get onboardingSellerInfo2Description;

  /// No description provided for @onboardingSellerInfo3Title.
  ///
  /// In en, this message translates to:
  /// **'A marketplace built around freshness'**
  String get onboardingSellerInfo3Title;

  /// No description provided for @onboardingSellerInfo3Description.
  ///
  /// In en, this message translates to:
  /// **'To preserve quality and freshness, listings remain active for 5 days and orders must be shipped within 2 business days of the sale.'**
  String get onboardingSellerInfo3Description;

  /// No description provided for @onboardingSellerInfo4Title.
  ///
  /// In en, this message translates to:
  /// **'A verified community'**
  String get onboardingSellerInfo4Title;

  /// No description provided for @onboardingSellerInfo4Description.
  ///
  /// In en, this message translates to:
  /// **'To sell on Truffly, you\'ll need to verify your identity and truffle license. Payments are transferred through Stripe after the buyer confirms delivery.'**
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
  /// **'How would you like to use Truffly?'**
  String get onboardingRoleSelectionTitle;

  /// No description provided for @onboardingRoleSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buy fresh truffles from the best truffle hunters or start selling yours directly to the community.'**
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
  /// **'What are you looking for?'**
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
  /// **'No matching products'**
  String get truffleEmptyTitle;

  /// No description provided for @truffleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try changing filters\nor check again later.'**
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
  /// **'Smooth Black'**
  String get truffleTypeMacrosporum;

  /// No description provided for @truffleTypeBrumaleMoschatum.
  ///
  /// In en, this message translates to:
  /// **'Musky Brumal'**
  String get truffleTypeBrumaleMoschatum;

  /// No description provided for @truffleTypeMesentericum.
  ///
  /// In en, this message translates to:
  /// **'Mesenteric'**
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

  /// No description provided for @sellerProfileInfoTab.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get sellerProfileInfoTab;

  /// No description provided for @sellerProfileReviewsTab.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get sellerProfileReviewsTab;

  /// No description provided for @sellerProfileTrufflesTab.
  ///
  /// In en, this message translates to:
  /// **'Truffles'**
  String get sellerProfileTrufflesTab;

  /// No description provided for @sellerProfileRatingStarsLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get sellerProfileRatingStarsLabel;

  /// No description provided for @sellerProfileOrdersLabel.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get sellerProfileOrdersLabel;

  /// No description provided for @sellerProfileActiveTrufflesLabel.
  ///
  /// In en, this message translates to:
  /// **'Active truffles'**
  String get sellerProfileActiveTrufflesLabel;

  /// No description provided for @sellerProfileBioFallback.
  ///
  /// In en, this message translates to:
  /// **'This seller has not added a description yet.'**
  String get sellerProfileBioFallback;

  /// No description provided for @sellerProfileJoinedPlatformLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined the platform'**
  String get sellerProfileJoinedPlatformLabel;

  /// No description provided for @sellerProfileSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller summary'**
  String get sellerProfileSummaryTitle;

  /// No description provided for @sellerProfileJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get sellerProfileJoinedLabel;

  /// No description provided for @sellerProfileRegionLabel.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get sellerProfileRegionLabel;

  /// No description provided for @sellerProfileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get sellerProfileUnavailable;

  /// No description provided for @sellerProfileRecentReviewsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent reviews'**
  String get sellerProfileRecentReviewsTitle;

  /// No description provided for @sellerProfileReadAll.
  ///
  /// In en, this message translates to:
  /// **'Read all'**
  String get sellerProfileReadAll;

  /// No description provided for @sellerProfileNoReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews for this seller yet.'**
  String get sellerProfileNoReviews;

  /// No description provided for @sellerProfileActiveTrufflesTitle.
  ///
  /// In en, this message translates to:
  /// **'Active truffles'**
  String get sellerProfileActiveTrufflesTitle;

  /// No description provided for @sellerProfileNoActiveTruffles.
  ///
  /// In en, this message translates to:
  /// **'This seller has no active truffles right now.'**
  String get sellerProfileNoActiveTruffles;

  /// No description provided for @sellerProfileUnableToLoadReviews.
  ///
  /// In en, this message translates to:
  /// **'Unable to load reviews right now.'**
  String get sellerProfileUnableToLoadReviews;

  /// No description provided for @sellerProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load this seller profile right now.'**
  String get sellerProfileLoadError;

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
  /// **'You can update your profile photo from camera or gallery. The new image uploads right away after selection.'**
  String get accountDetailsPhotoHelper;

  /// No description provided for @accountDetailsPhotoUploadPending.
  ///
  /// In en, this message translates to:
  /// **'Uploading profile photo...'**
  String get accountDetailsPhotoUploadPending;

  /// No description provided for @accountDetailsPhotoUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated successfully.'**
  String get accountDetailsPhotoUploadSuccess;

  /// No description provided for @accountDetailsPhotoRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile photo removed.'**
  String get accountDetailsPhotoRemoveSuccess;

  /// No description provided for @accountDetailsPhotoPickerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to pick an image right now.'**
  String get accountDetailsPhotoPickerUnavailable;

  /// No description provided for @accountDetailsPhotoPermissionDeniedError.
  ///
  /// In en, this message translates to:
  /// **'Permission denied. Allow access to your photos and try again.'**
  String get accountDetailsPhotoPermissionDeniedError;

  /// No description provided for @accountDetailsPhotoCameraUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable right now.'**
  String get accountDetailsPhotoCameraUnavailableError;

  /// No description provided for @accountDetailsPhotoGalleryUnavailableError.
  ///
  /// In en, this message translates to:
  /// **'Gallery unavailable right now.'**
  String get accountDetailsPhotoGalleryUnavailableError;

  /// No description provided for @accountDetailsPhotoFileNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'The selected file could not be found.'**
  String get accountDetailsPhotoFileNotFoundError;

  /// No description provided for @accountDetailsPhotoTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'The selected image must be 5 MB or smaller.'**
  String get accountDetailsPhotoTooLargeError;

  /// No description provided for @accountDetailsPhotoUnsupportedFormatError.
  ///
  /// In en, this message translates to:
  /// **'Use a JPG, PNG, or WebP image.'**
  String get accountDetailsPhotoUnsupportedFormatError;

  /// No description provided for @accountDetailsPhotoInvalidFileError.
  ///
  /// In en, this message translates to:
  /// **'The selected image could not be read.'**
  String get accountDetailsPhotoInvalidFileError;

  /// No description provided for @accountDetailsPhotoUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Unable to upload the profile photo right now. Please try again.'**
  String get accountDetailsPhotoUploadFailedError;

  /// No description provided for @accountDetailsPhotoDeleteFailedError.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove the profile photo right now. Please try again.'**
  String get accountDetailsPhotoDeleteFailedError;

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
  /// **'Check both your current and new email addresses and confirm both links to complete the change.'**
  String get accountDetailsEmailVerificationSent;

  /// No description provided for @shippingAddressesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shippingAddressesTitle;

  /// No description provided for @shippingAddressesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add and manage shipping addresses for your orders.'**
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
  /// **'You cannot publish this truffle right now.'**
  String get publishTruffleSubmitNotAllowed;

  /// No description provided for @publishTruffleSubmitStripeVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Stripe is still verifying your account. You can manage verification directly in Stripe.'**
  String get publishTruffleSubmitStripeVerificationPending;

  /// No description provided for @publishTruffleSubmitStripeOnboardingRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete Stripe registration to publish this truffle.'**
  String get publishTruffleSubmitStripeOnboardingRequired;

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
  /// **'Find quick answers about buying, selling, payments, shipping, and your account.'**
  String get accountSupportIntro;

  /// No description provided for @accountSupportFaqBuyingOrdersSection.
  ///
  /// In en, this message translates to:
  /// **'Buying & Orders'**
  String get accountSupportFaqBuyingOrdersSection;

  /// No description provided for @accountSupportFaqBuyTruffleQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I buy a truffle?'**
  String get accountSupportFaqBuyTruffleQuestion;

  /// No description provided for @accountSupportFaqBuyTruffleAnswer.
  ///
  /// In en, this message translates to:
  /// **'Browse available truffles, open a listing, review the product details, select a shipping address, and complete payment securely through Truffly.'**
  String get accountSupportFaqBuyTruffleAnswer;

  /// No description provided for @accountSupportFaqTrackOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'How can I track my order?'**
  String get accountSupportFaqTrackOrderQuestion;

  /// No description provided for @accountSupportFaqTrackOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'Once the seller ships your order and provides a tracking number, it will appear on the Order Details page.'**
  String get accountSupportFaqTrackOrderAnswer;

  /// No description provided for @accountSupportFaqAfterOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens after I place an order?'**
  String get accountSupportFaqAfterOrderQuestion;

  /// No description provided for @accountSupportFaqAfterOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'After payment, the seller has up to 48 hours to ship the truffles and provide tracking information. You will receive updates through the app and, if enabled, push notifications.'**
  String get accountSupportFaqAfterOrderAnswer;

  /// No description provided for @accountSupportFaqSellerDoesNotShipQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens if the seller does not ship?'**
  String get accountSupportFaqSellerDoesNotShipQuestion;

  /// No description provided for @accountSupportFaqSellerDoesNotShipAnswer.
  ///
  /// In en, this message translates to:
  /// **'If the seller does not provide tracking information within the required timeframe, the order may be automatically cancelled and refunded.'**
  String get accountSupportFaqSellerDoesNotShipAnswer;

  /// No description provided for @accountSupportFaqConfirmDeliveryQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I confirm delivery?'**
  String get accountSupportFaqConfirmDeliveryQuestion;

  /// No description provided for @accountSupportFaqConfirmDeliveryAnswer.
  ///
  /// In en, this message translates to:
  /// **'When your order arrives, open the Order Details page and tap \"Confirm Delivery\". This confirms that the order was received successfully.'**
  String get accountSupportFaqConfirmDeliveryAnswer;

  /// No description provided for @accountSupportFaqTrufflesQualitySection.
  ///
  /// In en, this message translates to:
  /// **'Truffles & Quality'**
  String get accountSupportFaqTrufflesQualitySection;

  /// No description provided for @accountSupportFaqTrufflesFreshQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are the truffles fresh?'**
  String get accountSupportFaqTrufflesFreshQuestion;

  /// No description provided for @accountSupportFaqTrufflesFreshAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Sellers are required to publish freshly harvested truffles and provide the harvest date for each listing.'**
  String get accountSupportFaqTrufflesFreshAnswer;

  /// No description provided for @accountSupportFaqQualityGradesQuestion.
  ///
  /// In en, this message translates to:
  /// **'What do the quality grades mean?'**
  String get accountSupportFaqQualityGradesQuestion;

  /// No description provided for @accountSupportFaqQualityGradesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Quality grades help describe the appearance and condition of the truffles. First Quality generally includes the most regular and visually appealing truffles, while lower grades may have cosmetic imperfections but remain suitable for consumption.'**
  String get accountSupportFaqQualityGradesAnswer;

  /// No description provided for @accountSupportFaqStoreTrufflesQuestion.
  ///
  /// In en, this message translates to:
  /// **'How should I store fresh truffles?'**
  String get accountSupportFaqStoreTrufflesQuestion;

  /// No description provided for @accountSupportFaqStoreTrufflesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Fresh truffles should be stored in the refrigerator in a sealed container with absorbent paper. Replace the paper daily and consume the truffles as soon as possible for the best experience.'**
  String get accountSupportFaqStoreTrufflesAnswer;

  /// No description provided for @accountSupportFaqDamagedOrderQuestion.
  ///
  /// In en, this message translates to:
  /// **'What should I do if my order arrives damaged?'**
  String get accountSupportFaqDamagedOrderQuestion;

  /// No description provided for @accountSupportFaqDamagedOrderAnswer.
  ///
  /// In en, this message translates to:
  /// **'Contact support as soon as possible and provide photos of the product, packaging, and shipping label. We will review the situation and assist where possible.'**
  String get accountSupportFaqDamagedOrderAnswer;

  /// No description provided for @accountSupportFaqShippingDeliverySection.
  ///
  /// In en, this message translates to:
  /// **'Shipping & Delivery'**
  String get accountSupportFaqShippingDeliverySection;

  /// No description provided for @accountSupportFaqSupportedCountriesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which countries can I order from?'**
  String get accountSupportFaqSupportedCountriesQuestion;

  /// No description provided for @accountSupportFaqSupportedCountriesAnswer.
  ///
  /// In en, this message translates to:
  /// **'Buyers located within supported European countries can place orders through Truffly.'**
  String get accountSupportFaqSupportedCountriesAnswer;

  /// No description provided for @accountSupportFaqShippingCostQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much does shipping cost?'**
  String get accountSupportFaqShippingCostQuestion;

  /// No description provided for @accountSupportFaqShippingCostAnswer.
  ///
  /// In en, this message translates to:
  /// **'Shipping costs are determined by the seller and are displayed before checkout.'**
  String get accountSupportFaqShippingCostAnswer;

  /// No description provided for @accountSupportFaqTrackingNumberQuestion.
  ///
  /// In en, this message translates to:
  /// **'Will I receive a tracking number?'**
  String get accountSupportFaqTrackingNumberQuestion;

  /// No description provided for @accountSupportFaqTrackingNumberAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Sellers must provide tracking information when shipping an order.'**
  String get accountSupportFaqTrackingNumberAnswer;

  /// No description provided for @accountSupportFaqPackageDelayedQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens if my package is delayed?'**
  String get accountSupportFaqPackageDelayedQuestion;

  /// No description provided for @accountSupportFaqPackageDelayedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Delivery times depend on the shipping carrier. If your package appears delayed, check the tracking information first. If the issue persists, contact support.'**
  String get accountSupportFaqPackageDelayedAnswer;

  /// No description provided for @accountSupportFaqPaymentsRefundsSection.
  ///
  /// In en, this message translates to:
  /// **'Payments & Refunds'**
  String get accountSupportFaqPaymentsRefundsSection;

  /// No description provided for @accountSupportFaqSecurePaymentsQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are payments secure?'**
  String get accountSupportFaqSecurePaymentsQuestion;

  /// No description provided for @accountSupportFaqSecurePaymentsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes. Payments are processed securely through Stripe. Truffly does not store your full payment card details.'**
  String get accountSupportFaqSecurePaymentsAnswer;

  /// No description provided for @accountSupportFaqPaymentChargedQuestion.
  ///
  /// In en, this message translates to:
  /// **'When is my payment charged?'**
  String get accountSupportFaqPaymentChargedQuestion;

  /// No description provided for @accountSupportFaqPaymentChargedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your payment is charged when the order is successfully placed.'**
  String get accountSupportFaqPaymentChargedAnswer;

  /// No description provided for @accountSupportFaqRefundsWorkQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do refunds work?'**
  String get accountSupportFaqRefundsWorkQuestion;

  /// No description provided for @accountSupportFaqRefundsWorkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Refunds may be issued in accordance with the Refund & Cancellation Policy. Refund eligibility depends on the order status and the circumstances of the request.'**
  String get accountSupportFaqRefundsWorkAnswer;

  /// No description provided for @accountSupportFaqRefundTimingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long does a refund take?'**
  String get accountSupportFaqRefundTimingQuestion;

  /// No description provided for @accountSupportFaqRefundTimingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Refund processing times vary depending on your bank and payment provider. Most refunds are completed within a few business days.'**
  String get accountSupportFaqRefundTimingAnswer;

  /// No description provided for @accountSupportFaqSellingSection.
  ///
  /// In en, this message translates to:
  /// **'Selling on Truffly'**
  String get accountSupportFaqSellingSection;

  /// No description provided for @accountSupportFaqBecomeSellerQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I become a seller?'**
  String get accountSupportFaqBecomeSellerQuestion;

  /// No description provided for @accountSupportFaqBecomeSellerAnswer.
  ///
  /// In en, this message translates to:
  /// **'Complete the seller application process, upload the required documents, and wait for approval from the Truffly team.'**
  String get accountSupportFaqBecomeSellerAnswer;

  /// No description provided for @accountSupportFaqVerifyIdentityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why do I need to verify my identity?'**
  String get accountSupportFaqVerifyIdentityQuestion;

  /// No description provided for @accountSupportFaqVerifyIdentityAnswer.
  ///
  /// In en, this message translates to:
  /// **'Verification helps maintain trust and safety on the platform and ensures that only eligible sellers can publish products.'**
  String get accountSupportFaqVerifyIdentityAnswer;

  /// No description provided for @accountSupportFaqSellerApprovalTimingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long does seller approval take?'**
  String get accountSupportFaqSellerApprovalTimingQuestion;

  /// No description provided for @accountSupportFaqSellerApprovalTimingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Most applications are reviewed within a few business days, although processing times may vary.'**
  String get accountSupportFaqSellerApprovalTimingAnswer;

  /// No description provided for @accountSupportFaqPublishAfterApprovalQuestion.
  ///
  /// In en, this message translates to:
  /// **'Can I publish truffles immediately after approval?'**
  String get accountSupportFaqPublishAfterApprovalQuestion;

  /// No description provided for @accountSupportFaqPublishAfterApprovalAnswer.
  ///
  /// In en, this message translates to:
  /// **'Before publishing, approved sellers must complete the required Stripe onboarding process for receiving payouts.'**
  String get accountSupportFaqPublishAfterApprovalAnswer;

  /// No description provided for @accountSupportFaqSellerPaymentsSection.
  ///
  /// In en, this message translates to:
  /// **'Seller Payments'**
  String get accountSupportFaqSellerPaymentsSection;

  /// No description provided for @accountSupportFaqSellerPaymentTimingQuestion.
  ///
  /// In en, this message translates to:
  /// **'When do I receive payment?'**
  String get accountSupportFaqSellerPaymentTimingQuestion;

  /// No description provided for @accountSupportFaqSellerPaymentTimingAnswer.
  ///
  /// In en, this message translates to:
  /// **'Payments are released after the order has been completed according to the Truffly payment process.'**
  String get accountSupportFaqSellerPaymentTimingAnswer;

  /// No description provided for @accountSupportFaqStripeAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why do I need a Stripe account?'**
  String get accountSupportFaqStripeAccountQuestion;

  /// No description provided for @accountSupportFaqStripeAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Stripe securely handles seller payouts and helps verify payment information and identity requirements.'**
  String get accountSupportFaqStripeAccountAnswer;

  /// No description provided for @accountSupportFaqCommissionQuestion.
  ///
  /// In en, this message translates to:
  /// **'How much commission does Truffly charge?'**
  String get accountSupportFaqCommissionQuestion;

  /// No description provided for @accountSupportFaqCommissionAnswer.
  ///
  /// In en, this message translates to:
  /// **'Truffly charges a fixed commission on completed sales. The current commission is displayed during the seller onboarding process.'**
  String get accountSupportFaqCommissionAnswer;

  /// No description provided for @accountSupportFaqAccountPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Account & Privacy'**
  String get accountSupportFaqAccountPrivacySection;

  /// No description provided for @accountSupportFaqDeleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get accountSupportFaqDeleteAccountQuestion;

  /// No description provided for @accountSupportFaqDeleteAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can request account deletion from the Settings page inside the app.'**
  String get accountSupportFaqDeleteAccountAnswer;

  /// No description provided for @accountSupportFaqAfterDeleteAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'What happens when I delete my account?'**
  String get accountSupportFaqAfterDeleteAccountQuestion;

  /// No description provided for @accountSupportFaqAfterDeleteAccountAnswer.
  ///
  /// In en, this message translates to:
  /// **'Personal data will be deleted or anonymized where possible. Certain records may be retained where required by law or necessary for security, accounting, or fraud prevention purposes.'**
  String get accountSupportFaqAfterDeleteAccountAnswer;

  /// No description provided for @accountSupportFaqProtectDataQuestion.
  ///
  /// In en, this message translates to:
  /// **'How does Truffly protect my data?'**
  String get accountSupportFaqProtectDataQuestion;

  /// No description provided for @accountSupportFaqProtectDataAnswer.
  ///
  /// In en, this message translates to:
  /// **'Truffly uses secure authentication, protected storage, access controls, and other technical measures designed to protect user information.'**
  String get accountSupportFaqProtectDataAnswer;

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

  /// No description provided for @accountSettingsNotificationsUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Unable to update the notifications preference.'**
  String get accountSettingsNotificationsUpdateError;

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
  /// **'We will delete your account if there is no transaction history. If you have orders or sold truffles, we will deactivate and anonymize it instead.'**
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

  /// No description provided for @accountSettingsDeleteAccountDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted. You have been signed out.'**
  String get accountSettingsDeleteAccountDeletedMessage;

  /// No description provided for @accountSettingsDeleteAccountDeactivatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account was deactivated for compliance. You have been signed out.'**
  String get accountSettingsDeleteAccountDeactivatedMessage;

  /// No description provided for @accountSettingsDeleteAccountUnauthorizedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again to delete your account.'**
  String get accountSettingsDeleteAccountUnauthorizedMessage;

  /// No description provided for @accountSettingsDeleteAccountInactiveMessage.
  ///
  /// In en, this message translates to:
  /// **'This account is already inactive.'**
  String get accountSettingsDeleteAccountInactiveMessage;

  /// No description provided for @accountSettingsDeleteAccountErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to process your account request right now. Please try again.'**
  String get accountSettingsDeleteAccountErrorMessage;

  /// No description provided for @notificationsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsInboxTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsUnreadLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationsUnreadLabel;

  /// No description provided for @notificationsReadLabel.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get notificationsReadLabel;

  /// No description provided for @notificationsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up. New updates will appear here.'**
  String get notificationsEmptyState;

  /// No description provided for @notificationsErrorState.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications right now.'**
  String get notificationsErrorState;

  /// No description provided for @notificationsRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get notificationsRetryButton;

  /// No description provided for @notificationGenericTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationGenericTitle;

  /// No description provided for @notificationGenericMessage.
  ///
  /// In en, this message translates to:
  /// **'Open the notification center to view the latest update.'**
  String get notificationGenericMessage;

  /// No description provided for @notificationFallbackTruffleName.
  ///
  /// In en, this message translates to:
  /// **'your truffle'**
  String get notificationFallbackTruffleName;

  /// No description provided for @notificationFallbackSellerName.
  ///
  /// In en, this message translates to:
  /// **'the seller'**
  String get notificationFallbackSellerName;

  /// No description provided for @notificationFallbackTrackingCode.
  ///
  /// In en, this message translates to:
  /// **'tracking unavailable'**
  String get notificationFallbackTrackingCode;

  /// No description provided for @notificationFallbackSellerAmount.
  ///
  /// In en, this message translates to:
  /// **'your payout'**
  String get notificationFallbackSellerAmount;

  /// No description provided for @notificationOrderConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get notificationOrderConfirmedTitle;

  /// No description provided for @notificationOrderConfirmedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order “{truffleName}” has been confirmed. The seller has 48 hours to ship it.'**
  String notificationOrderConfirmedMessage(Object truffleName);

  /// No description provided for @notificationPaymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get notificationPaymentFailedTitle;

  /// No description provided for @notificationPaymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The payment for “{truffleName}” failed. You can try again from checkout.'**
  String notificationPaymentFailedMessage(Object truffleName);

  /// No description provided for @notificationOrderShippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order shipped'**
  String get notificationOrderShippedTitle;

  /// No description provided for @notificationOrderShippedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order “{truffleName}” has been shipped.'**
  String notificationOrderShippedMessage(Object truffleName);

  /// No description provided for @notificationTrackingAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking available'**
  String get notificationTrackingAvailableTitle;

  /// No description provided for @notificationTrackingAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Tracking is available for “{truffleName}”: {trackingCode}.'**
  String notificationTrackingAvailableMessage(
    Object truffleName,
    Object trackingCode,
  );

  /// No description provided for @notificationDeliveryConfirmationReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get notificationDeliveryConfirmationReminderTitle;

  /// No description provided for @notificationDeliveryConfirmationReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Have you received “{truffleName}”? Confirm delivery to complete the order.'**
  String notificationDeliveryConfirmationReminderMessage(Object truffleName);

  /// No description provided for @notificationOrderCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order completed'**
  String get notificationOrderCompletedTitle;

  /// No description provided for @notificationOrderCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” has been completed.'**
  String notificationOrderCompletedMessage(Object truffleName);

  /// No description provided for @notificationOrderAutoCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order automatically completed'**
  String get notificationOrderAutoCompletedTitle;

  /// No description provided for @notificationOrderAutoCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” was automatically completed.'**
  String notificationOrderAutoCompletedMessage(Object truffleName);

  /// No description provided for @notificationOrderCancelledBySellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationOrderCancelledBySellerTitle;

  /// No description provided for @notificationOrderCancelledBySellerMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” was cancelled by the seller. Your refund will be started.'**
  String notificationOrderCancelledBySellerMessage(Object truffleName);

  /// No description provided for @notificationOrderAutoCancelledUnshippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationOrderAutoCancelledUnshippedTitle;

  /// No description provided for @notificationOrderAutoCancelledUnshippedMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” was cancelled because it was not shipped within 48 hours.'**
  String notificationOrderAutoCancelledUnshippedMessage(Object truffleName);

  /// No description provided for @notificationRefundStartedTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund started'**
  String get notificationRefundStartedTitle;

  /// No description provided for @notificationRefundStartedMessage.
  ///
  /// In en, this message translates to:
  /// **'The refund for “{truffleName}” has been started.'**
  String notificationRefundStartedMessage(Object truffleName);

  /// No description provided for @notificationRefundCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund completed'**
  String get notificationRefundCompletedTitle;

  /// No description provided for @notificationRefundCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The refund for “{truffleName}” has been completed.'**
  String notificationRefundCompletedMessage(Object truffleName);

  /// No description provided for @notificationReviewRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get notificationReviewRequestTitle;

  /// No description provided for @notificationReviewRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'How was your experience with “{sellerName}”? Leave a review for “{truffleName}”.'**
  String notificationReviewRequestMessage(
    Object sellerName,
    Object truffleName,
  );

  /// No description provided for @notificationReviewAutoCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic review'**
  String get notificationReviewAutoCreatedTitle;

  /// No description provided for @notificationReviewAutoCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'We automatically completed the review for “{truffleName}”.'**
  String notificationReviewAutoCreatedMessage(Object truffleName);

  /// No description provided for @notificationFavoriteTruffleUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffle no longer available'**
  String get notificationFavoriteTruffleUnavailableTitle;

  /// No description provided for @notificationFavoriteTruffleUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'“{truffleName}” is no longer available.'**
  String notificationFavoriteTruffleUnavailableMessage(Object truffleName);

  /// No description provided for @notificationFavoriteTruffleExpiringTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing expiring soon'**
  String get notificationFavoriteTruffleExpiringTitle;

  /// No description provided for @notificationFavoriteTruffleExpiringMessage.
  ///
  /// In en, this message translates to:
  /// **'“{truffleName}” is still available, but the listing is about to expire.'**
  String notificationFavoriteTruffleExpiringMessage(Object truffleName);

  /// No description provided for @notificationSellerApplicationSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request submitted'**
  String get notificationSellerApplicationSubmittedTitle;

  /// No description provided for @notificationSellerApplicationSubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request to sell on Truffly has been submitted. We’ll notify you once it has been reviewed.'**
  String get notificationSellerApplicationSubmittedMessage;

  /// No description provided for @notificationSellerApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller approved'**
  String get notificationSellerApprovedTitle;

  /// No description provided for @notificationSellerApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have been approved as a seller. Complete Stripe to start publishing truffles.'**
  String get notificationSellerApprovedMessage;

  /// No description provided for @notificationSellerRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Request not approved'**
  String get notificationSellerRejectedTitle;

  /// No description provided for @notificationSellerRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your seller request was not approved. Check the details or contact support.'**
  String get notificationSellerRejectedMessage;

  /// No description provided for @notificationStripeOnboardingRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up payments'**
  String get notificationStripeOnboardingRequiredTitle;

  /// No description provided for @notificationStripeOnboardingRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete your payment setup to start selling on Truffly.'**
  String get notificationStripeOnboardingRequiredMessage;

  /// No description provided for @notificationStripeOnboardingCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments set up'**
  String get notificationStripeOnboardingCompletedTitle;

  /// No description provided for @notificationStripeOnboardingCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'Payments are set up. You can now publish your truffles.'**
  String get notificationStripeOnboardingCompletedMessage;

  /// No description provided for @notificationTrufflePublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffle published'**
  String get notificationTrufflePublishedTitle;

  /// No description provided for @notificationTrufflePublishedMessage.
  ///
  /// In en, this message translates to:
  /// **'“{truffleName}” has been published and is now visible to users.'**
  String notificationTrufflePublishedMessage(Object truffleName);

  /// No description provided for @notificationTruffleDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Truffle deleted'**
  String get notificationTruffleDeletedTitle;

  /// No description provided for @notificationTruffleDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'“{truffleName}” has been deleted.'**
  String notificationTruffleDeletedMessage(Object truffleName);

  /// No description provided for @notificationTruffleExpiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing expired'**
  String get notificationTruffleExpiredTitle;

  /// No description provided for @notificationTruffleExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The listing “{truffleName}” has expired and is no longer visible.'**
  String notificationTruffleExpiredMessage(Object truffleName);

  /// No description provided for @notificationSellerNewOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'New order received'**
  String get notificationSellerNewOrderTitle;

  /// No description provided for @notificationSellerNewOrderMessage.
  ///
  /// In en, this message translates to:
  /// **'You received a new order for “{truffleName}”. Ship it within 48 hours.'**
  String notificationSellerNewOrderMessage(Object truffleName);

  /// No description provided for @notificationSellerShipping24hReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Shipping reminder'**
  String get notificationSellerShipping24hReminderTitle;

  /// No description provided for @notificationSellerShipping24hReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Remember to ship “{truffleName}”. You still have 24 hours to add tracking.'**
  String notificationSellerShipping24hReminderMessage(Object truffleName);

  /// No description provided for @notificationSellerShippingFinalReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Final shipping reminder'**
  String get notificationSellerShippingFinalReminderTitle;

  /// No description provided for @notificationSellerShippingFinalReminderMessage.
  ///
  /// In en, this message translates to:
  /// **'Last hours to ship “{truffleName}”. If you do not add tracking, the order will be cancelled.'**
  String notificationSellerShippingFinalReminderMessage(Object truffleName);

  /// No description provided for @notificationSellerOrderCancelledUnshippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationSellerOrderCancelledUnshippedTitle;

  /// No description provided for @notificationSellerOrderCancelledUnshippedMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” was cancelled because it was not shipped within 48 hours.'**
  String notificationSellerOrderCancelledUnshippedMessage(Object truffleName);

  /// No description provided for @notificationSellerOrderMarkedShippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order shipped'**
  String get notificationSellerOrderMarkedShippedTitle;

  /// No description provided for @notificationSellerOrderMarkedShippedMessage.
  ///
  /// In en, this message translates to:
  /// **'You marked “{truffleName}” as shipped. We’ll notify the buyer.'**
  String notificationSellerOrderMarkedShippedMessage(Object truffleName);

  /// No description provided for @notificationSellerDeliveryConfirmedByBuyerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery confirmed'**
  String get notificationSellerDeliveryConfirmedByBuyerTitle;

  /// No description provided for @notificationSellerDeliveryConfirmedByBuyerMessage.
  ///
  /// In en, this message translates to:
  /// **'The buyer confirmed delivery of “{truffleName}”.'**
  String notificationSellerDeliveryConfirmedByBuyerMessage(Object truffleName);

  /// No description provided for @notificationSellerOrderAutoCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Order automatically completed'**
  String get notificationSellerOrderAutoCompletedTitle;

  /// No description provided for @notificationSellerOrderAutoCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The order “{truffleName}” was automatically completed.'**
  String notificationSellerOrderAutoCompletedMessage(Object truffleName);

  /// No description provided for @notificationSellerPaymentReleasedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment released'**
  String get notificationSellerPaymentReleasedTitle;

  /// No description provided for @notificationSellerPaymentReleasedMessage.
  ///
  /// In en, this message translates to:
  /// **'The payment for “{truffleName}” has been released. You will receive {sellerAmount}.'**
  String notificationSellerPaymentReleasedMessage(
    Object truffleName,
    Object sellerAmount,
  );

  /// No description provided for @notificationSellerPaymentProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment processing'**
  String get notificationSellerPaymentProcessingTitle;

  /// No description provided for @notificationSellerPaymentProcessingMessage.
  ///
  /// In en, this message translates to:
  /// **'The payment for “{truffleName}” is being processed.'**
  String notificationSellerPaymentProcessingMessage(Object truffleName);

  /// No description provided for @notificationSellerPaymentFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment issue'**
  String get notificationSellerPaymentFailedTitle;

  /// No description provided for @notificationSellerPaymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'There is an issue with the payment for “{truffleName}”. We are checking it.'**
  String notificationSellerPaymentFailedMessage(Object truffleName);

  /// No description provided for @notificationSellerNewReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'New review'**
  String get notificationSellerNewReviewTitle;

  /// No description provided for @notificationSellerNewReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'You received a new review for “{truffleName}”.'**
  String notificationSellerNewReviewMessage(Object truffleName);

  /// No description provided for @notificationSellerAutoReviewReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatic review received'**
  String get notificationSellerAutoReviewReceivedTitle;

  /// No description provided for @notificationSellerAutoReviewReceivedMessage.
  ///
  /// In en, this message translates to:
  /// **'An automatic review was added for the order “{truffleName}”.'**
  String notificationSellerAutoReviewReceivedMessage(Object truffleName);

  /// No description provided for @notificationBuyerWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Truffly 👋'**
  String get notificationBuyerWelcomeTitle;

  /// No description provided for @notificationBuyerWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Explore fresh truffles, discover new hunters, and bring the authentic taste of truffles home.'**
  String get notificationBuyerWelcomeMessage;

  /// No description provided for @notificationProfileUpdatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get notificationProfileUpdatedTitle;

  /// No description provided for @notificationProfileUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your profile changes have been saved.'**
  String get notificationProfileUpdatedMessage;

  /// No description provided for @notificationSecurityNewLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'New login'**
  String get notificationSecurityNewLoginTitle;

  /// No description provided for @notificationSecurityNewLoginMessage.
  ///
  /// In en, this message translates to:
  /// **'A new login to your account was detected.'**
  String get notificationSecurityNewLoginMessage;

  /// No description provided for @notificationTitleGeneric.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationTitleGeneric;

  /// No description provided for @notificationTitleOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order update'**
  String get notificationTitleOrderPlaced;

  /// No description provided for @notificationTitleOrderShipped.
  ///
  /// In en, this message translates to:
  /// **'Order shipped'**
  String get notificationTitleOrderShipped;

  /// No description provided for @notificationTitleOrderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order completed'**
  String get notificationTitleOrderCompleted;

  /// No description provided for @notificationTitleOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get notificationTitleOrderCancelled;

  /// No description provided for @notificationTitleSellerApplicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Seller application'**
  String get notificationTitleSellerApplicationSubmitted;

  /// No description provided for @notificationTitleSellerApproved.
  ///
  /// In en, this message translates to:
  /// **'Seller approved'**
  String get notificationTitleSellerApproved;

  /// No description provided for @notificationTitleSellerRejected.
  ///
  /// In en, this message translates to:
  /// **'Seller rejected'**
  String get notificationTitleSellerRejected;

  /// No description provided for @notificationTitlePayoutReleased.
  ///
  /// In en, this message translates to:
  /// **'Payout released'**
  String get notificationTitlePayoutReleased;

  /// No description provided for @notificationTitleFavoriteTruffleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Saved truffle unavailable'**
  String get notificationTitleFavoriteTruffleDeleted;

  /// No description provided for @notificationMessageOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Your order has been confirmed. The seller can now prepare it.'**
  String get notificationMessageOrderPlaced;

  /// No description provided for @notificationMessageOrderShipped.
  ///
  /// In en, this message translates to:
  /// **'The seller has shipped your order.'**
  String get notificationMessageOrderShipped;

  /// No description provided for @notificationMessageOrderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your order has been completed.'**
  String get notificationMessageOrderCompleted;

  /// No description provided for @notificationMessageOrderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Your order was cancelled or refunded.'**
  String get notificationMessageOrderCancelled;

  /// No description provided for @notificationMessageOrderAutoCancelledUnshippedBuyer.
  ///
  /// In en, this message translates to:
  /// **'Your order was cancelled and refunded because the seller did not ship it within 48 hours.'**
  String get notificationMessageOrderAutoCancelledUnshippedBuyer;

  /// No description provided for @notificationMessageOrderAutoCancelledUnshippedSeller.
  ///
  /// In en, this message translates to:
  /// **'The order was cancelled and refunded because it was not shipped within 48 hours.'**
  String get notificationMessageOrderAutoCancelledUnshippedSeller;

  /// No description provided for @notificationTitleBuyerReviewCreated.
  ///
  /// In en, this message translates to:
  /// **'New review'**
  String get notificationTitleBuyerReviewCreated;

  /// No description provided for @notificationMessageBuyerReviewCreated.
  ///
  /// In en, this message translates to:
  /// **'A buyer left a review for one of your completed orders.'**
  String get notificationMessageBuyerReviewCreated;

  /// No description provided for @notificationTitleAutoReviewCreated.
  ///
  /// In en, this message translates to:
  /// **'Automatic review'**
  String get notificationTitleAutoReviewCreated;

  /// No description provided for @notificationMessageAutoReviewCreated.
  ///
  /// In en, this message translates to:
  /// **'An automatic review was created after the review window expired.'**
  String get notificationMessageAutoReviewCreated;

  /// No description provided for @notificationTitleOrderDeliveryConfirmationReminder.
  ///
  /// In en, this message translates to:
  /// **'Delivery reminder'**
  String get notificationTitleOrderDeliveryConfirmationReminder;

  /// No description provided for @notificationMessageOrderDeliveryConfirmationReminder.
  ///
  /// In en, this message translates to:
  /// **'Please confirm delivery within 48 hours or the order will be auto-completed.'**
  String get notificationMessageOrderDeliveryConfirmationReminder;

  /// No description provided for @notificationMessageSellerApplicationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'We have received your request. Your documents are under review.'**
  String get notificationMessageSellerApplicationSubmitted;

  /// No description provided for @notificationMessageSellerApproved.
  ///
  /// In en, this message translates to:
  /// **'Your request to become a seller has been approved.'**
  String get notificationMessageSellerApproved;

  /// No description provided for @notificationMessageSellerRejected.
  ///
  /// In en, this message translates to:
  /// **'Your request to become a seller was not approved.'**
  String get notificationMessageSellerRejected;

  /// No description provided for @notificationMessagePayoutReleased.
  ///
  /// In en, this message translates to:
  /// **'A payout has been released.'**
  String get notificationMessagePayoutReleased;

  /// No description provided for @notificationMessageFavoriteTruffleDeleted.
  ///
  /// In en, this message translates to:
  /// **'A truffle you saved is no longer available.'**
  String get notificationMessageFavoriteTruffleDeleted;

  /// No description provided for @reviewSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Review your order'**
  String get reviewSectionTitle;

  /// No description provided for @reviewSectionCopy.
  ///
  /// In en, this message translates to:
  /// **'Your review helps other buyers choose with more confidence and highlights the seller\'s work.'**
  String get reviewSectionCopy;

  /// No description provided for @reviewUnavailableCopy.
  ///
  /// In en, this message translates to:
  /// **'Reviewing is no longer available for this order.'**
  String get reviewUnavailableCopy;

  /// No description provided for @reviewLeaveCta.
  ///
  /// In en, this message translates to:
  /// **'Leave a review'**
  String get reviewLeaveCta;

  /// No description provided for @reviewSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Review sent'**
  String get reviewSubmittedLabel;

  /// No description provided for @reviewSubmittedSnackBar.
  ///
  /// In en, this message translates to:
  /// **'Thanks, your review has been published.'**
  String get reviewSubmittedSnackBar;

  /// No description provided for @reviewSubmitErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to submit the review right now.'**
  String get reviewSubmitErrorMessage;

  /// No description provided for @reviewSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How was your experience?'**
  String get reviewSheetTitle;

  /// No description provided for @reviewSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your review helps other buyers choose with more confidence and highlights the seller\'s work.'**
  String get reviewSheetSubtitle;

  /// No description provided for @reviewRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get reviewRatingLabel;

  /// No description provided for @reviewCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get reviewCommentLabel;

  /// No description provided for @reviewCommentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tell us how it went: freshness, shipping, truffle quality…'**
  String get reviewCommentPlaceholder;

  /// No description provided for @reviewWindowNote.
  ///
  /// In en, this message translates to:
  /// **'You have 48 hours to leave a review. After that, a 5-star automatic review will be published.'**
  String get reviewWindowNote;

  /// No description provided for @reviewSubmitCta.
  ///
  /// In en, this message translates to:
  /// **'Publish review'**
  String get reviewSubmitCta;

  /// No description provided for @reviewCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get reviewCancelCta;

  /// No description provided for @reviewRatingRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please choose a rating.'**
  String get reviewRatingRequiredError;

  /// No description provided for @reviewAutoLabel.
  ///
  /// In en, this message translates to:
  /// **'Automatically created review'**
  String get reviewAutoLabel;

  /// No description provided for @reviewAutoCommentCompletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Automatic review: order completed successfully.'**
  String get reviewAutoCommentCompletedSuccess;

  /// No description provided for @reviewAutoCommentUnshipped48h.
  ///
  /// In en, this message translates to:
  /// **'Automatic review: order was not shipped within 48 hours.'**
  String get reviewAutoCommentUnshipped48h;

  /// No description provided for @reviewWindowExpiredMessage.
  ///
  /// In en, this message translates to:
  /// **'The time to leave a review has expired. If you did not submit one, the planned automatic rating will be recorded.'**
  String get reviewWindowExpiredMessage;

  /// No description provided for @reviewAlreadySubmittedMessage.
  ///
  /// In en, this message translates to:
  /// **'You already left a review for this order.'**
  String get reviewAlreadySubmittedMessage;

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

  /// No description provided for @accountSettingsRefundAndCancellationLabel.
  ///
  /// In en, this message translates to:
  /// **'Refund & Cancellation'**
  String get accountSettingsRefundAndCancellationLabel;

  /// No description provided for @accountSettingsLegalInformationLabel.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get accountSettingsLegalInformationLabel;

  /// No description provided for @accountRefundAndCancellationTitle.
  ///
  /// In en, this message translates to:
  /// **'Refund & Cancellation'**
  String get accountRefundAndCancellationTitle;

  /// No description provided for @accountLegalInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get accountLegalInformationTitle;

  /// No description provided for @accountPrivacyPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'Last updated: [Date]\n\nTruffly respects your privacy and is committed to protecting your personal data.\n\nThis Privacy Policy explains how Truffly collects, uses, stores, shares, and protects personal information when you use the Truffly mobile application and related services.\n\n1. Data Controller\n\nThe data controller is:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nEmail: [Privacy email]\nSupport email: truffly@gmail.com\n\n2. What Truffly is\n\nTruffly is a marketplace that connects buyers with verified Italian truffle hunters and sellers.\n\nTruffly provides the digital platform, account management, payment flow, order tools, seller verification tools, notifications, and support features.\n\nTruffly does not directly sell the truffles listed by sellers unless expressly stated otherwise.\n\n3. Personal data we collect\n\nWhen you use Truffly, we may collect the following data:\n\nAccount data\n• first name\n• last name\n• email address\n• password credentials managed through our authentication provider\n• country\n• region, where applicable\n• profile image, if uploaded\n• account role, such as buyer or seller\n\nBuyer data\n• shipping addresses\n• phone number for delivery\n• order history\n• favorite products\n• reviews submitted\n• support requests\n\nSeller data\n• seller profile information\n• region\n• bio\n• seller application status\n• truffle license or permit information\n• seller verification documents\n• Stripe Connect onboarding status\n• published products\n• sales history\n• reviews received\n\nOrder and payment data\n• purchased product\n• seller and buyer IDs\n• order amount\n• shipping cost\n• commission amount\n• payment status\n• refund status\n• Stripe transaction identifiers\n• tracking code\n• order status\n\nTruffly does not store full card numbers or complete payment card details. Payments are processed by Stripe.\n\nTechnical data\n• device information\n• operating system\n• IP address\n• app logs\n• security logs\n• push notification token\n• authentication session data\n\n4. Why we use your data\n\nWe process personal data to:\n• create and manage your account\n• allow you to buy and sell truffles\n• verify seller applications\n• process payments and refunds\n• manage orders and shipping information\n• send order-related notifications\n• provide customer support\n• prevent fraud and misuse\n• secure the platform\n• comply with legal obligations\n• manage account deletion and data requests\n\n5. Legal basis for processing\n\nWe process your data under the following legal bases:\n\nContract performance\nTo provide the Truffly service, manage accounts, process orders, and enable payments.\n\nLegal obligations\nTo comply with applicable laws, accounting obligations, consumer protection rules, and requests from competent authorities.\n\nLegitimate interest\nTo protect the platform, prevent fraud, verify sellers, maintain audit logs, and improve security.\n\nConsent\nFor push notifications and any optional processing where consent is required.\n\nYou can withdraw consent for notifications at any time through your device settings or Truffly settings where available.\n\n6. Seller verification documents\n\nIf you apply to become a seller, Truffly may request documents to verify your identity and your eligibility to sell truffles.\n\nThese documents are used only for verification and platform safety.\n\nWhere possible, identity documents are deleted after the verification process is completed, unless retention is required by law or necessary to protect Truffly against fraud, disputes, or legal claims.\n\nSeller license or permit information may be retained for as long as your seller account remains active and for any additional period required by law or legitimate compliance needs.\n\n7. Payments\n\nPayments are processed through Stripe.\n\nStripe may collect and process payment data, identity verification data, tax information, bank account details, and other information required to provide payment services.\n\nTruffly may receive and store payment identifiers, order status, refund status, and seller payout status, but does not store full payment card details.\n\n8. Push notifications\n\nTruffly may send push notifications related to:\n• order confirmations\n• shipment updates\n• refund updates\n• seller approval or rejection\n• payment release\n• important account or security notices\n\nYou can disable push notifications through your device settings.\n\nSome important service communications may still be shown inside the app.\n\n9. Who we share data with\n\nWe may share data with:\n• Stripe, for payments and seller onboarding\n• Supabase, for authentication, database, and storage\n• Firebase Cloud Messaging, for push notifications\n• hosting, infrastructure, security, and technical service providers\n• competent authorities, where legally required\n• buyers and sellers, only where necessary to complete an order\n\nFor example, a seller may receive shipping information needed to fulfill an order. A buyer may see seller profile information, ratings, and order-related details.\n\n10. International transfers\n\nSome service providers may process data outside the European Economic Area.\n\nWhere this happens, Truffly relies on appropriate safeguards, such as Standard Contractual Clauses or other lawful transfer mechanisms under applicable data protection laws.\n\n11. Data retention\n\nWe keep personal data only for as long as necessary.\n\nIndicatively:\n• account data: for as long as the account is active\n• order data: for the period required by law and accounting obligations\n• seller verification data: for the time necessary for verification and compliance\n• support requests: for the time necessary to manage the request and protect legal rights\n• security logs: for security, fraud prevention, and audit purposes\n• deleted accounts: data is deleted or anonymized unless retention is legally required\n\nIf an account has completed orders, reviews, payments, refunds, or seller activity, some data may need to be retained to comply with legal obligations and protect the rights of users and Truffly.\n\n12. Account deletion\n\nYou may request deletion of your account from within the app.\n\nWhen you delete your account, Truffly will delete or anonymize personal data where possible.\n\nSome data may be retained where necessary to:\n• comply with legal obligations\n• maintain accounting records\n• manage disputes\n• prevent fraud\n• protect the rights of Truffly, buyers, or sellers\n\nIf you are a seller or have completed transactions, order records may be retained in anonymized or limited form.\n\n13. Your rights\n\nUnder applicable data protection laws, you may have the right to:\n• access your personal data\n• correct inaccurate data\n• request deletion of your data\n• restrict processing\n• object to processing\n• request data portability\n• withdraw consent\n• lodge a complaint with a data protection authority\n\nTo exercise your rights, contact us at:\n\n[Privacy email]\n\n14. Security\n\nTruffly uses technical and organizational measures designed to protect personal data, including access controls, authentication systems, protected storage, server-side business logic, and security logs.\n\nNo digital system can be guaranteed to be completely secure.\n\n15. Children\n\nTruffly is not intended for users under 18 years old.\n\nIf we become aware that a minor has created an account, we may delete the account and associated data.\n\n16. Changes to this Privacy Policy\n\nWe may update this Privacy Policy from time to time.\n\nWhen changes are significant, we may notify users through the app or other appropriate channels.\n\n17. Contact\n\nFor privacy-related requests:\n[Privacy email]\n\nFor general support:\ntruffly@gmail.com'**
  String get accountPrivacyPolicyContent;

  /// No description provided for @accountTermsContent.
  ///
  /// In en, this message translates to:
  /// **'Last updated: [Date]\n\nWelcome to Truffly.\n\nThese Terms & Conditions govern your access to and use of the Truffly mobile application and related services.\n\nBy creating an account or using Truffly, you agree to these Terms.\n\n1. Operator of the platform\n\nTruffly is operated by:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nSupport email: truffly@gmail.com\n\n2. What Truffly does\n\nTruffly is a digital marketplace that allows buyers to purchase fresh truffles from verified Italian sellers.\n\nTruffly provides:\n• the mobile platform\n• account registration\n• seller verification tools\n• product listing tools\n• order management\n• payment flow through Stripe\n• notifications\n• review tools\n• support tools\n\nUnless expressly stated otherwise, Truffly is not the direct seller of the products listed on the platform.\n\nThe sales contract for the product is concluded between the buyer and the seller.\n\n3. User eligibility\n\nTo use Truffly, you must:\n• be at least 18 years old\n• provide accurate information\n• keep your account credentials secure\n• use the platform lawfully\n• comply with these Terms\n\nTruffly may suspend or terminate accounts that violate these Terms or applicable law.\n\n4. Buyer accounts\n\nBuyers may:\n• browse truffles\n• view seller profiles\n• purchase available products\n• manage shipping addresses\n• track orders\n• confirm delivery\n• leave reviews\n• contact support\n\nBuyers must provide accurate shipping and contact information.\n\nTruffly is not responsible for failed deliveries caused by incorrect or incomplete information provided by the buyer.\n\n5. Seller accounts\n\nOnly approved sellers may publish truffles on Truffly.\n\nSellers must:\n• be based in Italy\n• provide accurate identity and eligibility information\n• hold any license, permit, authorization, or requirement applicable to truffle harvesting and sale\n• publish truthful product information\n• use real product images\n• ship products within the required timeframe\n• provide valid tracking information\n• comply with tax, food, consumer, and commercial laws applicable to their activity\n\nSellers are responsible for the products they publish and sell.\n\nTruffly may approve, reject, suspend, or remove seller access where necessary to protect users, comply with law, or preserve platform trust.\n\n6. Product listings\n\nEach product listing must contain accurate information, including where applicable:\n• truffle type\n• quality\n• weight\n• price\n• harvest date\n• region\n• shipping cost\n• images\n\nSellers must not publish misleading, false, illegal, unsafe, or unavailable products.\n\nTruffly may remove listings that violate these Terms or platform rules.\n\n7. Product freshness and availability\n\nTruffles are fresh and perishable products.\n\nAvailability may be limited and time-sensitive.\n\nA product may become unavailable if it is sold, expired, removed, or cancelled according to platform rules.\n\n8. Orders\n\nWhen a buyer completes payment, the order is created and the seller must ship the product according to the rules shown in the app.\n\nThe seller must insert tracking information within the required timeframe.\n\nOrder statuses may include:\n• paid\n• shipped\n• completed\n• cancelled\n\nTruffly may use automated systems to update order status according to platform rules.\n\n9. Payments\n\nPayments are processed through Stripe.\n\nWhen a buyer purchases a product, payment is collected securely and held according to the platform payment flow.\n\nSeller payouts are released according to the order completion rules.\n\nTruffly applies a fixed commission of [10%] on completed transactions, unless otherwise stated.\n\nThe commission is calculated by the platform.\n\n10. Shipping\n\nThe seller is responsible for preparing and shipping the product properly.\n\nSellers must use packaging suitable for fresh truffles and must comply with applicable shipping and food safety requirements.\n\nShipping times and costs may vary depending on destination and seller settings.\n\nTruffly is not responsible for delays caused by couriers, incorrect addresses, force majeure, or events outside Truffly’s reasonable control.\n\n11. Buyer confirmation and automatic completion\n\nAfter shipment, the buyer may confirm delivery in the app.\n\nIf the buyer does not confirm within the timeframe shown in the app, the order may be automatically completed after the applicable waiting period.\n\nWhen an order is completed, seller payout may be released according to the payment flow.\n\n12. Cancellations\n\nOrders may be cancelled in the cases described in the Refund & Cancellation Policy.\n\nIf the seller does not ship within the required timeframe, the order may be automatically cancelled and refunded.\n\nBuyers cannot freely cancel an order after payment unless allowed by law, platform policy, or support review.\n\n13. Right of withdrawal\n\nFresh truffles are perishable food products.\n\nFor this reason, the right of withdrawal may not apply to purchases of fresh truffles where the product is liable to deteriorate or expire rapidly.\n\nThis does not affect any mandatory consumer rights that cannot be excluded by law.\n\n14. Reviews\n\nBuyers may leave one review for each completed order.\n\nReviews must be honest, relevant, and based on a real purchase.\n\nUsers may not post:\n• false reviews\n• offensive content\n• discriminatory content\n• spam\n• private personal data\n• threats\n• illegal content\n\nTruffly may remove reviews that violate these Terms or applicable law.\n\nIf the app provides automatic reviews after a certain period, this will be disclosed in the app.\n\n15. User content\n\nUsers may upload or publish content such as profile information, product images, descriptions, and reviews.\n\nBy uploading content, you confirm that:\n• you have the right to use it\n• it is accurate and lawful\n• it does not infringe third-party rights\n• it does not contain illegal, harmful, or misleading material\n\nTruffly may remove content that violates these Terms.\n\n16. Prohibited use\n\nYou must not:\n• create fake accounts\n• impersonate another person\n• publish false product information\n• manipulate reviews\n• attempt to bypass payment systems\n• harass other users\n• upload illegal or harmful content\n• interfere with platform security\n• use Truffly for fraud or unlawful activity\n\n17. Platform role and limitation of responsibility\n\nTruffly acts as a marketplace platform and technology intermediary.\n\nSellers are responsible for the products they publish and sell.\n\nBuyers and sellers are responsible for complying with laws applicable to their own conduct.\n\nTo the maximum extent permitted by law, Truffly is not responsible for:\n• false information provided by users\n• product quality issues caused by sellers\n• misuse of products\n• courier delays\n• incorrect shipping information\n• tax obligations of sellers\n• disputes not caused by Truffly’s own breach\n\nNothing in these Terms limits rights that cannot be excluded under applicable consumer law.\n\n18. Taxes\n\nSellers are responsible for determining and fulfilling their own tax, invoicing, accounting, and reporting obligations.\n\nTruffly does not provide tax advice.\n\nBuyers and sellers should consult a qualified professional where needed.\n\n19. Account suspension or termination\n\nTruffly may suspend or terminate an account if:\n• the user violates these Terms\n• the user provides false information\n• fraud or abuse is suspected\n• required by law\n• necessary to protect users or the platform\n\nUsers may delete their account from within the app, subject to legal retention obligations.\n\n20. Changes to the service\n\nTruffly may update, modify, suspend, or discontinue parts of the platform.\n\nWhere changes materially affect users, Truffly may provide notice through the app or other appropriate channels.\n\n21. Governing law\n\nThese Terms are governed by the laws of Italy, without prejudice to mandatory consumer protection rights that may apply in the buyer’s country of residence.\n\n22. Contact\n\nFor support:\ntruffly@gmail.com\n\nFor legal inquiries:\n[Legal email]'**
  String get accountTermsContent;

  /// No description provided for @accountRefundAndCancellationContent.
  ///
  /// In en, this message translates to:
  /// **'Last updated: [Date]\n\nThis Refund & Cancellation Policy explains how cancellations, refunds, shipment deadlines, and payment releases work on Truffly.\n\n1. General principle\n\nTruffly is a marketplace for fresh truffles sold by verified Italian sellers.\n\nFresh truffles are perishable products. For this reason, refunds and cancellations are managed according to product freshness, shipment status, seller obligations, and applicable consumer protection laws.\n\n2. Payment protection\n\nWhen a buyer pays for an order, the payment is processed securely through Stripe.\n\nThe payment may be held according to the Truffly payment flow until the order is shipped, confirmed, completed, cancelled, or refunded.\n\n3. Seller shipping deadline\n\nSellers must ship the product and provide tracking information within the timeframe shown in the app.\n\nFor Truffly’s standard flow, sellers are expected to ship within 48 hours from order confirmation, unless otherwise stated.\n\n4. Automatic cancellation if the seller does not ship\n\nIf the seller does not provide tracking information within the required timeframe, Truffly may automatically cancel the order.\n\nIn this case:\n• the buyer receives a refund\n• the seller does not receive the payout\n• the product may become available again where applicable\n\n5. Buyer cancellation\n\nBecause fresh truffles are perishable and time-sensitive products, buyers generally cannot cancel an order after payment once the seller has started preparing or shipping the product.\n\nA buyer may contact support if:\n• the order was placed by mistake\n• the shipping address is incorrect\n• the seller has not shipped yet\n• there is another serious issue\n\nTruffly will evaluate the request but cannot guarantee cancellation in every case.\n\n6. Seller cancellation\n\nA seller may cancel an order before shipment only where allowed by the app flow or by Truffly support.\n\nReasons may include:\n• product no longer suitable for sale\n• product quality issue\n• inability to ship\n• incorrect listing information\n\nIf the seller cancels before shipment, the buyer will receive a refund.\n\nRepeated seller cancellations may lead to account review or suspension.\n\n7. Refund after shipment\n\nAfter an order has been shipped, refunds are not automatic.\n\nA buyer may contact support if:\n• the product was not delivered\n• the product arrived damaged\n• the product is materially different from the listing\n• there is a serious issue with freshness or quality\n• tracking information shows a delivery problem\n\nTruffly may ask the buyer to provide evidence, such as photos, tracking information, or order details.\n\n8. Delivery confirmation\n\nWhen the buyer receives the product, they may confirm delivery in the app.\n\nOnce delivery is confirmed, the order may be completed and the seller payout may be released.\n\n9. Automatic completion\n\nIf the buyer does not confirm delivery or report an issue within the timeframe shown in the app, the order may be automatically completed.\n\nAfter automatic completion, the seller payout may be released.\n\nThis does not remove mandatory legal rights that cannot be excluded.\n\n10. Right of withdrawal\n\nFresh truffles are perishable food products and may deteriorate or expire rapidly.\n\nFor this reason, the legal right of withdrawal may not apply to purchases of fresh truffles.\n\nThis does not affect any mandatory rights that consumers may have under applicable law, including rights related to defective, damaged, or non-conforming products.\n\n11. Refund method and timing\n\nRefunds are processed through the original payment method where possible.\n\nRefund timing may depend on:\n• Stripe processing times\n• the buyer’s bank or card issuer\n• payment method used\n• fraud or compliance checks\n\nTruffly cannot control delays caused by banks or payment providers.\n\n12. Shipping costs\n\nWhere an order is cancelled before shipment due to seller failure, shipping costs paid by the buyer may be refunded.\n\nWhere a refund is requested after shipment, shipping costs may be refunded or excluded depending on the reason for the refund, applicable law, and support review.\n\n13. Disputes\n\nIf there is a problem with an order, the buyer should contact support as soon as possible.\n\nSupport email:\ntruffly@gmail.com\n\nThe buyer should include:\n• order number\n• description of the issue\n• photos, if relevant\n• tracking details, if available\n\n14. Abuse\n\nTruffly may refuse refunds, suspend accounts, or restrict access where fraud, abuse, false claims, or repeated misuse of the refund process is suspected.\n\n15. Contact\n\nFor refund and cancellation requests:\ntruffly@gmail.com'**
  String get accountRefundAndCancellationContent;

  /// No description provided for @accountLegalInformationContent.
  ///
  /// In en, this message translates to:
  /// **'Last updated: [Date]\n\nThis page provides legal information about Truffly and the operator of the platform.\n\nPlatform operator\n\nTruffly is operated by:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nEmail: [Legal email]\nSupport email: truffly@gmail.com\n\nVAT / tax information:\n[VAT number / Tax code / Not applicable / To be added]\n\nNature of the service\n\nTruffly is a digital marketplace that connects buyers with verified Italian sellers of fresh truffles.\n\nUnless expressly stated otherwise, Truffly does not directly sell the products listed in the app.\n\nThe sales contract for each product is concluded between the buyer and the seller.\n\nSeller responsibility\n\nSellers are responsible for:\n• the accuracy of their listings\n• the quality and condition of the products they sell\n• compliance with applicable harvesting, food, tax, commercial, and consumer laws\n• packaging and shipping the product correctly\n• providing valid tracking information\n\nBuyer responsibility\n\nBuyers are responsible for:\n• providing accurate account information\n• providing a correct shipping address\n• checking order details before payment\n• reporting delivery or product issues promptly\n• using the platform lawfully\n\nPayments\n\nPayments are processed securely through Stripe.\n\nTruffly may apply a platform commission to completed transactions.\n\nSeller payouts, refunds, and payment releases are managed according to the applicable payment flow and platform policies.\n\nConsumer information\n\nBefore completing a purchase, buyers are shown key order information, including product details, price, shipping cost, seller information where available, and total amount.\n\nFresh truffles are perishable food products. The right of withdrawal may not apply where products are liable to deteriorate or expire rapidly.\n\nAccount deletion and data requests\n\nUsers can request account deletion from within the app.\n\nSome data may be retained where required by law or necessary for security, accounting, fraud prevention, disputes, or legal claims.\n\nPrivacy-related requests can be sent to:\n[Privacy email]\n\nSupport\n\nFor general support:\ntruffly@gmail.com\n\nLegal notices\n\nAll trademarks, logos, app designs, text, images, and platform materials are owned by Truffly or used with permission, unless otherwise stated.\n\nUsers may not copy, reproduce, distribute, or misuse Truffly content without authorization.\n\nGoverning law\n\nThe platform is operated from Italy.\n\nThese legal notices are governed by Italian law, without prejudice to mandatory consumer protection rights that may apply in the user’s country of residence.'**
  String get accountLegalInformationContent;
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
