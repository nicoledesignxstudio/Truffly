import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

enum FavoritesFailure {
  network,
  unknown,
}

final class FavoritesServiceException implements Exception {
  const FavoritesServiceException(this.failure);

  final FavoritesFailure failure;
}

final class FavoritesService {
  FavoritesService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  Future<Set<String>> fetchFavoriteIds() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return const {};

      final rows = await _supabaseClient
          .from('favorites')
          .select('truffle_id')
          .eq('user_id', user.id) as List<dynamic>;

      return rows
          .cast<Map<String, dynamic>>()
          .map((row) => row['truffle_id'] as String)
          .toSet();
    } on SocketException {
      throw const FavoritesServiceException(FavoritesFailure.network);
    } catch (_) {
      throw const FavoritesServiceException(FavoritesFailure.unknown);
    }
  }

  Future<void> addFavorite(String truffleId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const FavoritesServiceException(FavoritesFailure.unknown);
    }

    try {
      await _supabaseClient.from('favorites').insert({
        'user_id': user.id,
        'truffle_id': truffleId,
      });
    } on SocketException {
      throw const FavoritesServiceException(FavoritesFailure.network);
    } catch (_) {
      throw const FavoritesServiceException(FavoritesFailure.unknown);
    }
  }

  Future<void> removeFavorite(String truffleId) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const FavoritesServiceException(FavoritesFailure.unknown);
    }

    try {
      await _supabaseClient
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('truffle_id', truffleId);
    } on SocketException {
      throw const FavoritesServiceException(FavoritesFailure.network);
    } catch (_) {
      throw const FavoritesServiceException(FavoritesFailure.unknown);
    }
  }
}
