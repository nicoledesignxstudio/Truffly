sealed class AuthState {
  const AuthState();

  List<Object?> get props => const [];

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthState &&
            _listEquals(props, other.props));
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(props));
}

sealed class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState({
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  List<Object?> get props => [userId, email];
}

/// Auth evaluation is running (for example right after bootstrap handoff).
final class AuthChecking extends AuthState {
  const AuthChecking();
}

/// No authenticated session is available for app access.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Session exists but email is not verified yet.
final class AuthAuthenticatedUnverified extends AuthAuthenticatedState {
  const AuthAuthenticatedUnverified({
    required this.userId,
    required this.email,
  }) : super(userId: userId, email: email);
}

/// Session and email verification are valid, but onboarding is still required.
final class AuthAuthenticatedOnboardingRequired extends AuthAuthenticatedState {
  const AuthAuthenticatedOnboardingRequired({
    required this.userId,
    required this.email,
  }) : super(userId: userId, email: email);
}

/// User is fully authenticated and onboarding is complete.
final class AuthAuthenticatedReady extends AuthAuthenticatedState {
  const AuthAuthenticatedReady({
    required this.userId,
    required this.email,
  }) : super(userId: userId, email: email);
}

bool _listEquals(List<Object?> left, List<Object?> right) {
  if (left.length != right.length) return false;

  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }

  return true;
}
