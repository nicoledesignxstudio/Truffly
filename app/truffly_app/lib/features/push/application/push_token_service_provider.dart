import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/push/data/push_token_service.dart';

final pushTokenServiceProvider = Provider<PushTokenServiceApi>((ref) {
  return PushTokenService(
    ref.read(supabaseClientProvider),
    ref.read(firebaseMessagingProvider),
    ref.read(notificationPermissionServiceProvider),
  );
});
