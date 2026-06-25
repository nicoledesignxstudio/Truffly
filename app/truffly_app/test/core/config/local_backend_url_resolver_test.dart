import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truffly_app/core/config/local_backend_url_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('maps Android loopback URLs to the emulator alias by default', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      LocalBackendUrlResolver.normalize(
        'http://127.0.0.1:54321/auth/v1/health',
      ),
      'http://10.0.2.2:54321/auth/v1/health',
    );
  });

  test('uses the configured Android device host override when provided', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      LocalBackendUrlResolver.normalize(
        'http://10.0.2.2:54321/storage/v1/object/sign/truffle_images/demo.jpg',
        androidHostOverride: '192.168.1.44',
      ),
      'http://192.168.1.44:54321/storage/v1/object/sign/truffle_images/demo.jpg',
    );
  });

  test('keeps non-local URLs unchanged on Android', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(
      LocalBackendUrlResolver.normalize(
        'https://abccompany.supabase.co/auth/v1/health',
      ),
      'https://abccompany.supabase.co/auth/v1/health',
    );
  });
}
