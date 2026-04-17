import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/bootstrap/data/auth_session_service.dart';
import 'package:truffly_app/core/bootstrap/data/backend_health_service.dart';
import 'package:truffly_app/features/auth/data/auth_service.dart';
import 'package:truffly_app/features/auth/data/profile_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final backendHealthServiceProvider = Provider<BackendHealthService>((ref) {
  return BackendHealthService();
});

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService(ref.read(supabaseClientProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(supabaseClientProvider));
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref.read(supabaseClientProvider));
});

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale?>(
  AppLocaleNotifier.new,
);

final appLocaleCodeProvider = Provider<String>((ref) {
  return ref.watch(appLocaleProvider)?.languageCode ??
      PlatformDispatcher.instance.locale.languageCode;
});

final notificationsEnabledProvider =
    NotifierProvider<NotificationsPreferenceNotifier, bool>(
      NotificationsPreferenceNotifier.new,
    );

class AppLocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => null;

  void setLanguageCode(String languageCode) {
    state = Locale(languageCode);
  }
}

class NotificationsPreferenceNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setEnabled(bool enabled) {
    state = enabled;
  }
}
