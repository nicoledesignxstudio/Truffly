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

  final SupabaseClient _supabaseClient;

  AuthSessionResult getSessionStatus() {
    final session = _supabaseClient.auth.currentSession;
    if (session == null) {
      return const UnauthenticatedSession();
    }

    if (session.accessToken.trim().isEmpty || session.user.id.trim().isEmpty) {
      return const InvalidSession();
    }

    return AuthenticatedSession(session);
  }
}
