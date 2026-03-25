import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/account/data/account_details_service.dart';

final accountDetailsServiceProvider = Provider<AccountDetailsService>((ref) {
  return AccountDetailsService(
    authService: ref.read(authServiceProvider),
    profileService: ref.read(profileServiceProvider),
  );
});
