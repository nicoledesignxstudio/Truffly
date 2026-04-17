import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/l10n/app_localizations.dart';
import 'package:truffly_app/core/router/app_router.dart';
import 'package:truffly_app/core/theme/app_theme.dart';

class TrufflyApp extends ConsumerWidget {
  const TrufflyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

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
