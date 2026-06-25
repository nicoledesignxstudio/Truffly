import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/core/router/app_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/features/auth/domain/auth_state.dart';
import 'package:truffly_app/features/notifications/application/notifications_providers.dart';
import 'package:truffly_app/features/notifications/data/notifications_repository.dart';
import 'package:truffly_app/features/notifications/presentation/notification_route_resolver.dart';
import 'package:truffly_app/features/push/application/push_token_service_provider.dart';

final pushNotificationsCoordinatorProvider = Provider<void>((ref) {
  final router = ref.read(appRouterProvider);
  final messaging = ref.read(firebaseMessagingProvider);
  final tokenService = ref.read(pushTokenServiceProvider);
  final notificationsRepository = ref.read(notificationsRepositoryProvider);
  final authState = ref.read(authNotifierProvider);
  StreamSubscription<RemoteMessage>? foregroundSubscription;
  StreamSubscription<RemoteMessage>? openedAppSubscription;

  if (Firebase.apps.isEmpty || messaging == null) {
    return;
  }

  unawaited(tokenService.initialize());
  if (authState is AuthAuthenticatedReady) {
    unawaited(tokenService.syncCurrentToken());
  }
  unawaited(_configureForegroundHandling(
    router: router,
    messaging: messaging,
    ref: ref,
    notificationsRepository: notificationsRepository,
  ).then((subscriptions) {
    foregroundSubscription = subscriptions.foreground;
    openedAppSubscription = subscriptions.openedApp;
  }));

  ref.listen<AuthState>(authNotifierProvider, (previous, next) {
    if (next is AuthAuthenticatedReady) {
      unawaited(tokenService.syncCurrentToken());
    }
  });

  ref.onDispose(() async {
    await foregroundSubscription?.cancel();
    await openedAppSubscription?.cancel();
    await tokenService.dispose();
  });
});

Future<_PushMessageSubscriptions> _configureForegroundHandling({
  required GoRouter router,
  required FirebaseMessaging messaging,
  required Ref ref,
  required NotificationsRepository notificationsRepository,
}) async {
  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  final subscription = FirebaseMessaging.onMessage.listen((message) {
    final title = message.notification?.title?.trim();
    final body = message.notification?.body?.trim();
    debugPrint(
      'Push foreground message received: title=${title == null || title.isEmpty ? '(empty)' : title}, '
      'body=${body == null || body.isEmpty ? '(empty)' : body}, data=${message.data}',
    );
    ref.invalidate(notificationsInboxProvider);
  });

  final openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen((message) {
    unawaited(
      _handlePushOpen(
        router,
        ref,
        notificationsRepository,
        message.data,
      ),
    );
  });

  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    await _handlePushOpen(
      router,
      ref,
      notificationsRepository,
      initialMessage.data,
    );
  }

  return _PushMessageSubscriptions(
    foreground: subscription,
    openedApp: openedAppSubscription,
  );
}

Future<void> _handlePushOpen(
  GoRouter router,
  Ref ref,
  NotificationsRepository notificationsRepository,
  Map<String, dynamic> data,
) async {
  final payload = parsePushNotificationPayload(data);

  if (payload.notificationId != null) {
    try {
      await notificationsRepository.markAsRead(payload.notificationId!);
      ref.invalidate(notificationsInboxProvider);
    } on NotificationsRepositoryException {
      ref.invalidate(notificationsInboxProvider);
    } catch (_) {
      ref.invalidate(notificationsInboxProvider);
    }
  } else {
    ref.invalidate(notificationsInboxProvider);
  }

  String? currentUserId;
  try {
    final profile = await ref.read(currentUserAccountProfileProvider.future);
    currentUserId = profile.userId;
  } catch (_) {
    currentUserId = null;
  }

  final route = payload.resolveRoute(currentUserId: currentUserId);
  router.go(route ?? AppRoutes.notifications);
}

final class _PushMessageSubscriptions {
  const _PushMessageSubscriptions({
    required this.foreground,
    required this.openedApp,
  });

  final StreamSubscription<RemoteMessage> foreground;
  final StreamSubscription<RemoteMessage> openedApp;
}
