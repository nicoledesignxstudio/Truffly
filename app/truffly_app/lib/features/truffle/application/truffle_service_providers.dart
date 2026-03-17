import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truffly_app/core/providers/app_providers.dart';
import 'package:truffly_app/features/truffle/data/favorites_service.dart';
import 'package:truffly_app/features/truffle/data/truffle_service.dart';

final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService(ref.read(supabaseClientProvider));
});

final truffleServiceProvider = Provider<TruffleService>((ref) {
  return TruffleService(ref.read(supabaseClientProvider));
});
