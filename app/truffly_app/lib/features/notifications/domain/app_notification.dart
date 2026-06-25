final class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.targetRoute,
    required this.targetId,
    required this.metadata,
  });

  final String id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? targetRoute;
  final String? targetId;
  final Map<String, Object?> metadata;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      targetRoute: targetRoute,
      targetId: targetId,
      metadata: metadata,
    );
  }
}
