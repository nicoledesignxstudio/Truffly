import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/onboarding/data/models/notification_permission_result.dart';
import 'package:truffly_app/features/push/data/notification_permission_service.dart';

abstract interface class PushTokenServiceApi {
  Future<void> initialize();

  Future<void> syncCurrentToken({String? token});

  Future<void> clearCurrentToken();

  Future<bool> isCurrentDeviceNotificationsEnabled();

  Future<NotificationEnableResult> enableCurrentDeviceNotifications({
    bool requestPermission = true,
  });

  Future<void> setCurrentDeviceNotificationsEnabled(bool enabled);

  Future<void> openSystemNotificationSettings();

  Future<void> dispose();
}

enum NotificationEnableStatus {
  enabled,
  noActiveUser,
  systemNotificationsDisabled,
  tokenMissing,
  unsupportedPlatform,
  failed,
}

final class NotificationEnableResult {
  const NotificationEnableResult(this.status);

  final NotificationEnableStatus status;

  bool get isEnabled => status == NotificationEnableStatus.enabled;
}

final class PushTokenService implements PushTokenServiceApi {
  PushTokenService(
    this._supabaseClient,
    this._firebaseMessaging,
    this._notificationPermissionService,
  ) : _tokenRefreshSubscription = null;

  final SupabaseClient _supabaseClient;
  final FirebaseMessaging? _firebaseMessaging;
  final NotificationPermissionService _notificationPermissionService;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _registeredToken;

  @override
  Future<void> initialize() async {
    if (_firebaseMessaging == null) return;
    _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen((
      token,
    ) async {
      await _syncCurrentToken(
        token: token,
        source: _PushTokenSyncSource.refresh,
      );
    });
  }

  @override
  Future<void> syncCurrentToken({String? token}) async {
    await _syncCurrentToken(token: token, source: _PushTokenSyncSource.current);
  }

  Future<void> _syncCurrentToken({
    String? token,
    required _PushTokenSyncSource source,
  }) async {
    if (_firebaseMessaging == null) return;
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      debugPrint('FCM token save skipped: no active user');
      return;
    }

    final normalizedToken = await _resolveCurrentToken(token: token);
    if (normalizedToken == null) return;

    final systemAllowed = await _areNotificationsAllowedForSync();
    if (!systemAllowed) return;

    final platform = _resolvePlatform();
    if (platform == null) return;

