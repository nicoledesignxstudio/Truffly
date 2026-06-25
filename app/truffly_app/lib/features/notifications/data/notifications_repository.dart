import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';

final class NotificationsRepositoryException implements Exception {
  const NotificationsRepositoryException(this.code, this.message);

  final String code;
  final String message;
}

class NotificationsRepository {
  NotificationsRepository(this._supabaseClient);

  final dynamic _supabaseClient;

  Future<List<AppNotification>> fetchCurrentUserNotifications() async {
    try {
      final rows =
          await _supabaseClient
                  .from('notifications')
                  .select(
                    'id, type, message, read, created_at, target_route, target_id, metadata',
                  )
                  .order('created_at', ascending: false)
              as List<dynamic>;

      return [
        for (final row in rows.cast<Map<String, dynamic>>())
          _mapNotification(row),
      ];
    } on PostgrestException catch (error) {
      throw NotificationsRepositoryException(
        error.code ?? 'notifications_fetch_failed',
        error.message,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[NotificationsRepository] fetch failed: $error');
      }
      throw const NotificationsRepositoryException(
        'notifications_fetch_failed',
        'Unable to load notifications.',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _updateNotification(notificationId, {'read': true});
  }

  Future<void> markAllAsRead() async {
    await _supabaseClient
        .from('notifications')
        .update({'read': true})
        .eq('read', false);
  }

  AppNotification _mapNotification(Map<String, dynamic> row) {
    return AppNotification(
      id: row['id'] as String,
      type: (row['type'] as String? ?? 'generic').trim(),
      message: (row['message'] as String? ?? '').trim(),
      isRead: row['read'] == true,
      createdAt: DateTime.parse(row['created_at'] as String),
      targetRoute: _nullableTrimmedString(row['target_route']),
      targetId: _nullableTrimmedString(row['target_id']),
      metadata: _metadataMap(row['metadata']),
    );
  }

  Future<void> _updateNotification(
    String notificationId,
    Map<String, dynamic> values,
  ) async {
    await _supabaseClient
        .from('notifications')
        .update(values)
        .eq('id', notificationId);
  }

  String? _nullableTrimmedString(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Map<String, Object?> _metadataMap(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries) entry.key.toString(): entry.value,
      };
    }
    return const {};
  }
}
