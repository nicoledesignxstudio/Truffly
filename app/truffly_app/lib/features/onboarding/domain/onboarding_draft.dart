import 'package:truffly_app/features/onboarding/domain/onboarding_path.dart';

enum OnboardingNotificationPermissionStatus {
  notRequested,
  granted,
  denied,
}

enum OnboardingNotificationChoice {
  undecided,
  enabled,
  skipped,
}

final class OnboardingLocalDocument {
  const OnboardingLocalDocument({
    required this.localPath,
    required this.fileName,
  });

  final String localPath;
  final String fileName;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OnboardingLocalDocument &&
            other.localPath == localPath &&
            other.fileName == fileName);
  }

  @override
  int get hashCode => Object.hash(localPath, fileName);
}

final class OnboardingDraft {
  const OnboardingDraft({
    this.path,
    this.firstName = '',
    this.lastName = '',
    this.countryCode,
    this.region,
    this.tesserinoNumber = '',
    this.identityDocument,
    this.tesserinoDocument,
    this.notificationChoice = OnboardingNotificationChoice.undecided,
    this.notificationPermissionStatus =
        OnboardingNotificationPermissionStatus.notRequested,
  });

  final OnboardingPath? path;
  final String firstName;
  final String lastName;
  final String? countryCode;
  final String? region;
  final String tesserinoNumber;
  final OnboardingLocalDocument? identityDocument;
  final OnboardingLocalDocument? tesserinoDocument;
  final OnboardingNotificationChoice notificationChoice;
  final OnboardingNotificationPermissionStatus notificationPermissionStatus;

  bool get isBuyer => path?.isBuyer ?? false;
  bool get isSeller => path?.isSeller ?? false;
  bool get requiresRegion {
    if (isSeller) return true;
    return countryCode?.trim().toUpperCase() == 'IT';
  }

  bool get requiresDocuments => isSeller;
  bool get hasBothSellerDocuments =>
      identityDocument != null && tesserinoDocument != null;
  bool get hasRequestedNotificationPermission =>
      notificationPermissionStatus !=
      OnboardingNotificationPermissionStatus.notRequested;
  bool get notificationPermissionGranted =>
      notificationPermissionStatus ==
      OnboardingNotificationPermissionStatus.granted;
  bool get notificationsEnabled =>
      notificationChoice == OnboardingNotificationChoice.enabled;
  bool get notificationsSkipped =>
      notificationChoice == OnboardingNotificationChoice.skipped;

  OnboardingDraft copyWith({
    Object? path = _sentinel,
    String? firstName,
    String? lastName,
    Object? countryCode = _sentinel,
    Object? region = _sentinel,
    String? tesserinoNumber,
    Object? identityDocument = _sentinel,
    Object? tesserinoDocument = _sentinel,
    OnboardingNotificationChoice? notificationChoice,
    OnboardingNotificationPermissionStatus? notificationPermissionStatus,
  }) {
    return OnboardingDraft(
      path: identical(path, _sentinel) ? this.path : path as OnboardingPath?,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      countryCode: identical(countryCode, _sentinel)
          ? this.countryCode
          : countryCode as String?,
      region: identical(region, _sentinel) ? this.region : region as String?,
      tesserinoNumber: tesserinoNumber ?? this.tesserinoNumber,
      identityDocument: identical(identityDocument, _sentinel)
          ? this.identityDocument
          : identityDocument as OnboardingLocalDocument?,
      tesserinoDocument: identical(tesserinoDocument, _sentinel)
          ? this.tesserinoDocument
          : tesserinoDocument as OnboardingLocalDocument?,
      notificationChoice: notificationChoice ?? this.notificationChoice,
      notificationPermissionStatus:
          notificationPermissionStatus ?? this.notificationPermissionStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is OnboardingDraft &&
            other.path == path &&
            other.firstName == firstName &&
            other.lastName == lastName &&
            other.countryCode == countryCode &&
            other.region == region &&
            other.tesserinoNumber == tesserinoNumber &&
            other.identityDocument == identityDocument &&
            other.tesserinoDocument == tesserinoDocument &&
            other.notificationChoice == notificationChoice &&
            other.notificationPermissionStatus == notificationPermissionStatus);
  }

  @override
  int get hashCode => Object.hash(
        path,
        firstName,
        lastName,
        countryCode,
        region,
        tesserinoNumber,
        identityDocument,
        tesserinoDocument,
        notificationChoice,
        notificationPermissionStatus,
      );
}

const Object _sentinel = Object();
