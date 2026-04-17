import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/app.dart';
import 'package:truffly_app/core/config/auth_redirects.dart';
import 'package:truffly_app/core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.local');
  Env.validate();
  AuthRedirects.validateConfiguration();
  Stripe.publishableKey = Env.stripePublishableKey;
  Stripe.merchantIdentifier = Env.stripeMerchantIdentifier;
  Stripe.urlScheme = 'truffly';
  await Stripe.instance.applySettings();
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );
  runApp(const ProviderScope(child: TrufflyApp()));
}
