import 'package:supabase_flutter/supabase_flutter.dart';

final class SellerDashboardSummary {
  const SellerDashboardSummary({
    required this.completedEarnings,
    required this.pendingEarnings,
    required this.completedOrdersCount,
    required this.inProgressOrdersCount,
    required this.activeTrufflesCount,
    required this.averageRating,
    required this.reviewCount,
  });

  final double completedEarnings;
  final double pendingEarnings;
  final int completedOrdersCount;
  final int inProgressOrdersCount;
  final int activeTrufflesCount;
  final double averageRating;
  final int reviewCount;
}

class SellerDashboardService {
  SellerDashboardService(this._client);

  final SupabaseClient _client;

  Future<SellerDashboardSummary> getCurrentSellerDashboardSummary() async {
    final response = await _client.rpc('get_current_seller_dashboard_summary');
    final data = _asMap(response);

    return SellerDashboardSummary(
      completedEarnings: (data['completed_earnings'] as num?)?.toDouble() ?? 0,
      pendingEarnings: (data['pending_earnings'] as num?)?.toDouble() ?? 0,
      completedOrdersCount: (data['completed_orders_count'] as num?)?.toInt() ?? 0,
      inProgressOrdersCount: (data['in_progress_orders_count'] as num?)?.toInt() ?? 0,
      activeTrufflesCount: (data['active_truffles_count'] as num?)?.toInt() ?? 0,
      averageRating: (data['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['review_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> _asMap(Object? response) {
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response is List && response.isNotEmpty) {
      final first = response.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }

    throw const FormatException('Unexpected seller dashboard RPC response.');
  }
}