    try {
      await _enableTokenRow(
        userId: currentUser.id,
        token: normalizedToken,
        platform: platform,
      );

      _registeredToken = normalizedToken;
      if (source == _PushTokenSyncSource.refresh) {
        debugPrint('FCM token refreshed and saved');
      } else {
        debugPrint('FCM token saved to Supabase');
      }
    } catch (error, stackTrace) {
      debugPrint('FCM token save failed');
      debugPrint('$error');
      debugPrint('$stackTrace');
    }
  }

  @override
  Future<void> clearCurrentToken() async {
    if (_firebaseMessaging == null) return;
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      _registeredToken = null;
      return;
    }

    final token = _registeredToken ?? await _resolveCurrentToken();
    if (token == null) return;

    try {
      await _supabaseClient
          .from('user_push_tokens')
          .update({
            'enabled': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', currentUser.id)
          .eq('token', token);
      debugPrint('FCM token disabled/deleted on logout');
    } catch (error) {
      debugPrint('FCM token save failed');
      debugPrint('$error');
    } finally {
      _registeredToken = null;
    }
  }

  @override
  Future<bool> isCurrentDeviceNotificationsEnabled() async {
    if (_firebaseMessaging == null) return false;
    final systemAllowed = await _notificationPermissionService
        .areSystemNotificationsAllowed();
    if (!systemAllowed) {
      debugPrint('settings notification state refreshed');
      return false;
    }

    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      debugPrint('settings notification state refreshed');
      return false;
    }

    final token = await _resolveCurrentToken();
    if (token == null) {
      debugPrint('settings notification state refreshed');
      return false;
    }

    final row = await _supabaseClient
        .from('user_push_tokens')
        .select('enabled')
        .eq('user_id', currentUser.id)
        .eq('token', token)
        .maybeSingle();

    final enabled = row?['enabled'];
    final isEnabled = enabled is bool ? enabled : false;
    if (row != null && !isEnabled) {
      debugPrint('token row exists but disabled');
    }
    debugPrint('settings notification state refreshed');
    return isEnabled;
  }

  @override
  Future<NotificationEnableResult> enableCurrentDeviceNotifications({
    bool requestPermission = true,
  }) async {
    debugPrint('notification enable requested');

    if (_firebaseMessaging == null) {
      debugPrint('token enable failed');
      return const NotificationEnableResult(
        NotificationEnableStatus.unsupportedPlatform,
      );
    }

    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      debugPrint('FCM token save skipped: no active user');
      debugPrint('token enable failed');
      return const NotificationEnableResult(
        NotificationEnableStatus.noActiveUser,
      );
    }

    try {
      final permissionStatus = requestPermission
          ? await _notificationPermissionService.requestPermission()
          : await _notificationPermissionService.currentPermissionStatus();
      debugPrint('system permission status: ${permissionStatus.name}');

      final systemAllowed = await _notificationPermissionService
          .areSystemNotificationsAllowed();
      if (!_isAllowedPermission(permissionStatus) || !systemAllowed) {
        debugPrint('token enable failed');
        return const NotificationEnableResult(
          NotificationEnableStatus.systemNotificationsDisabled,
        );
      }

      final token = await _resolveCurrentToken();
      if (token == null) {
        debugPrint('FCM token is null');
        debugPrint('token enable failed');
        return const NotificationEnableResult(
          NotificationEnableStatus.tokenMissing,
        );
      }
      debugPrint('current FCM token found');

      final platform = _resolvePlatform();
      if (platform == null) {
        debugPrint('token enable failed');
        return const NotificationEnableResult(
          NotificationEnableStatus.unsupportedPlatform,
        );
      }

      final existingEnabled = await _readCurrentTokenEnabled(
        userId: currentUser.id,
        token: token,
      );
      if (existingEnabled == false) {
        debugPrint('token row exists but disabled');
        debugPrint('re-enabling current token');
      }

      await _enableTokenRow(
        userId: currentUser.id,
        token: token,
        platform: platform,
      );
      _registeredToken = token;
      debugPrint('token enabled in Supabase');
      return const NotificationEnableResult(NotificationEnableStatus.enabled);
    } catch (error, stackTrace) {
      debugPrint('token enable failed');
      debugPrint('$error');
      debugPrint('$stackTrace');
      return const NotificationEnableResult(NotificationEnableStatus.failed);
    }
  }

  @override
  Future<void> setCurrentDeviceNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final result = await enableCurrentDeviceNotifications();
      if (!result.isEnabled) {
        throw NotificationEnableException(result.status);
      }
      return;
    }

    if (_firebaseMessaging == null) return;
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) return;

    final token = await _resolveCurrentToken();
    if (token == null) return;

    final platform = _resolvePlatform();
    if (platform == null) return;

    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await _supabaseClient.from('user_push_tokens').upsert({
        'user_id': currentUser.id,
        'token': token,
        'platform': platform,
        'enabled': enabled,
        'last_seen_at': now,
        'updated_at': now,
      }, onConflict: 'token');

      _registeredToken = token;
    } catch (error, stackTrace) {
      debugPrint('FCM token save failed');
      debugPrint('$error');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> openSystemNotificationSettings() {
    return _notificationPermissionService.openSystemNotificationSettings();
  }

  @override
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<String?> _resolveCurrentToken({String? token}) async {
    final nextToken = token ?? await _resolveFirebaseToken();
    if (nextToken == null || nextToken.trim().isEmpty) return null;

    return nextToken.trim();
  }

  Future<String?> _resolveFirebaseToken() async {
    if (_firebaseMessaging == null) return null;
    return _firebaseMessaging.getToken();
  }

  Future<bool> _areNotificationsAllowedForSync() async {
    try {
      final permissionStatus = await _notificationPermissionService
          .currentPermissionStatus();
      final systemAllowed = await _notificationPermissionService
          .areSystemNotificationsAllowed();
      return _isAllowedPermission(permissionStatus) && systemAllowed;
    } catch (_) {
      return false;
    }
  }

  Future<bool?> _readCurrentTokenEnabled({
    required String userId,
    required String token,
  }) async {
    final row = await _supabaseClient
        .from('user_push_tokens')
        .select('enabled')
        .eq('user_id', userId)
        .eq('token', token)
        .maybeSingle();

    final enabled = row?['enabled'];
    return enabled is bool ? enabled : null;
  }

  Future<void> _enableTokenRow({
    required String userId,
    required String token,
    required String platform,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      await _supabaseClient.rpc<void>(
        'register_user_push_token',
        params: {'p_token': token, 'p_platform': platform},
      );
    } on PostgrestException catch (error) {
      if (!_isMissingRegisterPushTokenRpc(error)) {
        rethrow;
      }

      await _supabaseClient.from('user_push_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platform,
        'enabled': true,
        'last_seen_at': now,
        'updated_at': now,
      }, onConflict: 'token');
    }
  }

  bool _isMissingRegisterPushTokenRpc(PostgrestException error) {
    return error.code == '42883' ||
        error.message.contains('register_user_push_token');
  }

  bool _isAllowedPermission(NotificationPermissionResult status) {
    return status == NotificationPermissionResult.granted ||
        status == NotificationPermissionResult.provisional;
  }

  String? _resolvePlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }
}

final class NotificationEnableException implements Exception {
  const NotificationEnableException(this.status);

  final NotificationEnableStatus status;
}

enum _PushTokenSyncSource { current, refresh }
