import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/data/auth_result.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';

final currentUserAccountProfileProvider = FutureProvider<CurrentUserProfile>((
  ref,
) async {
  final result = await ref.read(profileServiceProvider).getCurrentUserProfile();
  if (result case AuthSuccess<CurrentUserProfile>(:final data)) {
    return data;
  }

  if (result case AuthFailureResult<CurrentUserProfile>(:final failure)) {
    throw failure;
  }

  throw StateError('Unexpected account profile result.');
});
