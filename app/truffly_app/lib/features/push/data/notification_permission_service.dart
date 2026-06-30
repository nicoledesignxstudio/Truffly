import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:truffly_app/features/onboarding/data/models/notification_permission_result.dart';

final class NotificationPermissionService {
  NotificationPermissionService(this._firebaseMessaging);

  static const _androidNotificationSettingsChannel = MethodChannel(
    'com.truffly.app/notification_settings',
  );

  final FirebaseMessaging? _firebaseMessaging;

  Future<NotificationPermissionResult> requestPermission() async {
    if (_firebaseMessaging == null) {
      return NotificationPermissionResult.denied;
    }

    if (!Platform.isIOS && !Platform.isAndroid) {
      return NotificationPermissionResult.denied;
    }

    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: true,
      sound: true,
    );

    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized => NotificationPermissionResult.granted,
      AuthorizationStatus.provisional =>
        NotificationPermissionResult.provisional,
      AuthorizationStatus.denied => NotificationPermissionResult.denied,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionResult.notDetermined,
    };
  }

  Future<NotificationPermissionResult> currentPermissionStatus() async {
    if (_firebaseMessaging == null) {
      return NotificationPermissionResult.denied;
    }

    if (!Platform.isIOS && !Platform.isAndroid) {
      return NotificationPermissionResult.denied;
    }

    final settings = await _firebaseMessaging.getNotificationSettings();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized => NotificationPermissionResult.granted,
      AuthorizationStatus.provisional =>
        NotificationPermissionResult.provisional,
      AuthorizationStatus.denied => NotificationPermissionResult.denied,
      AuthorizationStatus.notDetermined =>
        NotificationPermissionResult.notDetermined,
    };
  }

  Future<bool> areSystemNotificationsAllowed() async {
    if (Platform.isAndroid) {
      try {
        final result = await _androidNotificationSettingsChannel
            .invokeMethod<bool>('areNotificationsEnabled');
        return result ?? false;
      } catch (error, stackTrace) {
        debugPrint('system permission status check failed');
        debugPrint('$error');
        debugPrint('$stackTrace');
        return false;
      }
    }

    final status = await currentPermissionStatus();
    return status == NotificationPermissionResult.granted ||
        status == NotificationPermissionResult.provisional;
  }

  Future<void> openSystemNotificationSettings() async {
    if (!Platform.isAndroid) return;

    try {
      await _androidNotificationSettingsChannel.invokeMethod<void>(
        'openNotificationSettings',
      );
    } catch (error, stackTrace) {
      debugPrint('open notification settings failed');
      debugPrint('$error');
      debugPrint('$stackTrace');
    }
  }

  bool get isSupportedPlatform =>
      Platform.isIOS || Platform.isAndroid || kIsWeb;
}
