import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/core/config/auth_callback_context.dart';
import 'package:truffly_app/core/config/incoming_app_link.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';
import 'package:truffly_app/l10n/app_localizations.dart';
import 'package:truffly_app/core/router/app_router.dart';
import 'package:truffly_app/core/theme/app_theme.dart';
import 'package:truffly_app/features/push/application/push_notifications_coordinator.dart';

class TrufflyApp extends ConsumerStatefulWidget {
  const TrufflyApp({super.key});

  @override
  ConsumerState<TrufflyApp> createState() => _TrufflyAppState();
}

class _TrufflyAppState extends ConsumerState<TrufflyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _appLinkSub;
  String? _lastHandledLink;

  @override
  void initState() {
    super.initState();
    _listenForIncomingLinks();
  }

  @override
  void dispose() {
    unawaited(_appLinkSub?.cancel());
    super.dispose();
  }

  void _listenForIncomingLinks() {
    _appLinkSub = _appLinks.uriLinkStream.listen((uri) {
      unawaited(_handleIncomingUri(uri));
    });

    Future.microtask(() async {
      final initialUri = await _appLinks.getInitialLink();
      if (!mounted || initialUri == null) return;
      await _handleIncomingUri(initialUri);
    });
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    final rawLink = uri.toString();
    if (_lastHandledLink == rawLink) return;

    final normalizedUri = normalizeIncomingAppLink(uri);
    if (normalizedUri == null || !mounted) return;

    _lastHandledLink = rawLink;

    final callbackContext = AuthCallbackContext.fromUri(normalizedUri);
    final supabase = ref.read(supabaseClientProvider);

    if (callbackContext.hasSessionMaterial ||
        callbackContext.hasCallbackError) {
      try {
        await supabase.auth.getSessionFromUrl(uri);
      } on AuthException catch (error, stackTrace) {
        debugPrint(
          '[TrufflyApp] Auth callback handling failed: ${error.message}',
        );
        debugPrint('$stackTrace');
      } catch (error, stackTrace) {
        debugPrint('[TrufflyApp] Incoming auth link failed: $error');
        debugPrint('$stackTrace');
      }
    }

    if (callbackContext.type == 'recovery') {
      ref.read(passwordRecoveryFlowProvider.notifier).activate();
    }

    final destinationUri = callbackContext.type == 'email_change'
        ? _emailChangeDestinationUri(normalizedUri, supabase.auth.currentUser)
        : normalizedUri;

    final router = ref.read(appRouterProvider);
    router.go(destinationUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);
    ref.watch(pushNotificationsCoordinatorProvider);

    return MaterialApp.router(
      title: 'Truffly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}

Uri _emailChangeDestinationUri(Uri uri, User? user) {
  final pendingEmail = user?.newEmail?.trim();
  final currentEmail = user?.email?.trim();
  final expectedEmail = pendingEmail?.isNotEmpty == true
      ? pendingEmail
      : currentEmail;

  return uri.replace(
    queryParameters: {
      ...uri.queryParameters,
      'source': 'email_change',
      if (expectedEmail?.isNotEmpty == true) 'email': expectedEmail!,
    },
  );
}
