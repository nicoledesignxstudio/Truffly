import 'package:shared_preferences/shared_preferences.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';

class LocalNotificationsService {
  static const _buyerWelcomeType = 'buyer_welcome';
  static const _buyerWelcomeShownPrefix =
      'local_notification_buyer_welcome_shown';
  static const _buyerWelcomeReadPrefix =
      'local_notification_buyer_welcome_read';
  static const _buyerWelcomeCreatedAtPrefix =
      'local_notification_buyer_welcome_created_at';

  Future<bool> ensureBuyerWelcomeNotification({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final shownKey = _shownKey(userId);
    if (prefs.getBool(shownKey) == true) {
      return false;
    }

    await prefs.setBool(shownKey, true);
    await prefs.setBool(_readKey(userId), false);
    await prefs.setString(
      _createdAtKey(userId),
      DateTime.now().toUtc().toIso8601String(),
    );
    return true;
  }

  Future<List<AppNotification>> fetchCurrentUserLocalNotifications({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_shownKey(userId)) != true) {
      return const [];
    }

    final createdAtRaw = prefs.getString(_createdAtKey(userId));
    final createdAt = createdAtRaw == null
        ? DateTime.now().toUtc()
        : DateTime.tryParse(createdAtRaw)?.toUtc() ?? DateTime.now().toUtc();

    return [
      AppNotification(
        id: _notificationId(userId),
        type: _buyerWelcomeType,
        message: '',
        isRead: prefs.getBool(_readKey(userId)) == true,
        createdAt: createdAt,
        targetRoute: AppRoutes.truffles,
        targetId: null,
        metadata: const {},
      ),
    ];
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    if (notificationId != _notificationId(userId)) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_readKey(userId), true);
  }

  bool isLocalNotificationId(String notificationId) {
    return notificationId.startsWith('local_buyer_welcome_');
  }

  String _notificationId(String userId) => 'local_buyer_welcome_$userId';

  String _shownKey(String userId) => '$_buyerWelcomeShownPrefix.$userId';
  String _readKey(String userId) => '$_buyerWelcomeReadPrefix.$userId';
  String _createdAtKey(String userId) =>
      '$_buyerWelcomeCreatedAtPrefix.$userId';
}
