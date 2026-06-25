import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/features/push/application/push_token_service_provider.dart';
import 'package:truffly_app/features/push/data/push_token_service.dart';

final notificationPreferenceServiceProvider =
    Provider<PushTokenServiceApi>((ref) {
  return ref.read(pushTokenServiceProvider);
});

final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  return ref.read(notificationPreferenceServiceProvider)
      .isCurrentDeviceNotificationsEnabled();
});
