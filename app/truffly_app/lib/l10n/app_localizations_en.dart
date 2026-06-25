// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordLettersNumbers =>
      'Password must contain letters and numbers';

  @override
  String get confirmPasswordRequired => 'Confirm password is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get authLoginTitle => 'Welcome back';

  @override
  String get authLoginSubtitle =>
      'Log in to continue buying and selling premium truffles.';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'name@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authLoginButton => 'Log in';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get authNoAccountText => 'Don\'t have an account?';

  @override
  String get authSignupLink => 'Sign up';

  @override
  String get authSignupTitle => 'Create account';

  @override
  String get authSignupSubtitle =>
      'Join the trusted marketplace for buying and selling premium truffles.';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authSignupButton => 'Sign up';

  @override
  String get authAlreadyHaveAccountText => 'Already have an account?';

  @override
  String get authLoginLink => 'Log in';

  @override
  String get authErrorInvalidCredentials => 'Invalid email or password.';

  @override
  String get authErrorEmailNotVerified =>
      'Please verify your email before signing in.';

  @override
  String get authErrorNetwork =>
      'Network error. Check your connection and retry.';

  @override
  String get authErrorTimeout => 'Request timeout. Please try again.';

  @override
  String get authErrorUnknown => 'Something went wrong. Please try again.';

  @override
  String get authErrorEmailAlreadyUsed => 'This email is already in use.';

  @override
  String get authErrorEmailResendRateLimited =>
      'You requested too many verification emails. Wait a few minutes and try again.';

  @override
  String get authErrorEmailDeliveryRestricted =>
      'We cannot send the verification email to this address. Check the email you entered or configure custom SMTP.';

  @override
  String get authPasswordResetRateLimitedError =>
      'You requested too many reset links. Wait a few minutes and try again.';

  @override
  String get authPasswordResetDeliveryRestrictedError =>
      'We cannot send the reset email to this address. Check the email you entered or configure custom SMTP.';

  @override
  String get authErrorLoginFallback => 'Unable to sign in. Please try again.';

  @override
  String get authErrorSignupFallback =>
      'Unable to create your account. Please try again.';

  @override
  String get authVerifyEmailTitle => 'Verify your email';

  @override
  String get authVerifyEmailSubtitle =>
      'We’ve sent a verification link to your email address. Please confirm it to continue.';

  @override
  String get authVerifyEmailCurrentEmail => 'Email';

  @override
  String get authVerifyEmailRecheckButton => 'I verified my email';

  @override
  String get authVerifyEmailWrongEmailCta => 'I entered the wrong email';

  @override
  String get authVerifyEmailNotYetVerified => 'Your email is not verified yet.';

  @override
  String get authVerifyEmailSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get authVerifyEmailResendButton => 'Resend email';

  @override
  String get authVerifyEmailResendSuccess =>
      'We sent you a new verification email. Check your inbox.';

  @override
  String get authVerifyEmailMissingEmail =>
      'Unable to find your email for resend.';

  @override
  String get authVerifyEmailAutoContinueHint =>
      'After clicking the link in your email, the app will continue automatically.';

  @override
  String get authVerifyEmailSignOutButton => 'Sign out';

  @override
  String get authVerifyEmailSpamHint =>
      'If you don’t see the email, check your spam folder.';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we’ll send you a link to reset your password.';

  @override
  String get authForgotPasswordButton => 'Send reset link';

  @override
  String get authForgotPasswordSuccess =>
      'Check your email: we sent you a link to reset your password.';

  @override
  String get authForgotPasswordErrorFallback =>
      'Unable to send reset email. Please try again.';

  @override
  String get authForgotPasswordBackToLogin => 'Back to login';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordSubtitle =>
      'Choose a new secure password for your account.';

  @override
  String get authResetPasswordNewPasswordLabel => 'Password';

  @override
  String get authResetPasswordButton => 'Update password';

  @override
  String get authResetPasswordSuccess => 'Password updated successfully.';

  @override
  String get authResetPasswordInvalidLink =>
      'This reset link is invalid or expired.';

  @override
  String get authResetPasswordInvalidRecoverySession =>
      'Recovery session is invalid. Open the reset link again.';

  @override
  String get authResetPasswordErrorFallback =>
      'Unable to reset password. Please try again.';

  @override
  String get authResetPasswordSuccessTitle => 'Password updated';

  @override
  String get authResetPasswordSuccessMessage =>
      'Your password has been successfully updated.';

  @override
  String get authResetPasswordSuccessButton => 'Back to login';

  @override
  String get authWelcomeTitle => 'Bring the authentic taste of truffles home';

  @override
  String get authWelcomeSubtitle =>
      'The first marketplace dedicated to fresh truffles';

  @override
  String get authWelcomeCreateAccountButton => 'Sign up to Truffly';

  @override
  String get authWelcomeLoginButton => 'I already have an account';

  @override
  String get authWelcomeFooterInfo => 'About Truffly: Our platform';

  @override
  String get welcomeFreshTrufflesHome => 'Fresh truffles at your door';

  @override
  String get welcomeRealFreshTruffle => 'Real fresh truffle';

  @override
  String get welcomeDiscoverNewFlavors => 'Discover new flavors';

  @override
  String get welcomeVerifiedHunters => 'Verified truffle hunters';

  @override
  String get welcomeSelectedQuality => 'Selected quality';

  @override
  String get welcomeProtectedPurchases => 'Protected purchases';

  @override
  String get onboardingNameTitle => 'Tell us your name';

  @override
  String get onboardingNameSubtitle =>
      'This will be used to complete your onboarding profile details.';

  @override
  String get onboardingFirstNameLabel => 'First name';

  @override
  String get onboardingLastNameLabel => 'Last name';

  @override
  String get onboardingFirstNameRequiredError => 'First name is required.';

  @override
  String get onboardingFirstNameTooShortError =>
      'First name must be at least 2 characters.';

  @override
  String get onboardingLastNameRequiredError => 'Last name is required.';

  @override
  String get onboardingLastNameTooShortError =>
      'Last name must be at least 2 characters.';

  @override
  String get onboardingBuyerLocationTitle => 'Where are you buying from?';

  @override
  String get onboardingBuyerLocationSubtitle =>
      'Select your country. If you choose Italy, region becomes required.';

  @override
  String get onboardingCountryLabel => 'Country';

  @override
  String get onboardingCountryPlaceholder => 'Select a country';

  @override
  String get onboardingCountryRequiredError => 'Country is required.';

  @override
  String get onboardingCountryInvalidError => 'Select a valid country.';

  @override
  String get onboardingRegionLabel => 'Region';

  @override
  String get onboardingRegionPlaceholder => 'Select a region';

  @override
  String get onboardingRegionHint => 'TOSCANA';

  @override
  String get onboardingRegionNotRequiredHint => 'Not required';

  @override
  String get onboardingRegionRequiredError => 'Region is required.';

  @override
  String get onboardingRegionAbruzzo => 'Abruzzo';

  @override
  String get onboardingRegionBasilicata => 'Basilicata';

  @override
  String get onboardingRegionCalabria => 'Calabria';

  @override
  String get onboardingRegionCampania => 'Campania';

  @override
  String get onboardingRegionEmiliaRomagna => 'Emilia-Romagna';

  @override
  String get onboardingRegionFriuliVeneziaGiulia => 'Friuli Venezia Giulia';

  @override
  String get onboardingRegionLazio => 'Lazio';

  @override
  String get onboardingRegionLiguria => 'Liguria';

  @override
  String get onboardingRegionLombardia => 'Lombardia';

  @override
  String get onboardingRegionMarche => 'Marche';

  @override
  String get onboardingRegionMolise => 'Molise';

  @override
  String get onboardingRegionPiemonte => 'Piemonte';

  @override
  String get onboardingRegionPuglia => 'Puglia';

  @override
  String get onboardingRegionSardegna => 'Sardegna';

  @override
  String get onboardingRegionSicilia => 'Sicilia';

  @override
  String get onboardingRegionToscana => 'Toscana';

  @override
  String get onboardingRegionTrentinoAltoAdige => 'Trentino-Alto Adige';

  @override
  String get onboardingRegionUmbria => 'Umbria';

  @override
  String get onboardingRegionValleDaosta => 'Valle d\'Aosta';

  @override
  String get onboardingRegionVeneto => 'Veneto';

  @override
  String get onboardingBuyerLocationRegionHelper =>
      'Region is only required for buyers in Italy.';

  @override
  String get onboardingSellerRegionTitle => 'Select your region';

  @override
  String get onboardingSellerRegionSubtitle =>
      'At the moment, only truffle hunters residing in Italy can sell on Truffly. By continuing, you confirm that you reside in Italy.';

  @override
  String get onboardingSellerDocumentsTitle => 'Upload your seller documents';

  @override
  String get onboardingSellerDocumentsSubtitle =>
      'Select the required documents locally. Nothing is uploaded during onboarding until the final submit step.';

  @override
  String get onboardingTesserinoNumberLabel => 'Tesserino number';

  @override
  String get onboardingTesserinoNumberHint => 'Enter your tesserino number';

  @override
  String get onboardingTesserinoNumberRequiredError =>
      'Tesserino number is required.';

  @override
  String get onboardingIdentityDocumentTitle => 'Identity document';

  @override
  String get onboardingIdentityDocumentDescription =>
      'Choose a valid identity document for verification.';

  @override
  String get onboardingIdentityDocumentRequiredError =>
      'Identity document is required.';

  @override
  String get onboardingTesserinoDocumentTitle => 'Tesserino document';

  @override
  String get onboardingTesserinoDocumentDescription =>
      'Choose your truffle license or permit document.';

  @override
  String get onboardingTesserinoDocumentRequiredError =>
      'Tesserino document is required.';

  @override
  String get onboardingDocumentPickButton => 'Pick file';

  @override
  String get onboardingDocumentReplaceButton => 'Replace file';

  @override
  String get onboardingDocumentRemoveButton => 'Remove';

  @override
  String get onboardingDocumentTakePhotoOption => 'Take photo';

  @override
  String get onboardingDocumentChooseFromGalleryOption => 'Choose from gallery';

  @override
  String get onboardingDocumentSourceCancelOption => 'Cancel';

  @override
  String get onboardingDocumentNotSelected => 'No file selected';

  @override
  String get onboardingDocumentPermissionDeniedError => 'Permission denied.';

  @override
  String get onboardingDocumentCameraUnavailableError => 'Camera unavailable.';

  @override
  String get onboardingDocumentGalleryUnavailableError =>
      'Gallery unavailable.';

  @override
  String get onboardingDocumentPickerUnavailableError =>
      'Unable to select an image right now.';

  @override
  String get onboardingSellerDocumentsLocalOnlyHelper =>
      'Files stay local on this device for now. Upload happens only at final submit.';

  @override
  String get onboardingNotificationsBuyerTitle => 'Enable notifications';

  @override
  String get onboardingNotificationsBuyerSubtitle =>
      'Receive updates about your orders, shipments, and favorite truffles.';

  @override
  String get onboardingNotificationsBuyerBenefit1 =>
      'Order confirmations and shipping updates.';

  @override
  String get onboardingNotificationsBuyerBenefit2 =>
      'Delivery and tracking notifications.';

  @override
  String get onboardingNotificationsBuyerBenefit3 =>
      'New truffles matching your interests.';

  @override
  String get onboardingNotificationsSellerTitle => 'Never miss a sale';

  @override
  String get onboardingNotificationsSellerSubtitle =>
      'Enable notifications to stay updated on orders, shipments, payments, and seller activity.';

  @override
  String get onboardingNotificationsSellerBenefit1 =>
      'Instant notifications for new orders.';

  @override
  String get onboardingNotificationsSellerBenefit2 =>
      'Shipping reminders for active orders.';

  @override
  String get onboardingNotificationsSellerBenefit3 =>
      'Payment and payout updates.';

  @override
  String get onboardingNotificationsEnableButton => 'Enable notifications';

  @override
  String get onboardingNotificationsContinueWithoutButton => 'Not now';

  @override
  String get onboardingNotificationsFooter =>
      'You can always manage notifications later in settings.';

  @override
  String get onboardingNotificationsStatusIdle =>
      'Notifications are not enabled yet.';

  @override
  String get onboardingNotificationsStatusPending =>
      'Permission request in progress.';

  @override
  String get onboardingNotificationsStatusGranted =>
      'Notifications enabled successfully.';

  @override
  String get onboardingNotificationsStatusProvisional =>
      'Notifications are provisionally enabled on iOS.';

  @override
  String get onboardingNotificationsStatusNotDetermined =>
      'Notification permission has not been decided yet.';

  @override
  String get onboardingNotificationsStatusDenied =>
      'Permission denied. You can continue and enable notifications later in settings.';

  @override
  String get onboardingNotificationsStatusSkipped =>
      'You chose to continue without notifications for now.';

  @override
  String get onboardingNotificationsPermissionError =>
      'Unable to request notification permission right now. You can continue and try again later.';

  @override
  String get onboardingWelcomeBuyerTitle => 'Your truffle journey starts here';

  @override
  String get onboardingWelcomeBuyerSubtitle =>
      'Your buyer onboarding is complete.';

  @override
  String get onboardingWelcomeBuyerMessage =>
      'Discover freshly harvested truffles, meet passionate hunters, and experience the authentic world of truffles.';

  @override
  String get onboardingWelcomeBuyerReadyLabel => 'You\'re ready';

  @override
  String get onboardingWelcomeSellerTitle => 'Application submitted';

  @override
  String get onboardingWelcomeSellerSubtitle =>
      'Your seller request is under review.';

  @override
  String get onboardingWelcomeSellerMessage =>
      'Your seller request has been successfully submitted and is now under review.\nYou’ll receive a notification as your application status progresses.';

  @override
  String get onboardingWelcomeDefaultTitle => 'Welcome to Truffly';

  @override
  String get onboardingWelcomeDefaultSubtitle =>
      'You are almost ready to enter the app.';

  @override
  String get onboardingWelcomeDefaultMessage =>
      'Review your onboarding details and continue when you are ready.';

  @override
  String get onboardingBuyerInfo1Title => 'The true taste of fresh truffles';

  @override
  String get onboardingBuyerInfo1Description =>
      'Discover the taste and aroma of freshly harvested truffles, shipped directly from truffle hunters.';

  @override
  String get onboardingBuyerInfo2Title => 'Verified hunters, real reviews';

  @override
  String get onboardingBuyerInfo2Description =>
      'Buy with confidence from verified truffle hunters and discover authentic reviews shared by other buyers.';

  @override
  String get onboardingBuyerInfo3Title => 'We\'ve got the security covered';

  @override
  String get onboardingBuyerInfo3Description =>
      'With Truffly, your payment remains protected until your order reaches its destination.';

  @override
  String get onboardingSellerInfo1Title =>
      'Give your truffles the value they deserve';

  @override
  String get onboardingSellerInfo1Description =>
      'Sell directly to a community of truffle enthusiasts, without intermediaries. Set your own price and reach buyers ready to purchase.';

  @override
  String get onboardingSellerInfo2Title => 'No upfront costs';

  @override
  String get onboardingSellerInfo2Description =>
      'No registration fees and no upfront costs. We retain a 10% commission only on completed sales.';

  @override
  String get onboardingSellerInfo3Title =>
      'A marketplace built around freshness';

  @override
  String get onboardingSellerInfo3Description =>
      'To preserve quality and freshness, listings remain active for 5 days and orders must be shipped within 2 business days of the sale.';

  @override
  String get onboardingSellerInfo4Title => 'A verified community';

  @override
  String get onboardingSellerInfo4Description =>
      'To sell on Truffly, you\'ll need to verify your identity and truffle license. Payments are transferred through Stripe after the buyer confirms delivery.';

  @override
  String get onboardingFlowTitleBuyer => 'Buyer onboarding';

  @override
  String get onboardingFlowTitleSeller => 'Seller onboarding';

  @override
  String get onboardingFlowTitleDefault => 'Onboarding';

  @override
  String onboardingFlowStepCounter(Object current, Object total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingFlowSubmissionError =>
      'Something went wrong. Please try again.';

  @override
  String get onboardingSubmitNetworkError =>
      'Network connection lost. Please try again.';

  @override
  String get onboardingSubmitValidationError =>
      'Some onboarding data is invalid. Please review your details and try again.';

  @override
  String get onboardingSubmitDocumentError =>
      'A selected document could not be processed. Please review your files and try again.';

  @override
  String get onboardingSubmitServerError =>
      'Server unavailable right now. Please try again.';

  @override
  String get onboardingSubmitUnavailableError =>
      'This action is not available right now.';

  @override
  String get onboardingFlowBackButton => 'Back';

  @override
  String get onboardingFlowNextButton => 'Next';

  @override
  String get onboardingFlowEnterAppButton => 'Enter App';

  @override
  String get onboardingFlowSubmitButton => 'Submit';

  @override
  String onboardingProgressLabel(Object section) {
    return 'Section progress: $section';
  }

  @override
  String get onboardingPlaceholderTitle => 'Placeholder Step';

  @override
  String onboardingPlaceholderStepId(Object stepId) {
    return 'Step ID: $stepId';
  }

  @override
  String onboardingPlaceholderSection(Object section) {
    return 'Section: $section';
  }

  @override
  String get onboardingSectionAboutTruffly => 'About Truffly';

  @override
  String get onboardingSectionYourDetails => 'Your Details';

  @override
  String get onboardingSectionDocuments => 'Documents';

  @override
  String get onboardingSectionNotifications => 'Notifications';

  @override
  String get onboardingSectionWelcome => 'Welcome';

  @override
  String get onboardingCountryItaly => 'Italy';

  @override
  String get onboardingCountryFrance => 'France';

  @override
  String get onboardingCountryGermany => 'Germany';

  @override
  String get onboardingCountrySpain => 'Spain';

  @override
  String get onboardingCountryUnitedKingdom => 'United Kingdom';

  @override
  String get onboardingCountryUnitedStates => 'United States';

  @override
  String get onboardingRoleSelectionTitle =>
      'How would you like to use Truffly?';

  @override
  String get onboardingRoleSelectionSubtitle =>
      'Buy fresh truffles from the best truffle hunters or start selling yours directly to the community.';

  @override
  String get onboardingRoleSelectionBuyerTitle => 'Buy truffles';

  @override
  String get onboardingRoleSelectionBuyerDescription =>
      'See the 7-step buyer onboarding flow.';

  @override
  String get onboardingRoleSelectionSellerTitle => 'Sell truffles';

  @override
  String get onboardingRoleSelectionSellerDescription =>
      'See the 9-step seller onboarding flow.';

  @override
  String get onboardingExitTitle => 'Leave onboarding?';

  @override
  String get onboardingExitMessage =>
      'Your onboarding progress will stay saved locally for this session, but you will leave the onboarding flow.';

  @override
  String get onboardingExitStayButton => 'Stay';

  @override
  String get onboardingExitLeaveButton => 'Leave';

  @override
  String get onboardingDocumentUnsupportedFormatError =>
      'Unsupported file format. Use PNG, JPG, or JPEG.';

  @override
  String get onboardingDocumentFileNotFoundError =>
      'The selected file could not be found.';

  @override
  String get onboardingDocumentEmptyFileError => 'The selected file is empty.';

  @override
  String get trufflePageTitle => 'Truffles';

  @override
  String get truffleDetailTitle => 'Truffle detail';

  @override
  String get truffleDetailError => 'Unable to load this truffle right now.';

  @override
  String get truffleDetailPricePerKg => 'Price per kg';

  @override
  String get truffleSearchHint => 'What are you looking for?';

  @override
  String get truffleSearchApply => 'Search';

  @override
  String get truffleLoadError =>
      'Unable to load truffles right now. Please try again.';

  @override
  String get truffleRetry => 'Retry';

  @override
  String get truffleEmptyTitle => 'No matching products';

  @override
  String get truffleEmptySubtitle =>
      'Try changing filters\nor check again later.';

  @override
  String get truffleFiltersTitle => 'Filters';

  @override
  String get truffleFiltersReset => 'Reset';

  @override
  String get truffleFiltersApply => 'Apply filters';

  @override
  String get truffleFilterAll => 'All';

  @override
  String get truffleFilterQuality => 'Quality';

  @override
  String get truffleFilterPriceRange => 'Price range';

  @override
  String get truffleFilterWeight => 'Weight';

  @override
  String get truffleFilterHarvestDate => 'Harvest date';

  @override
  String get truffleFilterRegion => 'Harvest region';

  @override
  String get truffleHarvestToday => 'Today';

  @override
  String get truffleHarvestLast2Days => 'Last 2 days';

  @override
  String get truffleHarvestLast3Days => 'Last 3 days';

  @override
  String get truffleHarvestLast5Days => 'Last 5 days';

  @override
  String get truffleQualityFirst => 'First choice';

  @override
  String get truffleQualitySecond => 'Second choice';

  @override
  String get truffleQualityThird => 'Third choice';

  @override
  String get truffleTypeMagnatum => 'White truffle';

  @override
  String get truffleTypeMelanosporum => 'Black winter truffle';

  @override
  String get truffleTypeAestivum => 'Scorzone';

  @override
  String get truffleTypeUncinatum => 'Uncinato';

  @override
  String get truffleTypeBorchii => 'Bianchetto';

  @override
  String get truffleTypeBrumale => 'Brumale';

  @override
  String get truffleTypeMacrosporum => 'Smooth Black';

  @override
  String get truffleTypeBrumaleMoschatum => 'Musky Brumal';

  @override
  String get truffleTypeMesentericum => 'Mesenteric';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeGreetingPrefix => 'Hello';

  @override
  String get homeLoadError => 'Unable to load the home screen right now.';

  @override
  String get homeSeasonalSectionTitle => 'Seasonal Highlight';

  @override
  String get homeSeasonalInSeasonLabel => 'In season';

  @override
  String get homeSeasonalComingSoonLabel => 'Coming soon';

  @override
  String get homeSeasonalLoadingLabel => 'Loading seasonal highlights...';

  @override
  String homeSeasonalCountdownLine(int days, Object truffleName) {
    return '$days days left until $truffleName season begins';
  }

  @override
  String get homeSeasonalEmptyText =>
      'No seasonal highlight is available right now.';

  @override
  String get homeSeasonalErrorText => 'Unable to load seasonal information.';

  @override
  String get homeSeasonalRetryLabel => 'Retry';

  @override
  String get homeLatestNewsTitle => 'Latest News';

  @override
  String get homeTopSellersTitle => 'Top Truffle Hunters';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeLatestNewsEmpty => 'No truffles are available right now.';

  @override
  String get homeTopSellersEmpty =>
      'No truffle hunters are available right now.';

  @override
  String get homeSectionErrorText => 'Unable to load this section right now.';

  @override
  String get homeSellerOrdersInProgress => 'Orders in progress';

  @override
  String get homeSellerActiveTruffles => 'Active truffles';

  @override
  String get seasonalTruffleNameMagnatum => 'White Truffle';

  @override
  String get seasonalTruffleNameMelanosporum => 'Black Winter Truffle';

  @override
  String get seasonalTruffleNameAestivum => 'Summer Truffle';

  @override
  String get seasonalTruffleNameUncinatum => 'Uncinatum Truffle';

  @override
  String get seasonalTruffleNameBorchii => 'Bianchetto';

  @override
  String get seasonalTruffleNameBrumale => 'Brumale';

  @override
  String get seasonalTruffleNameMacrosporum => 'Smooth Black Truffle';

  @override
  String get seasonalTruffleNameBrumaleMoschatum => 'Musky Brumal Truffle';

  @override
  String get seasonalTruffleNameMesentericum => 'Mesenteric Truffle';

  @override
  String get guidesPageTitle => 'Truffle Guides';

  @override
  String get guidesLoadError => 'Unable to load guides right now.';

  @override
  String get guidesRetry => 'Retry';

  @override
  String get guidesEmpty => 'No guides are available right now.';

  @override
  String get guidesDescription => 'Description';

  @override
  String get guidesAroma => 'Aroma';

  @override
  String get guidesPriceRange => 'Price range';

  @override
  String get guidesRarity => 'Rarity';

  @override
  String get guidesSymbioticPlants => 'Symbiotic plants';

  @override
  String get guidesSoil => 'Soil';

  @override
  String get guidesSoilComposition => 'Composition';

  @override
  String get guidesSoilStructure => 'Structure';

  @override
  String get guidesSoilPh => 'pH';

  @override
  String get guidesSoilAltitude => 'Altitude';

  @override
  String get guidesSoilHumidity => 'Humidity';

  @override
  String get guidesSoilHelper =>
      'Discover the characteristics of the environment where this truffle grows: humidity, altitude, and soil type.';

  @override
  String get guidesHarvestPeriod => 'Harvest period';

  @override
  String get guidesTruffleQualityMetric => 'Truffle quality';

  @override
  String get guidesPriceRangeMetric => 'Price range';

  @override
  String get truffleShippingPlus => '+ shipping';

  @override
  String get truffleShippingItaly => 'Italy';

  @override
  String get sellerPageTitle => 'Sellers';

  @override
  String get sellerSearchHint => 'Search by first or last name';

  @override
  String get sellerLoadError =>
      'Unable to load sellers right now. Please try again.';

  @override
  String get sellerEmptyTitle => 'No sellers are available right now';

  @override
  String get sellerEmptySubtitle =>
      'Check back later to discover more verified profiles.';

  @override
  String get sellerEmptyFilteredTitle =>
      'No sellers match your current filters';

  @override
  String get sellerEmptyFilteredSubtitle =>
      'Try removing a filter or changing your search.';

  @override
  String get sellerResetFilters => 'Reset filters';

  @override
  String get sellerFilterRatingTitle => 'Rating';

  @override
  String get sellerFilterCompletedOrdersTitle => 'Completed orders';

  @override
  String get sellerFilterRatingThreePlus => '3+ stars';

  @override
  String get sellerFilterRatingFourPlus => '4+ stars';

  @override
  String get sellerFilterRatingFive => '5 stars';

  @override
  String get sellerFilterCompletedOrdersFivePlus => '5+ orders';

  @override
  String get sellerFilterCompletedOrdersTwentyPlus => '20+ orders';

  @override
  String get sellerFilterCompletedOrdersFiftyPlus => '50+ orders';

  @override
  String get sellerRatingNew => 'New';

  @override
  String get sellerRegionUnavailable => 'Region unavailable';

  @override
  String sellerActiveSearchFilter(Object query) {
    return 'Search: $query';
  }

  @override
  String sellerReviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String sellerCompletedOrdersShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: '0 orders',
    );
    return '$_temp0';
  }

  @override
  String get sellerProfileInfoTab => 'Info';

  @override
  String get sellerProfileReviewsTab => 'Reviews';

  @override
  String get sellerProfileTrufflesTab => 'Truffles';

  @override
  String get sellerProfileRatingStarsLabel => 'Rating';

  @override
  String get sellerProfileOrdersLabel => 'Orders';

  @override
  String get sellerProfileActiveTrufflesLabel => 'Active truffles';

  @override
  String get sellerProfileBioFallback =>
      'This seller has not added a description yet.';

  @override
  String get sellerProfileJoinedPlatformLabel => 'Joined the platform';

  @override
  String get sellerProfileSummaryTitle => 'Seller summary';

  @override
  String get sellerProfileJoinedLabel => 'Joined';

  @override
  String get sellerProfileRegionLabel => 'Region';

  @override
  String get sellerProfileUnavailable => 'Unavailable';

  @override
  String get sellerProfileRecentReviewsTitle => 'Recent reviews';

  @override
  String get sellerProfileReadAll => 'Read all';

  @override
  String get sellerProfileNoReviews => 'No reviews for this seller yet.';

  @override
  String get sellerProfileActiveTrufflesTitle => 'Active truffles';

  @override
  String get sellerProfileNoActiveTruffles =>
      'This seller has no active truffles right now.';

  @override
  String get sellerProfileUnableToLoadReviews =>
      'Unable to load reviews right now.';

  @override
  String get sellerProfileLoadError =>
      'Unable to load this seller profile right now.';

  @override
  String get accountDetailsTitle => 'Account details';

  @override
  String get accountDetailsSubtitle =>
      'Keep your account information up to date. Email changes require a new verification step.';

  @override
  String get accountDetailsSaveCta => 'Save changes';

  @override
  String get accountDetailsPersonalSectionTitle => 'Personal details';

  @override
  String get accountDetailsEmailSectionTitle => 'Email';

  @override
  String get accountDetailsLocationSectionTitle => 'Location';

  @override
  String get accountDetailsPhotoSectionTitle => 'Profile image';

  @override
  String get accountDetailsBioSectionTitle => 'Bio';

  @override
  String get accountDetailsBioPlaceholder =>
      'Tell buyers a little more about you';

  @override
  String get accountDetailsEmailVerified => 'Email verified';

  @override
  String get accountDetailsEmailHelper =>
      'If you change your email, we will send a new verification link and the app will bring you back to the email verification screen.';

  @override
  String get accountDetailsChangeEmailCta => 'Change email';

  @override
  String get accountDetailsSaveNewEmailCta => 'Save new email';

  @override
  String get accountDetailsCancelEmailChangeCta => 'Cancel';

  @override
  String get accountDetailsPhotoHelper =>
      'You can update your profile photo from camera or gallery. The new image uploads right away after selection.';

  @override
  String get accountDetailsPhotoUploadPending => 'Uploading profile photo...';

  @override
  String get accountDetailsPhotoUploadSuccess =>
      'Profile photo updated successfully.';

  @override
  String get accountDetailsPhotoRemoveSuccess => 'Profile photo removed.';

  @override
  String get accountDetailsPhotoPickerUnavailable =>
      'Unable to pick an image right now.';

  @override
  String get accountDetailsPhotoPermissionDeniedError =>
      'Permission denied. Allow access to your photos and try again.';

  @override
  String get accountDetailsPhotoCameraUnavailableError =>
      'Camera unavailable right now.';

  @override
  String get accountDetailsPhotoGalleryUnavailableError =>
      'Gallery unavailable right now.';

  @override
  String get accountDetailsPhotoFileNotFoundError =>
      'The selected file could not be found.';

  @override
  String get accountDetailsPhotoTooLargeError =>
      'The selected image must be 5 MB or smaller.';

  @override
  String get accountDetailsPhotoUnsupportedFormatError =>
      'Use a JPG, PNG, or WebP image.';

  @override
  String get accountDetailsPhotoInvalidFileError =>
      'The selected image could not be read.';

  @override
  String get accountDetailsPhotoUploadFailedError =>
      'Unable to upload the profile photo right now. Please try again.';

  @override
  String get accountDetailsPhotoDeleteFailedError =>
      'Unable to remove the profile photo right now. Please try again.';

  @override
  String get accountDetailsChangePhotoCta => 'Change photo';

  @override
  String get accountDetailsRemovePhotoCta => 'Remove photo';

  @override
  String get accountDetailsTakePhotoOption => 'Take photo';

  @override
  String get accountDetailsChooseFromGalleryOption => 'Choose from gallery';

  @override
  String get accountDetailsPhotoSourceCancelOption => 'Cancel';

  @override
  String get accountDetailsSellerCountryLockedHelper =>
      'Seller accounts stay linked to Italy according to the current domain rules.';

  @override
  String get accountDetailsRegionHiddenHelper =>
      'Region is only required when the selected country is Italy. Saving with another country will clear the region.';

  @override
  String get accountDetailsRequiredFieldError => 'This field is required.';

  @override
  String get accountDetailsSellerCountryError =>
      'Seller accounts must keep Italy as country.';

  @override
  String get accountDetailsInvalidImageUrlError => 'Enter a valid image URL.';

  @override
  String get accountDetailsSessionExpired =>
      'Your session expired. Sign in again to continue.';

  @override
  String get accountDetailsLoadError =>
      'Unable to load your account details right now.';

  @override
  String get accountDetailsSaveError =>
      'Unable to save your account details right now. Please try again.';

  @override
  String get accountDetailsSaveSuccess =>
      'Account details updated successfully.';

  @override
  String get accountDetailsEmailVerificationSent =>
      'Check both your current and new email addresses and confirm both links to complete the change.';

  @override
  String get shippingAddressesTitle => 'Shipping';

  @override
  String get shippingAddressesSubtitle =>
      'Add and manage shipping addresses for your orders.';

  @override
  String get shippingAddressesSectionTitle => 'Saved addresses';

  @override
  String get shippingAddressesAddCta => 'Add address';

  @override
  String get shippingAddressesEmptyTitle => 'No saved addresses';

  @override
  String get shippingAddressesEmptySubtitle =>
      'Add your first shipping address so it is ready to use during checkout.';

  @override
  String get shippingAddressesDefaultBadge => 'Default';

  @override
  String get shippingAddressesLoadError =>
      'Unable to load your shipping addresses right now.';

  @override
  String get shippingAddressesNetworkError =>
      'Network error while loading shipping addresses. Please try again.';

  @override
  String get shippingAddressesUnauthorizedError =>
      'Your session expired. Sign in again to manage shipping addresses.';

  @override
  String get shippingAddressesNotFoundError =>
      'This shipping address could not be found anymore.';

  @override
  String get shippingAddressesValidationError =>
      'Some shipping address data is invalid. Please review the form and try again.';

  @override
  String get shippingAddressAddTitle => 'Add address';

  @override
  String get shippingAddressEditTitle => 'Edit address';

  @override
  String get shippingAddressFormSubtitle =>
      'Use a dedicated shipping address for deliveries. The default address will be highlighted and ready for future checkout flows.';

  @override
  String get shippingAddressSaveCta => 'Save address';

  @override
  String get shippingAddressDeleteCta => 'Delete address';

  @override
  String get shippingAddressDeleteDialogTitle => 'Delete this address?';

  @override
  String get shippingAddressDeleteDialogMessage =>
      'This shipping address will be removed from your saved list.';

  @override
  String get shippingAddressDeleteDialogCancel => 'Cancel';

  @override
  String get shippingAddressDeleteDialogConfirm => 'Delete';

  @override
  String get shippingAddressFullNameLabel => 'Full name';

  @override
  String get shippingAddressFullNamePlaceholder => 'Enter full name';

  @override
  String get shippingAddressStreetLabel => 'Street';

  @override
  String get shippingAddressStreetPlaceholder => 'Street and house number';

  @override
  String get shippingAddressCityLabel => 'City';

  @override
  String get shippingAddressCityPlaceholder => 'Enter city';

  @override
  String get shippingAddressPostalCodeLabel => 'Postal code';

  @override
  String get shippingAddressPostalCodePlaceholder => 'Enter postal code';

  @override
  String get shippingAddressCountryLabel => 'Country';

  @override
  String get shippingAddressCountryPlaceholder => 'Select a country';

  @override
  String get shippingAddressPhoneLabel => 'Phone';

  @override
  String get shippingAddressPhonePlaceholder => 'Enter phone number';

  @override
  String get shippingAddressDefaultToggleLabel => 'Set as default address';

  @override
  String get shippingAddressDefaultToggleHelper =>
      'Default addresses are highlighted in your list and ready for future checkout selection.';

  @override
  String get shippingAddressRequiredFieldError => 'This field is required.';

  @override
  String get shippingAddressFullNameRequiredError => 'Full name is required.';

  @override
  String get shippingAddressStreetRequiredError => 'Street is required.';

  @override
  String get shippingAddressCityRequiredError => 'City is required.';

  @override
  String get shippingAddressCityInvalidError => 'Enter a valid city name.';

  @override
  String get shippingAddressPostalCodeRequiredError =>
      'Postal code is required.';

  @override
  String get shippingAddressPostalCodeInvalidError =>
      'Enter a valid postal code.';

  @override
  String get shippingAddressCountryRequiredError => 'Country is required.';

  @override
  String get shippingAddressCountryInvalidError => 'Select a valid country.';

  @override
  String get shippingAddressPhoneRequiredError => 'Phone is required.';

  @override
  String get shippingAddressPhoneInvalidError =>
      'Enter a valid phone number with prefix.';

  @override
  String get shippingAddressValidationFallback =>
      'Review this field and try again.';

  @override
  String get shippingAddressSaveError =>
      'Unable to save this shipping address right now. Please try again.';

  @override
  String get shippingAddressSavedSuccess =>
      'Shipping address saved successfully.';

  @override
  String get shippingAddressDeletedSuccess =>
      'Shipping address deleted successfully.';

  @override
  String get publishTruffleTitle => 'Publish truffle';

  @override
  String get publishTrufflePhotosTitle => 'Product photos';

  @override
  String get publishTrufflePhotosSubtitle =>
      'Add between 1 and 3 photos. The first photo will be used as the cover image.';

  @override
  String get publishTruffleAddPhoto => 'Add photo';

  @override
  String get publishTruffleRemovePhoto => 'Remove photo';

  @override
  String get publishTruffleQualityLabel => 'Truffle quality';

  @override
  String get publishTruffleTypeLabel => 'Truffle type';

  @override
  String get publishTruffleTypePlaceholder => 'Select truffle type';

  @override
  String get publishTruffleLatinNameLabel => 'Latin name';

  @override
  String get publishTrufflePricingTitle => 'Weight and prices';

  @override
  String get publishTruffleWeightLabel => 'Weight in grams';

  @override
  String get publishTruffleTotalPriceLabel => 'Total price in EUR';

  @override
  String get publishTruffleShippingItalyLabel => 'Shipping price Italy';

  @override
  String get publishTruffleShippingAbroadLabel => 'Shipping price abroad';

  @override
  String get publishTrufflePricePerKgPreviewLabel => 'Price per kg preview';

  @override
  String get publishTrufflePricePerKgPreviewPlaceholder =>
      'Fill in weight and total price';

  @override
  String get publishTruffleRegionLabel => 'Harvest region';

  @override
  String get publishTruffleRegionPlaceholder => 'Select harvest region';

  @override
  String get publishTruffleHarvestDateLabel => 'Harvest date';

  @override
  String get publishTruffleCta => 'Publish truffle';

  @override
  String get publishTruffleConfirmTitle => 'Publish this truffle?';

  @override
  String get publishTruffleConfirmMessage =>
      'After publication, the truffle will be visible in the marketplace and cannot be edited.';

  @override
  String get publishTruffleCancelAction => 'Cancel';

  @override
  String get publishTruffleConfirmAction => 'Publish';

  @override
  String get publishTruffleTakePhoto => 'Take photo';

  @override
  String get publishTruffleChooseFromGallery => 'Choose from gallery';

  @override
  String get publishTruffleValidationImagesRequired =>
      'Add at least 1 product photo.';

  @override
  String get publishTruffleValidationImagesTooMany =>
      'You can upload up to 3 product photos.';

  @override
  String get publishTruffleValidationQualityRequired =>
      'Select the truffle quality.';

  @override
  String get publishTruffleValidationTypeRequired => 'Select the truffle type.';

  @override
  String get publishTruffleValidationWeightRequired => 'Weight is required.';

  @override
  String get publishTruffleValidationWeightInvalid =>
      'Enter a weight greater than 0.';

  @override
  String get publishTruffleValidationPriceRequired =>
      'Total price is required.';

  @override
  String get publishTruffleValidationPriceInvalid =>
      'Enter a total price greater than 0.';

  @override
  String get publishTruffleValidationShippingItalyRequired =>
      'Shipping price for Italy is required.';

  @override
  String get publishTruffleValidationShippingItalyInvalid =>
      'Enter a shipping price for Italy equal to or greater than 0.';

  @override
  String get publishTruffleValidationShippingAbroadRequired =>
      'Shipping price for abroad is required.';

  @override
  String get publishTruffleValidationShippingAbroadInvalid =>
      'Enter a shipping price for abroad equal to or greater than 0.';

  @override
  String get publishTruffleValidationRegionRequired =>
      'Select the harvest region.';

  @override
  String get publishTruffleValidationHarvestDateRequired =>
      'Harvest date is required.';

  @override
  String get publishTruffleValidationHarvestDateFuture =>
      'Harvest date cannot be in the future.';

  @override
  String get publishTruffleValidationImageFormat =>
      'Unsupported image format. Use PNG, JPG, or JPEG.';

  @override
  String get publishTruffleValidationImageMissing =>
      'The selected image could not be read.';

  @override
  String get publishTruffleValidationImageTooLarge =>
      'The selected image is still too large after optimization.';

  @override
  String get publishTruffleValidationImageProcessingFailed =>
      'Unable to prepare this image for upload.';

  @override
  String get publishTruffleImagePickerUnavailable =>
      'Unable to pick an image right now.';

  @override
  String get publishTruffleSubmitUnauthenticated =>
      'Your session expired. Sign in again before publishing.';

  @override
  String get publishTruffleSubmitNotAllowed =>
      'You cannot publish this truffle right now.';

  @override
  String get publishTruffleSubmitStripeVerificationPending =>
      'Stripe is still verifying your account. You can manage verification directly in Stripe.';

  @override
  String get publishTruffleSubmitStripeOnboardingRequired =>
      'Complete Stripe registration to publish this truffle.';

  @override
  String get publishTruffleSubmitInProgress =>
      'A publish request for this truffle is already in progress. Please wait a few seconds and try again.';

  @override
  String get publishTruffleSubmitValidation =>
      'Some product data is invalid. Review the form and try again.';

  @override
  String get publishTruffleSubmitInvalidImage =>
      'One or more selected images are invalid. Review them and try again.';

  @override
  String get publishTruffleSubmitNetwork =>
      'Network error. Check your connection and try again.';

  @override
  String get publishTruffleSubmitImageUpload =>
      'Unable to upload one or more product images.';

  @override
  String get publishTruffleSubmitUnknown =>
      'Unable to publish this truffle right now. Please try again.';

  @override
  String get publishTruffleAccessError =>
      'Unable to verify publish permissions right now. Pull to refresh and try again.';

  @override
  String get sellerMyTrufflesTitle => 'My truffles';

  @override
  String get sellerMyTrufflesTabPublishing => 'Publishing';

  @override
  String get sellerMyTrufflesTabActive => 'Active';

  @override
  String get sellerMyTrufflesTabReserved => 'Reserved';

  @override
  String get sellerMyTrufflesTabSold => 'Sold';

  @override
  String get sellerMyTrufflesTabExpired => 'Expired';

  @override
  String get sellerMyTrufflesStatusPublishing => 'Publishing';

  @override
  String get sellerMyTrufflesStatusReserved => 'Reserved';

  @override
  String get sellerMyTrufflesEmptyPublishingTitle =>
      'No truffles are publishing';

  @override
  String get sellerMyTrufflesEmptyPublishingSubtitle =>
      'Publishing listings appear here until they are ready to become visible to buyers.';

  @override
  String get sellerMyTrufflesEmptyActiveTitle => 'No active truffles';

  @override
  String get sellerMyTrufflesEmptyActiveSubtitle =>
      'Publish a truffle and it will appear here while it is available.';

  @override
  String get sellerMyTrufflesEmptyReservedTitle => 'No reserved truffles';

  @override
  String get sellerMyTrufflesEmptyReservedSubtitle =>
      'Truffles with an open order in progress appear here until the sale is completed or cancelled.';

  @override
  String get sellerMyTrufflesEmptySoldTitle => 'No sold truffles';

  @override
  String get sellerMyTrufflesEmptySoldSubtitle =>
      'Completed sales will appear here once a truffle has been purchased.';

  @override
  String get sellerMyTrufflesEmptyExpiredTitle => 'No expired truffles';

  @override
  String get sellerMyTrufflesEmptyExpiredSubtitle =>
      'Expired truffles will remain visible here for quick reference.';

  @override
  String get sellerMyTrufflesLoadError =>
      'Unable to load your truffles right now.';

  @override
  String get sellerMyTrufflesRetry => 'Retry';

  @override
  String get sellerMyTrufflesDeleteTitle => 'Delete this truffle?';

  @override
  String get sellerMyTrufflesDeleteMessage =>
      'This action is irreversible. The truffle, its images, and related saves will be removed.';

  @override
  String get sellerMyTrufflesDeleteCancel => 'Cancel';

  @override
  String get sellerMyTrufflesDeleteConfirm => 'Delete';

  @override
  String get sellerMyTrufflesDeleteSuccess => 'Truffle deleted successfully.';

  @override
  String get sellerMyTrufflesDeleteForbidden =>
      'This truffle can no longer be deleted.';

  @override
  String get sellerMyTrufflesDeleteNetwork =>
      'Connection issue while deleting the truffle. Please try again.';

  @override
  String get sellerMyTrufflesDeleteUnauthenticated =>
      'Your session expired. Sign in again before deleting a truffle.';

  @override
  String get sellerMyTrufflesDeleteUnknown =>
      'Unable to delete the truffle right now.';

  @override
  String get accountLanguageItalian => 'Italiano';

  @override
  String get accountLanguageEnglish => 'English';

  @override
  String get accountSupportTitle => 'Support';

  @override
  String get accountSupportIntro =>
      'Find quick answers about buying, selling, payments, shipping, and your account.';

  @override
  String get accountSupportFaqBuyingOrdersSection => 'Buying & Orders';

  @override
  String get accountSupportFaqBuyTruffleQuestion => 'How do I buy a truffle?';

  @override
  String get accountSupportFaqBuyTruffleAnswer =>
      'Browse available truffles, open a listing, review the product details, select a shipping address, and complete payment securely through Truffly.';

  @override
  String get accountSupportFaqTrackOrderQuestion => 'How can I track my order?';

  @override
  String get accountSupportFaqTrackOrderAnswer =>
      'Once the seller ships your order and provides a tracking number, it will appear on the Order Details page.';

  @override
  String get accountSupportFaqAfterOrderQuestion =>
      'What happens after I place an order?';

  @override
  String get accountSupportFaqAfterOrderAnswer =>
      'After payment, the seller has up to 48 hours to ship the truffles and provide tracking information. You will receive updates through the app and, if enabled, push notifications.';

  @override
  String get accountSupportFaqSellerDoesNotShipQuestion =>
      'What happens if the seller does not ship?';

  @override
  String get accountSupportFaqSellerDoesNotShipAnswer =>
      'If the seller does not provide tracking information within the required timeframe, the order may be automatically cancelled and refunded.';

  @override
  String get accountSupportFaqConfirmDeliveryQuestion =>
      'How do I confirm delivery?';

  @override
  String get accountSupportFaqConfirmDeliveryAnswer =>
      'When your order arrives, open the Order Details page and tap \"Confirm Delivery\". This confirms that the order was received successfully.';

  @override
  String get accountSupportFaqTrufflesQualitySection => 'Truffles & Quality';

  @override
  String get accountSupportFaqTrufflesFreshQuestion =>
      'Are the truffles fresh?';

  @override
  String get accountSupportFaqTrufflesFreshAnswer =>
      'Yes. Sellers are required to publish freshly harvested truffles and provide the harvest date for each listing.';

  @override
  String get accountSupportFaqQualityGradesQuestion =>
      'What do the quality grades mean?';

  @override
  String get accountSupportFaqQualityGradesAnswer =>
      'Quality grades help describe the appearance and condition of the truffles. First Quality generally includes the most regular and visually appealing truffles, while lower grades may have cosmetic imperfections but remain suitable for consumption.';

  @override
  String get accountSupportFaqStoreTrufflesQuestion =>
      'How should I store fresh truffles?';

  @override
  String get accountSupportFaqStoreTrufflesAnswer =>
      'Fresh truffles should be stored in the refrigerator in a sealed container with absorbent paper. Replace the paper daily and consume the truffles as soon as possible for the best experience.';

  @override
  String get accountSupportFaqDamagedOrderQuestion =>
      'What should I do if my order arrives damaged?';

  @override
  String get accountSupportFaqDamagedOrderAnswer =>
      'Contact support as soon as possible and provide photos of the product, packaging, and shipping label. We will review the situation and assist where possible.';

  @override
  String get accountSupportFaqShippingDeliverySection => 'Shipping & Delivery';

  @override
  String get accountSupportFaqSupportedCountriesQuestion =>
      'Which countries can I order from?';

  @override
  String get accountSupportFaqSupportedCountriesAnswer =>
      'Buyers located within supported European countries can place orders through Truffly.';

  @override
  String get accountSupportFaqShippingCostQuestion =>
      'How much does shipping cost?';

  @override
  String get accountSupportFaqShippingCostAnswer =>
      'Shipping costs are determined by the seller and are displayed before checkout.';

  @override
  String get accountSupportFaqTrackingNumberQuestion =>
      'Will I receive a tracking number?';

  @override
  String get accountSupportFaqTrackingNumberAnswer =>
      'Yes. Sellers must provide tracking information when shipping an order.';

  @override
  String get accountSupportFaqPackageDelayedQuestion =>
      'What happens if my package is delayed?';

  @override
  String get accountSupportFaqPackageDelayedAnswer =>
      'Delivery times depend on the shipping carrier. If your package appears delayed, check the tracking information first. If the issue persists, contact support.';

  @override
  String get accountSupportFaqPaymentsRefundsSection => 'Payments & Refunds';

  @override
  String get accountSupportFaqSecurePaymentsQuestion => 'Are payments secure?';

  @override
  String get accountSupportFaqSecurePaymentsAnswer =>
      'Yes. Payments are processed securely through Stripe. Truffly does not store your full payment card details.';

  @override
  String get accountSupportFaqPaymentChargedQuestion =>
      'When is my payment charged?';

  @override
  String get accountSupportFaqPaymentChargedAnswer =>
      'Your payment is charged when the order is successfully placed.';

  @override
  String get accountSupportFaqRefundsWorkQuestion => 'How do refunds work?';

  @override
  String get accountSupportFaqRefundsWorkAnswer =>
      'Refunds may be issued in accordance with the Refund & Cancellation Policy. Refund eligibility depends on the order status and the circumstances of the request.';

  @override
  String get accountSupportFaqRefundTimingQuestion =>
      'How long does a refund take?';

  @override
  String get accountSupportFaqRefundTimingAnswer =>
      'Refund processing times vary depending on your bank and payment provider. Most refunds are completed within a few business days.';

  @override
  String get accountSupportFaqSellingSection => 'Selling on Truffly';

  @override
  String get accountSupportFaqBecomeSellerQuestion =>
      'How do I become a seller?';

  @override
  String get accountSupportFaqBecomeSellerAnswer =>
      'Complete the seller application process, upload the required documents, and wait for approval from the Truffly team.';

  @override
  String get accountSupportFaqVerifyIdentityQuestion =>
      'Why do I need to verify my identity?';

  @override
  String get accountSupportFaqVerifyIdentityAnswer =>
      'Verification helps maintain trust and safety on the platform and ensures that only eligible sellers can publish products.';

  @override
  String get accountSupportFaqSellerApprovalTimingQuestion =>
      'How long does seller approval take?';

  @override
  String get accountSupportFaqSellerApprovalTimingAnswer =>
      'Most applications are reviewed within a few business days, although processing times may vary.';

  @override
  String get accountSupportFaqPublishAfterApprovalQuestion =>
      'Can I publish truffles immediately after approval?';

  @override
  String get accountSupportFaqPublishAfterApprovalAnswer =>
      'Before publishing, approved sellers must complete the required Stripe onboarding process for receiving payouts.';

  @override
  String get accountSupportFaqSellerPaymentsSection => 'Seller Payments';

  @override
  String get accountSupportFaqSellerPaymentTimingQuestion =>
      'When do I receive payment?';

  @override
  String get accountSupportFaqSellerPaymentTimingAnswer =>
      'Payments are released after the order has been completed according to the Truffly payment process.';

  @override
  String get accountSupportFaqStripeAccountQuestion =>
      'Why do I need a Stripe account?';

  @override
  String get accountSupportFaqStripeAccountAnswer =>
      'Stripe securely handles seller payouts and helps verify payment information and identity requirements.';

  @override
  String get accountSupportFaqCommissionQuestion =>
      'How much commission does Truffly charge?';

  @override
  String get accountSupportFaqCommissionAnswer =>
      'Truffly charges a fixed commission on completed sales. The current commission is displayed during the seller onboarding process.';

  @override
  String get accountSupportFaqAccountPrivacySection => 'Account & Privacy';

  @override
  String get accountSupportFaqDeleteAccountQuestion =>
      'How do I delete my account?';

  @override
  String get accountSupportFaqDeleteAccountAnswer =>
      'You can request account deletion from the Settings page inside the app.';

  @override
  String get accountSupportFaqAfterDeleteAccountQuestion =>
      'What happens when I delete my account?';

  @override
  String get accountSupportFaqAfterDeleteAccountAnswer =>
      'Personal data will be deleted or anonymized where possible. Certain records may be retained where required by law or necessary for security, accounting, or fraud prevention purposes.';

  @override
  String get accountSupportFaqProtectDataQuestion =>
      'How does Truffly protect my data?';

  @override
  String get accountSupportFaqProtectDataAnswer =>
      'Truffly uses secure authentication, protected storage, access controls, and other technical measures designed to protect user information.';

  @override
  String get accountSupportContactTitle => 'Contact support';

  @override
  String get accountSupportContactBody =>
      'If you need help with an order or delivery, write to us and include the main details.';

  @override
  String get accountSupportContactCta => 'Write to support';

  @override
  String get accountSupportEmailLaunchError =>
      'Unable to open your email app right now.';

  @override
  String get accountSettingsTitle => 'Settings';

  @override
  String get accountSettingsIntro =>
      'Manage language, notifications, and account information from one place.';

  @override
  String get accountSettingsPreferencesSection => 'Preferences';

  @override
  String get accountSettingsLanguageLabel => 'Language';

  @override
  String get accountSettingsNotificationsLabel => 'Notifications';

  @override
  String get accountSettingsLanguageSheetTitle => 'Choose a language';

  @override
  String get accountSettingsLanguageSheetBody =>
      'This updates the language used across the app.';

  @override
  String get accountSettingsLegalSection => 'Legal';

  @override
  String get accountSettingsPrivacyPolicyLabel => 'Privacy Policy';

  @override
  String get accountSettingsTermsLabel => 'Terms & Conditions';

  @override
  String get accountSettingsAccountSection => 'Account';

  @override
  String get accountSettingsDeleteAccountLabel => 'Delete account';

  @override
  String get accountSettingsDeleteAccountDialogTitle => 'Delete your account?';

  @override
  String get accountSettingsDeleteAccountDialogBody =>
      'We will delete your account if there is no transaction history. If you have orders or sold truffles, we will deactivate and anonymize it instead.';

  @override
  String get accountSettingsDeleteAccountDialogCancel => 'Cancel';

  @override
  String get accountSettingsDeleteAccountDialogConfirm => 'Confirm';

  @override
  String get accountSettingsDeleteAccountDeletedMessage =>
      'Your account was deleted. You have been signed out.';

  @override
  String get accountSettingsDeleteAccountDeactivatedMessage =>
      'Your account was deactivated for compliance. You have been signed out.';

  @override
  String get accountSettingsDeleteAccountUnauthorizedMessage =>
      'Your session expired. Sign in again to delete your account.';

  @override
  String get accountSettingsDeleteAccountInactiveMessage =>
      'This account is already inactive.';

  @override
  String get accountSettingsDeleteAccountErrorMessage =>
      'Unable to process your account request right now. Please try again.';

  @override
  String get notificationsInboxTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all as read';

  @override
  String get notificationsUnreadLabel => 'Unread';

  @override
  String get notificationsReadLabel => 'Read';

  @override
  String get notificationsEmptyState =>
      'You are all caught up. New updates will appear here.';

  @override
  String get notificationsErrorState =>
      'Unable to load notifications right now.';

  @override
  String get notificationsRetryButton => 'Retry';

  @override
  String get notificationGenericTitle => 'Notification';

  @override
  String get notificationGenericMessage =>
      'Open the notification center to view the latest update.';

  @override
  String get notificationFallbackTruffleName => 'your truffle';

  @override
  String get notificationFallbackSellerName => 'the seller';

  @override
  String get notificationFallbackTrackingCode => 'tracking unavailable';

  @override
  String get notificationFallbackSellerAmount => 'your payout';

  @override
  String get notificationOrderConfirmedTitle => 'Order confirmed';

  @override
  String notificationOrderConfirmedMessage(Object truffleName) {
    return 'Your order “$truffleName” has been confirmed. The seller has 48 hours to ship it.';
  }

  @override
  String get notificationPaymentFailedTitle => 'Payment failed';

  @override
  String notificationPaymentFailedMessage(Object truffleName) {
    return 'The payment for “$truffleName” failed. You can try again from checkout.';
  }

  @override
  String get notificationOrderShippedTitle => 'Order shipped';

  @override
  String notificationOrderShippedMessage(Object truffleName) {
    return 'Your order “$truffleName” has been shipped.';
  }

  @override
  String get notificationTrackingAvailableTitle => 'Tracking available';

  @override
  String notificationTrackingAvailableMessage(
    Object truffleName,
    Object trackingCode,
  ) {
    return 'Tracking is available for “$truffleName”: $trackingCode.';
  }

  @override
  String get notificationDeliveryConfirmationReminderTitle =>
      'Confirm delivery';

  @override
  String notificationDeliveryConfirmationReminderMessage(Object truffleName) {
    return 'Have you received “$truffleName”? Confirm delivery to complete the order.';
  }

  @override
  String get notificationOrderCompletedTitle => 'Order completed';

  @override
  String notificationOrderCompletedMessage(Object truffleName) {
    return 'The order “$truffleName” has been completed.';
  }

  @override
  String get notificationOrderAutoCompletedTitle =>
      'Order automatically completed';

  @override
  String notificationOrderAutoCompletedMessage(Object truffleName) {
    return 'The order “$truffleName” was automatically completed.';
  }

  @override
  String get notificationOrderCancelledBySellerTitle => 'Order cancelled';

  @override
  String notificationOrderCancelledBySellerMessage(Object truffleName) {
    return 'The order “$truffleName” was cancelled by the seller. Your refund will be started.';
  }

  @override
  String get notificationOrderAutoCancelledUnshippedTitle => 'Order cancelled';

  @override
  String notificationOrderAutoCancelledUnshippedMessage(Object truffleName) {
    return 'The order “$truffleName” was cancelled because it was not shipped within 48 hours.';
  }

  @override
  String get notificationRefundStartedTitle => 'Refund started';

  @override
  String notificationRefundStartedMessage(Object truffleName) {
    return 'The refund for “$truffleName” has been started.';
  }

  @override
  String get notificationRefundCompletedTitle => 'Refund completed';

  @override
  String notificationRefundCompletedMessage(Object truffleName) {
    return 'The refund for “$truffleName” has been completed.';
  }

  @override
  String get notificationReviewRequestTitle => 'Leave a review';

  @override
  String notificationReviewRequestMessage(
    Object sellerName,
    Object truffleName,
  ) {
    return 'How was your experience with “$sellerName”? Leave a review for “$truffleName”.';
  }

  @override
  String get notificationReviewAutoCreatedTitle => 'Automatic review';

  @override
  String notificationReviewAutoCreatedMessage(Object truffleName) {
    return 'We automatically completed the review for “$truffleName”.';
  }

  @override
  String get notificationFavoriteTruffleUnavailableTitle =>
      'Truffle no longer available';

  @override
  String notificationFavoriteTruffleUnavailableMessage(Object truffleName) {
    return '“$truffleName” is no longer available.';
  }

  @override
  String get notificationFavoriteTruffleExpiringTitle =>
      'Listing expiring soon';

  @override
  String notificationFavoriteTruffleExpiringMessage(Object truffleName) {
    return '“$truffleName” is still available, but the listing is about to expire.';
  }

  @override
  String get notificationSellerApplicationSubmittedTitle => 'Request submitted';

  @override
  String get notificationSellerApplicationSubmittedMessage =>
      'Your request to sell on Truffly has been submitted. We’ll notify you once it has been reviewed.';

  @override
  String get notificationSellerApprovedTitle => 'Seller approved';

  @override
  String get notificationSellerApprovedMessage =>
      'You have been approved as a seller. Complete Stripe to start publishing truffles.';

  @override
  String get notificationSellerRejectedTitle => 'Request not approved';

  @override
  String get notificationSellerRejectedMessage =>
      'Your seller request was not approved. Check the details or contact support.';

  @override
  String get notificationStripeOnboardingRequiredTitle => 'Set up payments';

  @override
  String get notificationStripeOnboardingRequiredMessage =>
      'Complete your payment setup to start selling on Truffly.';

  @override
  String get notificationStripeOnboardingCompletedTitle => 'Payments set up';

  @override
  String get notificationStripeOnboardingCompletedMessage =>
      'Payments are set up. You can now publish your truffles.';

  @override
  String get notificationTrufflePublishedTitle => 'Truffle published';

  @override
  String notificationTrufflePublishedMessage(Object truffleName) {
    return '“$truffleName” has been published and is now visible to users.';
  }

  @override
  String get notificationTruffleDeletedTitle => 'Truffle deleted';

  @override
  String notificationTruffleDeletedMessage(Object truffleName) {
    return '“$truffleName” has been deleted.';
  }

  @override
  String get notificationTruffleExpiredTitle => 'Listing expired';

  @override
  String notificationTruffleExpiredMessage(Object truffleName) {
    return 'The listing “$truffleName” has expired and is no longer visible.';
  }

  @override
  String get notificationSellerNewOrderTitle => 'New order received';

  @override
  String notificationSellerNewOrderMessage(Object truffleName) {
    return 'You received a new order for “$truffleName”. Ship it within 48 hours.';
  }

  @override
  String get notificationSellerShipping24hReminderTitle => 'Shipping reminder';

  @override
  String notificationSellerShipping24hReminderMessage(Object truffleName) {
    return 'Remember to ship “$truffleName”. You still have 24 hours to add tracking.';
  }

  @override
  String get notificationSellerShippingFinalReminderTitle =>
      'Final shipping reminder';

  @override
  String notificationSellerShippingFinalReminderMessage(Object truffleName) {
    return 'Last hours to ship “$truffleName”. If you do not add tracking, the order will be cancelled.';
  }

  @override
  String get notificationSellerOrderCancelledUnshippedTitle =>
      'Order cancelled';

  @override
  String notificationSellerOrderCancelledUnshippedMessage(Object truffleName) {
    return 'The order “$truffleName” was cancelled because it was not shipped within 48 hours.';
  }

  @override
  String get notificationSellerOrderMarkedShippedTitle => 'Order shipped';

  @override
  String notificationSellerOrderMarkedShippedMessage(Object truffleName) {
    return 'You marked “$truffleName” as shipped. We’ll notify the buyer.';
  }

  @override
  String get notificationSellerDeliveryConfirmedByBuyerTitle =>
      'Delivery confirmed';

  @override
  String notificationSellerDeliveryConfirmedByBuyerMessage(Object truffleName) {
    return 'The buyer confirmed delivery of “$truffleName”.';
  }

  @override
  String get notificationSellerOrderAutoCompletedTitle =>
      'Order automatically completed';

  @override
  String notificationSellerOrderAutoCompletedMessage(Object truffleName) {
    return 'The order “$truffleName” was automatically completed.';
  }

  @override
  String get notificationSellerPaymentReleasedTitle => 'Payment released';

  @override
  String notificationSellerPaymentReleasedMessage(
    Object truffleName,
    Object sellerAmount,
  ) {
    return 'The payment for “$truffleName” has been released. You will receive $sellerAmount.';
  }

  @override
  String get notificationSellerPaymentProcessingTitle => 'Payment processing';

  @override
  String notificationSellerPaymentProcessingMessage(Object truffleName) {
    return 'The payment for “$truffleName” is being processed.';
  }

  @override
  String get notificationSellerPaymentFailedTitle => 'Payment issue';

  @override
  String notificationSellerPaymentFailedMessage(Object truffleName) {
    return 'There is an issue with the payment for “$truffleName”. We are checking it.';
  }

  @override
  String get notificationSellerNewReviewTitle => 'New review';

  @override
  String notificationSellerNewReviewMessage(Object truffleName) {
    return 'You received a new review for “$truffleName”.';
  }

  @override
  String get notificationSellerAutoReviewReceivedTitle =>
      'Automatic review received';

  @override
  String notificationSellerAutoReviewReceivedMessage(Object truffleName) {
    return 'An automatic review was added for the order “$truffleName”.';
  }

  @override
  String get notificationBuyerWelcomeTitle => 'Welcome to Truffly 👋';

  @override
  String get notificationBuyerWelcomeMessage =>
      'Explore fresh truffles, discover new hunters, and bring the authentic taste of truffles home.';

  @override
  String get notificationProfileUpdatedTitle => 'Profile updated';

  @override
  String get notificationProfileUpdatedMessage =>
      'Your profile changes have been saved.';

  @override
  String get notificationSecurityNewLoginTitle => 'New login';

  @override
  String get notificationSecurityNewLoginMessage =>
      'A new login to your account was detected.';

  @override
  String get notificationTitleGeneric => 'Notification';

  @override
  String get notificationTitleOrderPlaced => 'Order update';

  @override
  String get notificationTitleOrderShipped => 'Order shipped';

  @override
  String get notificationTitleOrderCompleted => 'Order completed';

  @override
  String get notificationTitleOrderCancelled => 'Order cancelled';

  @override
  String get notificationTitleSellerApplicationSubmitted =>
      'Seller application';

  @override
  String get notificationTitleSellerApproved => 'Seller approved';

  @override
  String get notificationTitleSellerRejected => 'Seller rejected';

  @override
  String get notificationTitlePayoutReleased => 'Payout released';

  @override
  String get notificationTitleFavoriteTruffleDeleted =>
      'Saved truffle unavailable';

  @override
  String get notificationMessageOrderPlaced =>
      'Your order has been confirmed. The seller can now prepare it.';

  @override
  String get notificationMessageOrderShipped =>
      'The seller has shipped your order.';

  @override
  String get notificationMessageOrderCompleted =>
      'Your order has been completed.';

  @override
  String get notificationMessageOrderCancelled =>
      'Your order was cancelled or refunded.';

  @override
  String get notificationMessageOrderAutoCancelledUnshippedBuyer =>
      'Your order was cancelled and refunded because the seller did not ship it within 48 hours.';

  @override
  String get notificationMessageOrderAutoCancelledUnshippedSeller =>
      'The order was cancelled and refunded because it was not shipped within 48 hours.';

  @override
  String get notificationTitleBuyerReviewCreated => 'New review';

  @override
  String get notificationMessageBuyerReviewCreated =>
      'A buyer left a review for one of your completed orders.';

  @override
  String get notificationTitleAutoReviewCreated => 'Automatic review';

  @override
  String get notificationMessageAutoReviewCreated =>
      'An automatic review was created after the review window expired.';

  @override
  String get notificationTitleOrderDeliveryConfirmationReminder =>
      'Delivery reminder';

  @override
  String get notificationMessageOrderDeliveryConfirmationReminder =>
      'Please confirm delivery within 48 hours or the order will be auto-completed.';

  @override
  String get notificationMessageSellerApplicationSubmitted =>
      'We have received your request. Your documents are under review.';

  @override
  String get notificationMessageSellerApproved =>
      'Your request to become a seller has been approved.';

  @override
  String get notificationMessageSellerRejected =>
      'Your request to become a seller was not approved.';

  @override
  String get notificationMessagePayoutReleased => 'A payout has been released.';

  @override
  String get notificationMessageFavoriteTruffleDeleted =>
      'A truffle you saved is no longer available.';

  @override
  String get reviewSectionTitle => 'Review your order';

  @override
  String get reviewSectionCopy =>
      'Your review helps other buyers choose with more confidence and highlights the seller\'s work.';

  @override
  String get reviewUnavailableCopy =>
      'Reviewing is no longer available for this order.';

  @override
  String get reviewLeaveCta => 'Leave a review';

  @override
  String get reviewSubmittedLabel => 'Review sent';

  @override
  String get reviewSubmittedSnackBar =>
      'Thanks, your review has been published.';

  @override
  String get reviewSubmitErrorMessage =>
      'Unable to submit the review right now.';

  @override
  String get reviewSheetTitle => 'How was your experience?';

  @override
  String get reviewSheetSubtitle =>
      'Your review helps other buyers choose with more confidence and highlights the seller\'s work.';

  @override
  String get reviewRatingLabel => 'Rating';

  @override
  String get reviewCommentLabel => 'Comment';

  @override
  String get reviewCommentPlaceholder =>
      'Tell us how it went: freshness, shipping, truffle quality…';

  @override
  String get reviewWindowNote =>
      'You have 48 hours to leave a review. After that, a 5-star automatic review will be published.';

  @override
  String get reviewSubmitCta => 'Publish review';

  @override
  String get reviewCancelCta => 'Later';

  @override
  String get reviewRatingRequiredError => 'Please choose a rating.';

  @override
  String get reviewAutoLabel => 'Automatically created review';

  @override
  String get reviewAutoCommentCompletedSuccess =>
      'Automatic review: order completed successfully.';

  @override
  String get reviewAutoCommentUnshipped48h =>
      'Automatic review: order was not shipped within 48 hours.';

  @override
  String get reviewWindowExpiredMessage =>
      'The time to leave a review has expired. If you did not submit one, the planned automatic rating will be recorded.';

  @override
  String get reviewAlreadySubmittedMessage =>
      'You already left a review for this order.';

  @override
  String get accountPrivacyPolicyTitle => 'Privacy Policy';

  @override
  String get accountPrivacyPolicyLeadTitle => 'Your privacy on Truffly';

  @override
  String get accountPrivacyPolicyLeadBody =>
      'This summary explains how Truffly handles the information used to create your account, manage orders, and support your activity in the app.';

  @override
  String get accountPrivacyPolicySectionDataTitle => 'What data we collect';

  @override
  String get accountPrivacyPolicySectionDataBody =>
      'We may collect profile details, shipping information, order references, and messages you send to support so we can provide the service.';

  @override
  String get accountPrivacyPolicySectionUsageTitle => 'How we use it';

  @override
  String get accountPrivacyPolicySectionUsageBody =>
      'We use this information to manage your account, process orders, improve the marketplace experience, and communicate important updates.';

  @override
  String get accountPrivacyPolicySectionSharingTitle =>
      'When data can be shared';

  @override
  String get accountPrivacyPolicySectionSharingBody =>
      'Information is shared only when necessary to complete your order, operate the platform, comply with legal obligations, or assist you with support requests.';

  @override
  String get accountPrivacyPolicySectionRightsTitle => 'Your choices';

  @override
  String get accountPrivacyPolicySectionRightsBody =>
      'You can review and update the account information available in the app. Future versions will include more tools to manage privacy requests directly.';

  @override
  String get accountTermsTitle => 'Terms & Conditions';

  @override
  String get accountTermsLeadTitle => 'Using the Truffly app';

  @override
  String get accountTermsLeadBody =>
      'These terms summarize the basic rules for browsing the marketplace, placing orders, and interacting with sellers through Truffly.';

  @override
  String get accountTermsSectionOrdersTitle => 'Orders and availability';

  @override
  String get accountTermsSectionOrdersBody =>
      'Product availability can change quickly because fresh truffles are seasonal. Order confirmation depends on availability and final seller validation.';

  @override
  String get accountTermsSectionShippingTitle => 'Shipping and delivery';

  @override
  String get accountTermsSectionShippingBody =>
      'Shipping timelines may vary based on destination, freshness requirements, and courier operations. We will share relevant updates in your order flow whenever possible.';

  @override
  String get accountTermsSectionSupportTitle => 'Support and issues';

  @override
  String get accountTermsSectionSupportBody =>
      'If there is an issue with an order or delivery, contact support promptly so the team can review the situation and guide you on the next steps.';

  @override
  String get accountTermsSectionUpdatesTitle => 'Future updates';

  @override
  String get accountTermsSectionUpdatesBody =>
      'These texts are an MVP version and may be updated as Truffly expands its legal and operational flows.';

  @override
  String get accountSettingsRefundAndCancellationLabel =>
      'Refund & Cancellation';

  @override
  String get accountSettingsLegalInformationLabel => 'Legal Information';

  @override
  String get accountRefundAndCancellationTitle => 'Refund & Cancellation';

  @override
  String get accountLegalInformationTitle => 'Legal Information';

  @override
  String get accountPrivacyPolicyContent =>
      'Last updated: [Date]\n\nTruffly respects your privacy and is committed to protecting your personal data.\n\nThis Privacy Policy explains how Truffly collects, uses, stores, shares, and protects personal information when you use the Truffly mobile application and related services.\n\n1. Data Controller\n\nThe data controller is:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nEmail: [Privacy email]\nSupport email: truffly@gmail.com\n\n2. What Truffly is\n\nTruffly is a marketplace that connects buyers with verified Italian truffle hunters and sellers.\n\nTruffly provides the digital platform, account management, payment flow, order tools, seller verification tools, notifications, and support features.\n\nTruffly does not directly sell the truffles listed by sellers unless expressly stated otherwise.\n\n3. Personal data we collect\n\nWhen you use Truffly, we may collect the following data:\n\nAccount data\n• first name\n• last name\n• email address\n• password credentials managed through our authentication provider\n• country\n• region, where applicable\n• profile image, if uploaded\n• account role, such as buyer or seller\n\nBuyer data\n• shipping addresses\n• phone number for delivery\n• order history\n• favorite products\n• reviews submitted\n• support requests\n\nSeller data\n• seller profile information\n• region\n• bio\n• seller application status\n• truffle license or permit information\n• seller verification documents\n• Stripe Connect onboarding status\n• published products\n• sales history\n• reviews received\n\nOrder and payment data\n• purchased product\n• seller and buyer IDs\n• order amount\n• shipping cost\n• commission amount\n• payment status\n• refund status\n• Stripe transaction identifiers\n• tracking code\n• order status\n\nTruffly does not store full card numbers or complete payment card details. Payments are processed by Stripe.\n\nTechnical data\n• device information\n• operating system\n• IP address\n• app logs\n• security logs\n• push notification token\n• authentication session data\n\n4. Why we use your data\n\nWe process personal data to:\n• create and manage your account\n• allow you to buy and sell truffles\n• verify seller applications\n• process payments and refunds\n• manage orders and shipping information\n• send order-related notifications\n• provide customer support\n• prevent fraud and misuse\n• secure the platform\n• comply with legal obligations\n• manage account deletion and data requests\n\n5. Legal basis for processing\n\nWe process your data under the following legal bases:\n\nContract performance\nTo provide the Truffly service, manage accounts, process orders, and enable payments.\n\nLegal obligations\nTo comply with applicable laws, accounting obligations, consumer protection rules, and requests from competent authorities.\n\nLegitimate interest\nTo protect the platform, prevent fraud, verify sellers, maintain audit logs, and improve security.\n\nConsent\nFor push notifications and any optional processing where consent is required.\n\nYou can withdraw consent for notifications at any time through your device settings or Truffly settings where available.\n\n6. Seller verification documents\n\nIf you apply to become a seller, Truffly may request documents to verify your identity and your eligibility to sell truffles.\n\nThese documents are used only for verification and platform safety.\n\nWhere possible, identity documents are deleted after the verification process is completed, unless retention is required by law or necessary to protect Truffly against fraud, disputes, or legal claims.\n\nSeller license or permit information may be retained for as long as your seller account remains active and for any additional period required by law or legitimate compliance needs.\n\n7. Payments\n\nPayments are processed through Stripe.\n\nStripe may collect and process payment data, identity verification data, tax information, bank account details, and other information required to provide payment services.\n\nTruffly may receive and store payment identifiers, order status, refund status, and seller payout status, but does not store full payment card details.\n\n8. Push notifications\n\nTruffly may send push notifications related to:\n• order confirmations\n• shipment updates\n• refund updates\n• seller approval or rejection\n• payment release\n• important account or security notices\n\nYou can disable push notifications through your device settings.\n\nSome important service communications may still be shown inside the app.\n\n9. Who we share data with\n\nWe may share data with:\n• Stripe, for payments and seller onboarding\n• Supabase, for authentication, database, and storage\n• Firebase Cloud Messaging, for push notifications\n• hosting, infrastructure, security, and technical service providers\n• competent authorities, where legally required\n• buyers and sellers, only where necessary to complete an order\n\nFor example, a seller may receive shipping information needed to fulfill an order. A buyer may see seller profile information, ratings, and order-related details.\n\n10. International transfers\n\nSome service providers may process data outside the European Economic Area.\n\nWhere this happens, Truffly relies on appropriate safeguards, such as Standard Contractual Clauses or other lawful transfer mechanisms under applicable data protection laws.\n\n11. Data retention\n\nWe keep personal data only for as long as necessary.\n\nIndicatively:\n• account data: for as long as the account is active\n• order data: for the period required by law and accounting obligations\n• seller verification data: for the time necessary for verification and compliance\n• support requests: for the time necessary to manage the request and protect legal rights\n• security logs: for security, fraud prevention, and audit purposes\n• deleted accounts: data is deleted or anonymized unless retention is legally required\n\nIf an account has completed orders, reviews, payments, refunds, or seller activity, some data may need to be retained to comply with legal obligations and protect the rights of users and Truffly.\n\n12. Account deletion\n\nYou may request deletion of your account from within the app.\n\nWhen you delete your account, Truffly will delete or anonymize personal data where possible.\n\nSome data may be retained where necessary to:\n• comply with legal obligations\n• maintain accounting records\n• manage disputes\n• prevent fraud\n• protect the rights of Truffly, buyers, or sellers\n\nIf you are a seller or have completed transactions, order records may be retained in anonymized or limited form.\n\n13. Your rights\n\nUnder applicable data protection laws, you may have the right to:\n• access your personal data\n• correct inaccurate data\n• request deletion of your data\n• restrict processing\n• object to processing\n• request data portability\n• withdraw consent\n• lodge a complaint with a data protection authority\n\nTo exercise your rights, contact us at:\n\n[Privacy email]\n\n14. Security\n\nTruffly uses technical and organizational measures designed to protect personal data, including access controls, authentication systems, protected storage, server-side business logic, and security logs.\n\nNo digital system can be guaranteed to be completely secure.\n\n15. Children\n\nTruffly is not intended for users under 18 years old.\n\nIf we become aware that a minor has created an account, we may delete the account and associated data.\n\n16. Changes to this Privacy Policy\n\nWe may update this Privacy Policy from time to time.\n\nWhen changes are significant, we may notify users through the app or other appropriate channels.\n\n17. Contact\n\nFor privacy-related requests:\n[Privacy email]\n\nFor general support:\ntruffly@gmail.com';

  @override
  String get accountTermsContent =>
      'Last updated: [Date]\n\nWelcome to Truffly.\n\nThese Terms & Conditions govern your access to and use of the Truffly mobile application and related services.\n\nBy creating an account or using Truffly, you agree to these Terms.\n\n1. Operator of the platform\n\nTruffly is operated by:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nSupport email: truffly@gmail.com\n\n2. What Truffly does\n\nTruffly is a digital marketplace that allows buyers to purchase fresh truffles from verified Italian sellers.\n\nTruffly provides:\n• the mobile platform\n• account registration\n• seller verification tools\n• product listing tools\n• order management\n• payment flow through Stripe\n• notifications\n• review tools\n• support tools\n\nUnless expressly stated otherwise, Truffly is not the direct seller of the products listed on the platform.\n\nThe sales contract for the product is concluded between the buyer and the seller.\n\n3. User eligibility\n\nTo use Truffly, you must:\n• be at least 18 years old\n• provide accurate information\n• keep your account credentials secure\n• use the platform lawfully\n• comply with these Terms\n\nTruffly may suspend or terminate accounts that violate these Terms or applicable law.\n\n4. Buyer accounts\n\nBuyers may:\n• browse truffles\n• view seller profiles\n• purchase available products\n• manage shipping addresses\n• track orders\n• confirm delivery\n• leave reviews\n• contact support\n\nBuyers must provide accurate shipping and contact information.\n\nTruffly is not responsible for failed deliveries caused by incorrect or incomplete information provided by the buyer.\n\n5. Seller accounts\n\nOnly approved sellers may publish truffles on Truffly.\n\nSellers must:\n• be based in Italy\n• provide accurate identity and eligibility information\n• hold any license, permit, authorization, or requirement applicable to truffle harvesting and sale\n• publish truthful product information\n• use real product images\n• ship products within the required timeframe\n• provide valid tracking information\n• comply with tax, food, consumer, and commercial laws applicable to their activity\n\nSellers are responsible for the products they publish and sell.\n\nTruffly may approve, reject, suspend, or remove seller access where necessary to protect users, comply with law, or preserve platform trust.\n\n6. Product listings\n\nEach product listing must contain accurate information, including where applicable:\n• truffle type\n• quality\n• weight\n• price\n• harvest date\n• region\n• shipping cost\n• images\n\nSellers must not publish misleading, false, illegal, unsafe, or unavailable products.\n\nTruffly may remove listings that violate these Terms or platform rules.\n\n7. Product freshness and availability\n\nTruffles are fresh and perishable products.\n\nAvailability may be limited and time-sensitive.\n\nA product may become unavailable if it is sold, expired, removed, or cancelled according to platform rules.\n\n8. Orders\n\nWhen a buyer completes payment, the order is created and the seller must ship the product according to the rules shown in the app.\n\nThe seller must insert tracking information within the required timeframe.\n\nOrder statuses may include:\n• paid\n• shipped\n• completed\n• cancelled\n\nTruffly may use automated systems to update order status according to platform rules.\n\n9. Payments\n\nPayments are processed through Stripe.\n\nWhen a buyer purchases a product, payment is collected securely and held according to the platform payment flow.\n\nSeller payouts are released according to the order completion rules.\n\nTruffly applies a fixed commission of [10%] on completed transactions, unless otherwise stated.\n\nThe commission is calculated by the platform.\n\n10. Shipping\n\nThe seller is responsible for preparing and shipping the product properly.\n\nSellers must use packaging suitable for fresh truffles and must comply with applicable shipping and food safety requirements.\n\nShipping times and costs may vary depending on destination and seller settings.\n\nTruffly is not responsible for delays caused by couriers, incorrect addresses, force majeure, or events outside Truffly’s reasonable control.\n\n11. Buyer confirmation and automatic completion\n\nAfter shipment, the buyer may confirm delivery in the app.\n\nIf the buyer does not confirm within the timeframe shown in the app, the order may be automatically completed after the applicable waiting period.\n\nWhen an order is completed, seller payout may be released according to the payment flow.\n\n12. Cancellations\n\nOrders may be cancelled in the cases described in the Refund & Cancellation Policy.\n\nIf the seller does not ship within the required timeframe, the order may be automatically cancelled and refunded.\n\nBuyers cannot freely cancel an order after payment unless allowed by law, platform policy, or support review.\n\n13. Right of withdrawal\n\nFresh truffles are perishable food products.\n\nFor this reason, the right of withdrawal may not apply to purchases of fresh truffles where the product is liable to deteriorate or expire rapidly.\n\nThis does not affect any mandatory consumer rights that cannot be excluded by law.\n\n14. Reviews\n\nBuyers may leave one review for each completed order.\n\nReviews must be honest, relevant, and based on a real purchase.\n\nUsers may not post:\n• false reviews\n• offensive content\n• discriminatory content\n• spam\n• private personal data\n• threats\n• illegal content\n\nTruffly may remove reviews that violate these Terms or applicable law.\n\nIf the app provides automatic reviews after a certain period, this will be disclosed in the app.\n\n15. User content\n\nUsers may upload or publish content such as profile information, product images, descriptions, and reviews.\n\nBy uploading content, you confirm that:\n• you have the right to use it\n• it is accurate and lawful\n• it does not infringe third-party rights\n• it does not contain illegal, harmful, or misleading material\n\nTruffly may remove content that violates these Terms.\n\n16. Prohibited use\n\nYou must not:\n• create fake accounts\n• impersonate another person\n• publish false product information\n• manipulate reviews\n• attempt to bypass payment systems\n• harass other users\n• upload illegal or harmful content\n• interfere with platform security\n• use Truffly for fraud or unlawful activity\n\n17. Platform role and limitation of responsibility\n\nTruffly acts as a marketplace platform and technology intermediary.\n\nSellers are responsible for the products they publish and sell.\n\nBuyers and sellers are responsible for complying with laws applicable to their own conduct.\n\nTo the maximum extent permitted by law, Truffly is not responsible for:\n• false information provided by users\n• product quality issues caused by sellers\n• misuse of products\n• courier delays\n• incorrect shipping information\n• tax obligations of sellers\n• disputes not caused by Truffly’s own breach\n\nNothing in these Terms limits rights that cannot be excluded under applicable consumer law.\n\n18. Taxes\n\nSellers are responsible for determining and fulfilling their own tax, invoicing, accounting, and reporting obligations.\n\nTruffly does not provide tax advice.\n\nBuyers and sellers should consult a qualified professional where needed.\n\n19. Account suspension or termination\n\nTruffly may suspend or terminate an account if:\n• the user violates these Terms\n• the user provides false information\n• fraud or abuse is suspected\n• required by law\n• necessary to protect users or the platform\n\nUsers may delete their account from within the app, subject to legal retention obligations.\n\n20. Changes to the service\n\nTruffly may update, modify, suspend, or discontinue parts of the platform.\n\nWhere changes materially affect users, Truffly may provide notice through the app or other appropriate channels.\n\n21. Governing law\n\nThese Terms are governed by the laws of Italy, without prejudice to mandatory consumer protection rights that may apply in the buyer’s country of residence.\n\n22. Contact\n\nFor support:\ntruffly@gmail.com\n\nFor legal inquiries:\n[Legal email]';

  @override
  String get accountRefundAndCancellationContent =>
      'Last updated: [Date]\n\nThis Refund & Cancellation Policy explains how cancellations, refunds, shipment deadlines, and payment releases work on Truffly.\n\n1. General principle\n\nTruffly is a marketplace for fresh truffles sold by verified Italian sellers.\n\nFresh truffles are perishable products. For this reason, refunds and cancellations are managed according to product freshness, shipment status, seller obligations, and applicable consumer protection laws.\n\n2. Payment protection\n\nWhen a buyer pays for an order, the payment is processed securely through Stripe.\n\nThe payment may be held according to the Truffly payment flow until the order is shipped, confirmed, completed, cancelled, or refunded.\n\n3. Seller shipping deadline\n\nSellers must ship the product and provide tracking information within the timeframe shown in the app.\n\nFor Truffly’s standard flow, sellers are expected to ship within 48 hours from order confirmation, unless otherwise stated.\n\n4. Automatic cancellation if the seller does not ship\n\nIf the seller does not provide tracking information within the required timeframe, Truffly may automatically cancel the order.\n\nIn this case:\n• the buyer receives a refund\n• the seller does not receive the payout\n• the product may become available again where applicable\n\n5. Buyer cancellation\n\nBecause fresh truffles are perishable and time-sensitive products, buyers generally cannot cancel an order after payment once the seller has started preparing or shipping the product.\n\nA buyer may contact support if:\n• the order was placed by mistake\n• the shipping address is incorrect\n• the seller has not shipped yet\n• there is another serious issue\n\nTruffly will evaluate the request but cannot guarantee cancellation in every case.\n\n6. Seller cancellation\n\nA seller may cancel an order before shipment only where allowed by the app flow or by Truffly support.\n\nReasons may include:\n• product no longer suitable for sale\n• product quality issue\n• inability to ship\n• incorrect listing information\n\nIf the seller cancels before shipment, the buyer will receive a refund.\n\nRepeated seller cancellations may lead to account review or suspension.\n\n7. Refund after shipment\n\nAfter an order has been shipped, refunds are not automatic.\n\nA buyer may contact support if:\n• the product was not delivered\n• the product arrived damaged\n• the product is materially different from the listing\n• there is a serious issue with freshness or quality\n• tracking information shows a delivery problem\n\nTruffly may ask the buyer to provide evidence, such as photos, tracking information, or order details.\n\n8. Delivery confirmation\n\nWhen the buyer receives the product, they may confirm delivery in the app.\n\nOnce delivery is confirmed, the order may be completed and the seller payout may be released.\n\n9. Automatic completion\n\nIf the buyer does not confirm delivery or report an issue within the timeframe shown in the app, the order may be automatically completed.\n\nAfter automatic completion, the seller payout may be released.\n\nThis does not remove mandatory legal rights that cannot be excluded.\n\n10. Right of withdrawal\n\nFresh truffles are perishable food products and may deteriorate or expire rapidly.\n\nFor this reason, the legal right of withdrawal may not apply to purchases of fresh truffles.\n\nThis does not affect any mandatory rights that consumers may have under applicable law, including rights related to defective, damaged, or non-conforming products.\n\n11. Refund method and timing\n\nRefunds are processed through the original payment method where possible.\n\nRefund timing may depend on:\n• Stripe processing times\n• the buyer’s bank or card issuer\n• payment method used\n• fraud or compliance checks\n\nTruffly cannot control delays caused by banks or payment providers.\n\n12. Shipping costs\n\nWhere an order is cancelled before shipment due to seller failure, shipping costs paid by the buyer may be refunded.\n\nWhere a refund is requested after shipment, shipping costs may be refunded or excluded depending on the reason for the refund, applicable law, and support review.\n\n13. Disputes\n\nIf there is a problem with an order, the buyer should contact support as soon as possible.\n\nSupport email:\ntruffly@gmail.com\n\nThe buyer should include:\n• order number\n• description of the issue\n• photos, if relevant\n• tracking details, if available\n\n14. Abuse\n\nTruffly may refuse refunds, suspend accounts, or restrict access where fraud, abuse, false claims, or repeated misuse of the refund process is suspected.\n\n15. Contact\n\nFor refund and cancellation requests:\ntruffly@gmail.com';

  @override
  String get accountLegalInformationContent =>
      'Last updated: [Date]\n\nThis page provides legal information about Truffly and the operator of the platform.\n\nPlatform operator\n\nTruffly is operated by:\n\n[Legal owner / Company name]\nAddress: [Legal address]\nCountry: Italy\nEmail: [Legal email]\nSupport email: truffly@gmail.com\n\nVAT / tax information:\n[VAT number / Tax code / Not applicable / To be added]\n\nNature of the service\n\nTruffly is a digital marketplace that connects buyers with verified Italian sellers of fresh truffles.\n\nUnless expressly stated otherwise, Truffly does not directly sell the products listed in the app.\n\nThe sales contract for each product is concluded between the buyer and the seller.\n\nSeller responsibility\n\nSellers are responsible for:\n• the accuracy of their listings\n• the quality and condition of the products they sell\n• compliance with applicable harvesting, food, tax, commercial, and consumer laws\n• packaging and shipping the product correctly\n• providing valid tracking information\n\nBuyer responsibility\n\nBuyers are responsible for:\n• providing accurate account information\n• providing a correct shipping address\n• checking order details before payment\n• reporting delivery or product issues promptly\n• using the platform lawfully\n\nPayments\n\nPayments are processed securely through Stripe.\n\nTruffly may apply a platform commission to completed transactions.\n\nSeller payouts, refunds, and payment releases are managed according to the applicable payment flow and platform policies.\n\nConsumer information\n\nBefore completing a purchase, buyers are shown key order information, including product details, price, shipping cost, seller information where available, and total amount.\n\nFresh truffles are perishable food products. The right of withdrawal may not apply where products are liable to deteriorate or expire rapidly.\n\nAccount deletion and data requests\n\nUsers can request account deletion from within the app.\n\nSome data may be retained where required by law or necessary for security, accounting, fraud prevention, disputes, or legal claims.\n\nPrivacy-related requests can be sent to:\n[Privacy email]\n\nSupport\n\nFor general support:\ntruffly@gmail.com\n\nLegal notices\n\nAll trademarks, logos, app designs, text, images, and platform materials are owned by Truffly or used with permission, unless otherwise stated.\n\nUsers may not copy, reproduce, distribute, or misuse Truffly content without authorization.\n\nGoverning law\n\nThe platform is operated from Italy.\n\nThese legal notices are governed by Italian law, without prejudice to mandatory consumer protection rights that may apply in the user’s country of residence.';
}
