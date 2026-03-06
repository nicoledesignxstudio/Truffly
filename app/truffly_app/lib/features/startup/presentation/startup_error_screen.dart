import 'package:flutter/material.dart';
import 'package:truffly_app/core/bootstrap/domain/bootstrap_failure.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.failure,
    required this.onRetry,
  });

  final BootstrapFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 36),
              const SizedBox(height: 12),
              Text(
                _messageForFailure(failure),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _messageForFailure(BootstrapFailure failure) {
    return switch (failure) {
      BackendUnavailableFailure() =>
        'Backend unavailable. Please check your connection and try again.',
      NetworkTimeoutFailure() =>
        'Connection timeout. Please retry.',
      NetworkFailure() =>
        'Network error. Please check your internet connection and retry.',
      ConfigFailure() =>
        'App configuration error. Verify environment setup.',
      InvalidSessionFailure() =>
        'Session is invalid. Please sign in again.',
      UnknownBootstrapFailure() =>
        'An unexpected startup error occurred. Please retry.',
    };
  }
}
