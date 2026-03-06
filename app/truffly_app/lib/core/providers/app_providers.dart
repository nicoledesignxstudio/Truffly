import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/bootstrap/data/auth_session_service.dart';
import 'package:truffly_app/core/bootstrap/data/backend_health_service.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final backendHealthServiceProvider = Provider<BackendHealthService>((ref) {
  return BackendHealthService();
});

final authSessionServiceProvider = Provider<AuthSessionService>((ref) {
  return AuthSessionService(ref.read(supabaseClientProvider));
});
