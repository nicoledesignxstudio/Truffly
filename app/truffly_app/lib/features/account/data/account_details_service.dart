import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/auth_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';

class AccountDetailsService {
  const AccountDetailsService({
    required AuthService authService,
    required ProfileService profileService,
  }) : _authService = authService,
       _profileService = profileService;

  final AuthService _authService;
  final ProfileService _profileService;

  Future<AuthResult<CurrentUserProfile>> loadCurrentProfile() {
    return _profileService.getCurrentUserProfile();
  }

  Future<AuthResult<AuthUnit>> updateProfile({
    required String firstName,
    required String lastName,
    required String countryCode,
    required String? region,
    required String? bio,
    required String? profileImageUrl,
    required bool isSeller,
  }) {
    return _profileService.updateCurrentUserProfileDetails(
      firstName: firstName,
      lastName: lastName,
      countryCode: countryCode,
      region: region,
      bio: isSeller ? bio : null,
      profileImageUrl: isSeller ? profileImageUrl : null,
    );
  }

  Future<AuthResult<AuthUnit>> updateEmail({
    required String email,
  }) {
    return _authService.updateEmail(email: email);
  }
}
