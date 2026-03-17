import 'package:truffly_app/features/auth/domain/auth_failure.dart';

sealed class AuthResult<T> {
  const AuthResult();

  bool get isSuccess => this is AuthSuccess<T>;

  bool get isFailure => this is AuthFailureResult<T>;

  T? get dataOrNull {
    final result = this;
    return switch (result) {
      AuthSuccess<T>(:final data) => data,
      AuthFailureResult<T>() => null,
    };
  }

  AuthFailure? get failureOrNull {
    final result = this;
    return switch (result) {
      AuthSuccess<T>() => null,
      AuthFailureResult<T>(:final failure) => failure,
    };
  }
}

final class AuthSuccess<T> extends AuthResult<T> {
  const AuthSuccess(this.data);

  final T data;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthSuccess<T> && other.data == data);
  }

  @override
  int get hashCode => Object.hash(runtimeType, data);
}

final class AuthFailureResult<T> extends AuthResult<T> {
  const AuthFailureResult(this.failure);

  final AuthFailure failure;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthFailureResult<T> && other.failure == failure);
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);
}

final class AuthUnit {
  const AuthUnit._();

  static const value = AuthUnit._();
}

final class AuthSignupSuccess {
  const AuthSignupSuccess({
    required this.email,
    this.verificationRequired = true,
    this.sessionEstablished = false,
  });

  final String email;
  final bool verificationRequired;
  final bool sessionEstablished;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AuthSignupSuccess &&
            other.email == email &&
            other.verificationRequired == verificationRequired &&
            other.sessionEstablished == sessionEstablished);
  }

  @override
  int get hashCode =>
      Object.hash(email, verificationRequired, sessionEstablished);
}
