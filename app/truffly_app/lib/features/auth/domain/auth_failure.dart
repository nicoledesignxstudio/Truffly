sealed class AuthFailure {
  const AuthFailure();

  List<Object?> get props => const [];

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AuthFailure &&
            _listEquals(props, other.props));
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(props));
}

final class EmailAlreadyUsedFailure extends AuthFailure {
  const EmailAlreadyUsedFailure();
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure();
}

final class UnauthenticatedFailure extends AuthFailure {
  const UnauthenticatedFailure();
}

final class EmailNotVerifiedFailure extends AuthFailure {
  const EmailNotVerifiedFailure();
}

final class NetworkErrorFailure extends AuthFailure {
  const NetworkErrorFailure();
}

final class TimeoutFailure extends AuthFailure {
  const TimeoutFailure();
}

final class ResetLinkInvalidFailure extends AuthFailure {
  const ResetLinkInvalidFailure();
}

final class UserProfileMissingFailure extends AuthFailure {
  const UserProfileMissingFailure();
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure();
}

bool _listEquals(List<Object?> left, List<Object?> right) {
  if (left.length != right.length) return false;

  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }

  return true;
}
