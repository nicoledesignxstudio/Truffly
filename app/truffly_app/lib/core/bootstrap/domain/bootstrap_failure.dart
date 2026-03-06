sealed class BootstrapFailure {
  const BootstrapFailure();
}

class BackendUnavailableFailure extends BootstrapFailure {
  const BackendUnavailableFailure();
}

class NetworkTimeoutFailure extends BootstrapFailure {
  const NetworkTimeoutFailure();
}

class NetworkFailure extends BootstrapFailure {
  const NetworkFailure();
}

class ConfigFailure extends BootstrapFailure {
  const ConfigFailure();
}

class InvalidSessionFailure extends BootstrapFailure {
  const InvalidSessionFailure();
}

class UnknownBootstrapFailure extends BootstrapFailure {
  const UnknownBootstrapFailure();
}
