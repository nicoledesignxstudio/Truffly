import 'package:truffly_app/core/bootstrap/domain/bootstrap_failure.dart';

sealed class BootstrapState {
  const BootstrapState();
}

class BootstrapInitial extends BootstrapState {
  const BootstrapInitial();
}

class BootstrapLoading extends BootstrapState {
  const BootstrapLoading();
}

class BootstrapAuthenticated extends BootstrapState {
  const BootstrapAuthenticated();
}

class BootstrapUnauthenticated extends BootstrapState {
  const BootstrapUnauthenticated();
}

class BootstrapError extends BootstrapState {
  const BootstrapError(this.failure);

  final BootstrapFailure failure;
}
