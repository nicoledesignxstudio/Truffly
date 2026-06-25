import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:truffly_app/features/onboarding/data/models/notification_permission_result.dart';

final class NotificationPermissionService {
  NotificationPermissionService(this._firebaseMessaging);

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
      AuthorizationStatus.provisional => NotificationPermissionResult.provisional,
      AuthorizationStatus.denied => NotificationPermissionResult.denied,
      AuthorizationStatus.notDetermined => NotificationPermissionResult.notDetermined,
    };
  }

  bool get isSupportedPlatform =>
      Platform.isIOS || Platform.isAndroid || kIsWeb;
}
