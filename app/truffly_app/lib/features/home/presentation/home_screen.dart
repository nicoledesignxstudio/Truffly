import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/auth/application/auth_notifier.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _isSigningOut ? null : _handleSignOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home placeholder'),
            const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isSigningOut
                    ? null
                    : () => context.go(AppRoutes.truffles),
                icon: const Icon(Icons.grid_view_rounded),
                label: const Text('Open truffles'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isSigningOut ? null : _handleSignOut,
                icon: _isSigningOut
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    if (_isSigningOut) return;

    setState(() {
      _isSigningOut = true;
    });

    await ref.read(authNotifierProvider.notifier).signOut();
    if (!mounted) return;

    setState(() {
      _isSigningOut = false;
    });
  }
}
