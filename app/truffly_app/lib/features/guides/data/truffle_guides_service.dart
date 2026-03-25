import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/guides/domain/truffle_guide.dart';
import 'package:truffly_app/features/truffle/domain/truffle_type.dart';

enum TruffleGuidesFailure { network, unauthorized, notFound, unknown }

final class TruffleGuidesException implements Exception {
  const TruffleGuidesException(this.failure);

  final TruffleGuidesFailure failure;
}

final class TruffleGuidesService {
  const TruffleGuidesService(this._supabaseClient);

  final SupabaseClient _supabaseClient;

  static const _selectColumns =
      'id, truffle_type, latin_name, title_it, title_en, '
      'short_description_it, short_description_en, description_it, description_en, '
      'aroma_it, aroma_en, price_min_eur, price_max_eur, rarity, '
      'symbiotic_plants_it, symbiotic_plants_en, '
      'soil_composition_it, soil_composition_en, '
      'soil_structure_it, soil_structure_en, '
      'soil_ph_it, soil_ph_en, '
      'soil_altitude_it, soil_altitude_en, '
      'soil_humidity_it, soil_humidity_en, '
      'harvest_start_month, harvest_end_month, '
      'is_published, sort_order';

  Future<List<TruffleGuide>> fetchPublishedGuides() async {
    try {
      final rows = await _supabaseClient
          .from('truffle_guides')
          .select(_selectColumns)
          .eq('is_published', true)
          .order('sort_order', ascending: true) as List<dynamic>;

      return rows
          .cast<Map<String, dynamic>>()
          .map(TruffleGuide.fromMap)
          .toList(growable: false);
    } on SocketException {
      throw const TruffleGuidesException(TruffleGuidesFailure.network);
    } on PostgrestException catch (error) {
      throw TruffleGuidesException(_mapPostgrestFailure(error));
    } catch (_) {
      throw const TruffleGuidesException(TruffleGuidesFailure.unknown);
    }
  }

  Future<TruffleGuide> fetchPublishedGuideByType(TruffleType truffleType) async {
    try {
      final row = await _supabaseClient
          .from('truffle_guides')
          .select(_selectColumns)
          .eq('is_published', true)
          .eq('truffle_type', truffleType.dbValue)
          .maybeSingle();

      if (row is! Map<String, dynamic>) {
        throw const TruffleGuidesException(TruffleGuidesFailure.notFound);
      }

      return TruffleGuide.fromMap(row);
    } on SocketException {
      throw const TruffleGuidesException(TruffleGuidesFailure.network);
    } on PostgrestException catch (error) {
      throw TruffleGuidesException(_mapPostgrestFailure(error));
    } on TruffleGuidesException {
      rethrow;
    } catch (_) {
      throw const TruffleGuidesException(TruffleGuidesFailure.unknown);
    }
  }

  TruffleGuidesFailure _mapPostgrestFailure(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (error.code == '42501' || message.contains('not allowed')) {
      return TruffleGuidesFailure.unauthorized;
    }
    if (message.contains('fetch') || message.contains('socket')) {
      return TruffleGuidesFailure.network;
    }
    return TruffleGuidesFailure.unknown;
  }
}