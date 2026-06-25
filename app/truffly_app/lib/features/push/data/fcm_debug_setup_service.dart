import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

final class FcmDebugSetupService {
  FcmDebugSetupService(this._firebaseMessaging);

  final FirebaseMessaging _firebaseMessaging;
  StreamSubscription<String>? _tokenRefreshSubscription;

  Future<void> setup() async {
    if (!kDebugMode || !Platform.isAndroid) {
      return;
    }

    debugPrint('FCM setup started');

    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint(
        'notification permission status: ${settings.authorizationStatus.name}',
      );

      final token = await _firebaseMessaging.getToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('FCM token is null');
      } else {
        debugPrint('FCM token obtained: ${token.trim()}');
      }

      _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen((
        refreshedToken,
      ) {
        final normalizedToken = refreshedToken.trim();
        if (normalizedToken.isEmpty) {
          debugPrint('FCM token is null');
          return;
        }

        debugPrint('FCM token refreshed: $normalizedToken');
      });
    } catch (error, stackTrace) {
      debugPrint('FCM setup failed');
      debugPrint('$error');
      debugPrint('$stackTrace');
    }
  }
}
