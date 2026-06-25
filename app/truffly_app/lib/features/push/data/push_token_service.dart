import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PushTokenServiceApi {
  Future<void> initialize();

  Future<void> syncCurrentToken({String? token});

  Future<void> clearCurrentToken();

  Future<bool> isCurrentDeviceNotificationsEnabled();

  Future<void> setCurrentDeviceNotificationsEnabled(bool enabled);

  Future<void> dispose();
}

final class PushTokenService implements PushTokenServiceApi {
  PushTokenService(this._supabaseClient, this._firebaseMessaging)
    : _tokenRefreshSubscription = null;

  final SupabaseClient _supabaseClient;
  final FirebaseMessaging? _firebaseMessaging;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _registeredToken;

  @override
  Future<void> initialize() async {
    if (_firebaseMessaging == null) return;
    _tokenRefreshSubscription ??= _firebaseMessaging.onTokenRefresh.listen(
      (token) async {
        await _syncCurrentToken(
          token: token,
          source: _PushTokenSyncSource.refresh,
        );
      },
    );
  }

  @override
  Future<void> syncCurrentToken({String? token}) async {
    await _syncCurrentToken(
      token: token,
      source: _PushTokenSyncSource.current,
    );
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
    if (_registeredToken == normalizedToken) return;

    final platform = _resolvePlatform();
    if (platform == null) return;

    final now = DateTime.now().toUtc().toIso8601String();

    try {
      await _supabaseClient.from('user_push_tokens').upsert({
        'user_id': currentUser.id,
        'token': normalizedToken,
        'platform': platform,
        'enabled': true,
        'last_seen_at': now,
        'updated_at': now,
      }, onConflict: 'token');

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
    final token = await _resolveCurrentToken();
    if (token == null) return false;

    final row = await _supabaseClient
        .from('user_push_tokens')
        .select('enabled')
        .eq('token', token)
        .maybeSingle();

    final enabled = row?['enabled'];
    return enabled is bool ? enabled : false;
  }

  @override
  Future<void> setCurrentDeviceNotificationsEnabled(bool enabled) async {
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

  String? _resolvePlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }
}

enum _PushTokenSyncSource { current, refresh }
