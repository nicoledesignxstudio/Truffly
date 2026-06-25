import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/app.dart';
import 'package:truffly_app/core/config/auth_redirects.dart';
import 'package:truffly_app/core/config/env.dart';
import 'package:truffly_app/core/config/runtime_config.dart';
import 'package:truffly_app/features/push/data/fcm_debug_setup_service.dart';
import 'package:truffly_app/firebase_options.dart';

FcmDebugSetupService? _fcmDebugSetupService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  AuthRedirects.validateConfiguration();
  Stripe.publishableKey = RuntimeConfig.stripePublishableKey;
  // Apple Pay is only prewired for now. A real rollout will still require:
  // Apple Developer Account, a real Apple Merchant ID, Xcode signing/capabilities,
  // and validation on a physical iOS device.
  Stripe.merchantIdentifier = RuntimeConfig.stripeAppleMerchantIdentifier;
  Stripe.urlScheme = 'truffly';
  await Stripe.instance.applySettings();
  try {
    debugPrint('Firebase initialization started');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialization successful');
    _fcmDebugSetupService = FcmDebugSetupService(FirebaseMessaging.instance);
    await _fcmDebugSetupService!.setup();
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed');
    debugPrint('$error');
    debugPrint('$stackTrace');
    // Firebase is optional at startup so the app can still open in
    // environments where the native config has not been provisioned yet.
  }
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
      detectSessionInUri: false,
    ),
  );
  runApp(const ProviderScope(child: TrufflyApp()));
}
