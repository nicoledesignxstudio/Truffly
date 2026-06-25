import 'package:flutter/foundation.dart';
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
              Text(_messageForFailure(failure), textAlign: TextAlign.center),
              if (kDebugMode && _devHintForFailure(failure) != null) ...[
                const SizedBox(height: 8),
                Text(
                  _devHintForFailure(failure)!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
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

  String? _devHintForFailure(BootstrapFailure failure) {
    return switch (failure) {
      BackendUnavailableFailure() ||
      NetworkTimeoutFailure() ||
      NetworkFailure() =>
        'Dev hint: with local Supabase on a real Android device, run adb reverse tcp:54321 tcp:54321 or set ANDROID_DEVICE_HOST to your computer LAN IP.',
      _ => null,
    };
  }
}
