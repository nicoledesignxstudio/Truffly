import 'dart:io';
import 'dart:async';

import 'package:truffly_app/core/config/env.dart';

enum BackendHealthIssue {
  backendUnavailable,
  timeout,
  network,
  config,
  unknown,
}

sealed class BackendHealthResult {
  const BackendHealthResult();
}

class BackendHealthy extends BackendHealthResult {
  const BackendHealthy();
}

class BackendUnhealthy extends BackendHealthResult {
  const BackendUnhealthy(this.issue);

  final BackendHealthIssue issue;
}

class BackendHealthService {
  Future<BackendHealthResult> checkHealth() async {
    final healthUri = Uri.tryParse('${Env.supabaseUrl}/auth/v1/health');
    if (healthUri == null || healthUri.host.isEmpty) {
      return const BackendUnhealthy(BackendHealthIssue.config);
    }

    final client = HttpClient();

    try {
      final request =
          await client.getUrl(healthUri).timeout(const Duration(seconds: 6));
      request.headers.set('apikey', Env.supabaseAnonKey);
      final response =
          await request.close().timeout(const Duration(seconds: 6));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const BackendHealthy();
      }
      return const BackendUnhealthy(BackendHealthIssue.backendUnavailable);
    } on TimeoutException {
      return const BackendUnhealthy(BackendHealthIssue.timeout);
    } on SocketException {
      return const BackendUnhealthy(BackendHealthIssue.network);
    } on HttpException {
      return const BackendUnhealthy(BackendHealthIssue.network);
    } on StateError {
      return const BackendUnhealthy(BackendHealthIssue.config);
    } catch (_) {
      return const BackendUnhealthy(BackendHealthIssue.unknown);
    } finally {
      client.close(force: true);
    }
  }
}
