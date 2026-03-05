import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/env.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  bool _isLoading = false;
  String? _result;

  SupabaseClient get _client => Supabase.instance.client;

  String get _sessionStatus =>
      _client.auth.currentSession == null ? 'none' : 'active';

  String get _maskedSupabaseUrl {
    final uri = Uri.tryParse(Env.supabaseUrl);
    if (uri == null || uri.host.isEmpty) {
      return 'invalid URL';
    }
    final hasPort = uri.hasPort;
    return hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      // Network-level health check on GoTrue endpoint, independent from DB RLS.
      final healthUri = Uri.parse('${Env.supabaseUrl}/auth/v1/health');
      final client = HttpClient();

      try {
        final request = await client
            .getUrl(healthUri)
            .timeout(const Duration(seconds: 6));
        request.headers.set('apikey', Env.supabaseAnonKey);
        final response =
            await request.close().timeout(const Duration(seconds: 6));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          setState(() {
            _result = '\u2705 Connected';
          });
        } else {
          setState(() {
            _result =
                '\u274c Error: health endpoint returned ${response.statusCode}';
          });
        }
      } finally {
        client.close(force: true);
      }
    } catch (error) {
      setState(() {
        _result = '\u274c Error: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truffly \u2014 Health')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supabase: $_maskedSupabaseUrl'),
            const SizedBox(height: 8),
            Text('Session: $_sessionStatus'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: const Text('Test connection'),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading) const CircularProgressIndicator(),
            if (_result != null) ...[
              const SizedBox(height: 12),
              Text(_result!),
            ],
          ],
        ),
      ),
    );
  }
}
