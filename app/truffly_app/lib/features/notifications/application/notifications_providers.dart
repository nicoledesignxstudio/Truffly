import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/notifications/data/local_notifications_service.dart';
import 'package:truffly_app/features/notifications/data/notifications_repository.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.read(supabaseClientProvider));
});

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((
  ref,
) {
  return LocalNotificationsService();
});

final notificationsInboxProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final authState = ref.watch(authNotifierProvider);
  final remoteNotifications = await ref
      .read(notificationsRepositoryProvider)
      .fetchCurrentUserNotifications();

  final userId = switch (authState) {
    AuthAuthenticatedState(:final userId) => userId,
    _ => null,
  };

  if (userId == null || userId.trim().isEmpty) {
    return remoteNotifications;
  }

  final localNotifications = await ref
      .read(localNotificationsServiceProvider)
      .fetchCurrentUserLocalNotifications(userId: userId);

  final items = [...remoteNotifications, ...localNotifications];
  items.sort((left, right) => right.createdAt.compareTo(left.createdAt));
  return items;
});

final unreadNotificationCountProvider = Provider<AsyncValue<int>>((ref) {
  final notificationsAsync = ref.watch(notificationsInboxProvider);
  return notificationsAsync.whenData(
    (items) => items.where((item) => !item.isRead).length,
  );
});
