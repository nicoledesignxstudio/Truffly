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
  String get authVerifyEmailNotYetVerified => 'Your email is not verified yet.';

  @override
  String get authVerifyEmailSessionExpired =>
      'Your session expired. Please sign in again.';

  @override
  String get authVerifyEmailResendButton => 'Resend email';

  @override
  String get authVerifyEmailResendSuccess => 'Verification email sent again.';

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
      'If the email exists, a reset link has been sent.';

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
  String get authWelcomeTitleLeading => 'Buy and sell';

  @override
  String get authWelcomeTitleAccent => 'premium truffles';

  @override
  String get authWelcomeSubtitle =>
      'Join a trusted marketplace built around\nquality, transparency, and real reviews.';

  @override
  String get authWelcomeCreateAccountButton => 'Create account';

  @override
  String get authWelcomeGoogleButton => 'Continue with Google';

  @override
  String get authWelcomeLoginButton => 'I already have an account';

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
      'Seller country is treated as Italy in this onboarding flow, so only region is required here.';

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
  String get onboardingNotificationsTitle => 'Stay updated with notifications';

  @override
  String get onboardingNotificationsSubtitle =>
      'Notifications help you follow the most important moments of your Truffly experience.';

  @override
  String get onboardingNotificationsBenefitOrderUpdates =>
      'Order updates from purchase to completion.';

  @override
  String get onboardingNotificationsBenefitShippingUpdates =>
      'Shipping and delivery updates for active orders.';

  @override
  String get onboardingNotificationsBenefitSellerApproval =>
      'Seller approval updates if you apply to sell on Truffly.';

  @override
  String get onboardingNotificationsBenefitPayments =>
      'Payment and payout related updates when relevant.';

  @override
  String get onboardingNotificationsEnableButton => 'Enable Notifications';

  @override
  String get onboardingNotificationsContinueWithoutButton =>
      'Continue Without Notifications';

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
  String get onboardingNotificationsStatusDenied =>
      'Permission denied. You can continue and enable notifications later in settings.';

  @override
  String get onboardingNotificationsStatusSkipped =>
      'You chose to continue without notifications for now.';

  @override
  String get onboardingNotificationsPermissionError =>
      'Unable to request notification permission right now. You can continue and try again later.';

  @override
  String get onboardingWelcomeBuyerTitle => 'Welcome to Truffly';

  @override
  String get onboardingWelcomeBuyerSubtitle =>
      'Your buyer onboarding is complete.';

  @override
  String get onboardingWelcomeBuyerMessage =>
      'You are ready to start exploring premium truffles, trusted sellers, and secure purchases in the app.';

  @override
  String get onboardingWelcomeSellerTitle => 'Your Truffly profile is ready';

  @override
  String get onboardingWelcomeSellerSubtitle =>
      'You are ready to complete seller onboarding.';

  @override
  String get onboardingWelcomeSellerMessage =>
      'Enter the app to continue with your account. We will keep the seller review flow separate from approval and update you as it progresses.';

  @override
  String get onboardingWelcomeDefaultTitle => 'Welcome to Truffly';

  @override
  String get onboardingWelcomeDefaultSubtitle =>
      'You are almost ready to enter the app.';

  @override
  String get onboardingWelcomeDefaultMessage =>
      'Review your onboarding details and continue when you are ready.';

  @override
  String get onboardingBuyerInfo1Title =>
      'Fresh truffles, selected for quality';

  @override
  String get onboardingBuyerInfo1Description =>
      'Truffly is built for people who want access to premium truffles with a simple mobile experience focused on freshness, origin, and product quality.';

  @override
  String get onboardingBuyerInfo2Title => 'Secure purchases with escrow logic';

  @override
  String get onboardingBuyerInfo2Description =>
      'Payments are designed to follow a protected order flow. Truffly keeps the purchase experience clear and secure while the order moves from payment to shipment to completion.';

  @override
  String get onboardingBuyerInfo3Title => 'Verified sellers and trust signals';

  @override
  String get onboardingBuyerInfo3Description =>
      'Buyers can explore a marketplace built around verified sellers, transparent profiles, reviews, and a stronger sense of trust across the community.';

  @override
  String get onboardingSellerInfo1Title =>
      'Sell your truffles to a focused market';

  @override
  String get onboardingSellerInfo1Description =>
      'Truffly helps truffle hunters reach buyers through a dedicated mobile marketplace designed around quality, trust, and clear order management.';

  @override
  String get onboardingSellerInfo2Title => 'A clear commission model';

  @override
  String get onboardingSellerInfo2Description =>
      'Truffly applies a 10% commission on completed sales. The goal is to keep seller economics simple and predictable from the beginning.';

  @override
  String get onboardingSellerInfo3Title => 'Shipping timing matters';

  @override
  String get onboardingSellerInfo3Description =>
      'Orders follow strict timing expectations. Sellers are expected to ship quickly, and the current MVP flow is built around a 48-hour shipping rule.';

  @override
  String get onboardingSellerInfo4Title =>
      'Approval, escrow, and payout expectations';

  @override
  String get onboardingSellerInfo4Description =>
      'Seller onboarding includes review and approval steps. Payments and payouts follow a structured flow, and Stripe-related setup happens only after approval.';

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
      'How would you like to use Truffly';

  @override
  String get onboardingRoleSelectionSubtitle =>
      'Choose how you want to get started.\nYou can always change this later.';

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
  String get truffleSearchHint => 'Search by name or Latin name';

  @override
  String get truffleSearchApply => 'Search';

  @override
  String get truffleLoadError =>
      'Unable to load truffles right now. Please try again.';

  @override
  String get truffleRetry => 'Retry';

  @override
  String get truffleEmptyTitle => 'No products match your search';

  @override
  String get truffleEmptySubtitle =>
      'Try changing filters or check again later.';

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
  String get truffleTypeMacrosporum => 'Smooth Black Truffle';

  @override
  String get truffleTypeBrumaleMoschatum => 'Musky Brumal Truffle';

  @override
  String get truffleTypeMesentericum => 'Mesenteric Truffle';

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
      'You can update the seller avatar from camera or gallery. If you remove the current photo, the profile falls back to initials.';

  @override
  String get accountDetailsPhotoPendingHelper =>
      'You selected a new photo locally. The final upload connection will be added in the next step without polluting the current data model.';

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
  String get accountDetailsPhotoUploadPending =>
      'The new photo is ready as a local preview. We will connect the final upload in the next technical step.';

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
      'We sent a verification link to your new email address. Verify your email to continue.';

  @override
  String get shippingAddressesTitle => 'Shipping addresses';

  @override
  String get shippingAddressesSubtitle =>
      'Choose which address to keep ready for checkout and update it whenever your delivery details change.';

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
      'Only approved sellers with Stripe onboarding completed can publish truffles.';

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
      'Find quick answers about orders, shipping, and delivery support.';

  @override
  String get accountSupportFaqSection => 'FAQ';

  @override
  String get accountSupportFaqOrderFlowQuestion =>
      'How does an order work on Truffly?';

  @override
  String get accountSupportFaqOrderFlowAnswer =>
      'Choose your truffle, confirm the order, and we will keep you updated until delivery.';

  @override
  String get accountSupportFaqShippingTimingQuestion =>
      'When is the truffle shipped?';

  @override
  String get accountSupportFaqShippingTimingAnswer =>
      'Fresh truffles are prepared and shipped as quickly as possible after order confirmation.';

  @override
  String get accountSupportFaqOrderTrackingQuestion =>
      'How can I follow my order status?';

  @override
  String get accountSupportFaqOrderTrackingAnswer =>
      'You can check the latest order status from the My orders section in your account.';

  @override
  String get accountSupportFaqCancellationQuestion => 'Can I cancel an order?';

  @override
  String get accountSupportFaqCancellationAnswer =>
      'If you need to cancel an order, contact support as soon as possible and we will review the request.';

  @override
  String get accountSupportFaqDeliveryIssueQuestion =>
      'What happens if there is a delivery problem?';

  @override
  String get accountSupportFaqDeliveryIssueAnswer =>
      'Write to support with your order details and we will help you resolve the issue quickly.';

  @override
  String get accountSupportFaqContactQuestion => 'How can I contact support?';

  @override
  String get accountSupportFaqContactAnswer =>
      'Use the email below to contact the Truffly team directly.';

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
      'This action is not available yet from the app. Confirm only if you want to continue as soon as the flow is ready.';

  @override
  String get accountSettingsDeleteAccountDialogCancel => 'Cancel';

  @override
  String get accountSettingsDeleteAccountDialogConfirm => 'Confirm';

  @override
  String get accountSettingsDeleteAccountPendingMessage =>
      'Account deletion is not available in-app yet. Contact support if you need immediate help.';

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
}
