import 'package:supabase_flutter/supabase_flutter.dart';

sealed class AuthSessionResult {
  const AuthSessionResult();
}

class AuthenticatedSession extends AuthSessionResult {
  const AuthenticatedSession(this.session);

  final Session session;
}

class UnauthenticatedSession extends AuthSessionResult {
  const UnauthenticatedSession();
}

class InvalidSession extends AuthSessionResult {
  const InvalidSession();
}

class AuthSessionService {
  AuthSessionService(this._supabaseClient);

  static const Duration _sessionHydrationTimeout = Duration(seconds: 2);

  final SupabaseClient _supabaseClient;

  Future<AuthSessionResult> getSessionStatus() async {
    final session = await _resolveCurrentSession();
    if (session == null) {
      return const UnauthenticatedSession();
    }

    if (session.accessToken.trim().isEmpty || session.user.id.trim().isEmpty) {
      return const InvalidSession();
    }

    return AuthenticatedSession(session);
  }

  Future<Session?> _resolveCurrentSession() async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      return session;
    }

    try {
      await _supabaseClient.auth.onAuthStateChange.first.timeout(
        _sessionHydrationTimeout,
      );
    } catch (_) {
      // If session hydration takes too long, fall back to the current snapshot.
    }

    return _supabaseClient.auth.currentSession;
  }
}
