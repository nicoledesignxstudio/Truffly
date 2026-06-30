import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:truffly_app/core/router/app_routes.dart';
import 'package:truffly_app/core/theme/app_colors.dart';
import 'package:truffly_app/core/theme/app_shadows.dart';
import 'package:truffly_app/core/theme/app_spacing.dart';
import 'package:truffly_app/core/theme/app_text_styles.dart';
import 'package:truffly_app/features/auth/presentation/widgets/auth_back_button.dart';
import 'package:truffly_app/features/home/presentation/widgets/home_nav_bar.dart';
import 'package:truffly_app/features/account/application/account_providers.dart';
import 'package:truffly_app/features/notifications/application/notifications_providers.dart';
import 'package:truffly_app/features/notifications/data/notifications_repository.dart';
import 'package:truffly_app/features/notifications/domain/app_notification.dart';
import 'package:truffly_app/features/notifications/presentation/notification_content.dart';
import 'package:truffly_app/features/notifications/presentation/notification_route_resolver.dart';
import 'package:truffly_app/l10n/app_localizations.dart';

class NotificationsInboxPage extends ConsumerWidget {
  const NotificationsInboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final inboxAsync = ref.watch(notificationsInboxProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const HomeNavBar(activeTab: HomeNavTab.account),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leadingWidth: 66,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.spacingM),
          child: AuthBackButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
        ),
        title: Text(
          l10n.notificationsInboxTitle,
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsInboxProvider);
          await ref.read(notificationsInboxProvider.future);
        },
        child: inboxAsync.when(
          loading: () => const _InboxState(
            key: Key('notifications_loading_state'),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _InboxErrorState(
            onRetry: () => ref.invalidate(notificationsInboxProvider),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _InboxEmptyState(message: l10n.notificationsEmptyState);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.spacingM,
                AppSpacing.spacingS,
                AppSpacing.spacingM,
                AppSpacing.spacingL,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _NotificationTile(
                  notification: item,
                  onTap: () => _handleNotificationTap(context, ref, item),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    try {
      if (!notification.isRead) {
        final currentUser = await ref.read(
          currentUserAccountProfileProvider.future,
        );
        final localNotificationsService = ref.read(
          localNotificationsServiceProvider,
        );
        if (localNotificationsService.isLocalNotificationId(notification.id)) {
          await localNotificationsService.markAsRead(
            userId: currentUser.userId,
            notificationId: notification.id,
          );
        } else {
          await ref
              .read(notificationsRepositoryProvider)
              .markAsRead(notification.id);
        }
      }
      ref.invalidate(notificationsInboxProvider);
      String? currentUserId;
      try {
        final currentUser = await ref.read(
          currentUserAccountProfileProvider.future,
        );
        currentUserId = currentUser.userId;
      } catch (_) {
        currentUserId = null;
      }
      if (!context.mounted) return;
      final route = resolveNotificationRoute(
        notification,
        currentUserId: currentUserId,
      );
      context.push(route ?? AppRoutes.notifications);
    } on NotificationsRepositoryException {
      ref.invalidate(notificationsInboxProvider);
    } catch (_) {
      ref.invalidate(notificationsInboxProvider);
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final relativeTime = _relativeTimeLabel(context, notification.createdAt);
    final content = localizedNotificationContent(context, notification);

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFFFF8F4) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.black10),
            boxShadow: AppShadows.authField,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _NotificationAvatar(icon: content.icon, isUnread: isUnread),
                const SizedBox(width: AppSpacing.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  content.title,
                                  maxLines: 2,
                                  softWrap: true,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  content.message,
                                  softWrap: true,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.black80,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacingS),
                          Text(
                            relativeTime,
                            style: AppTextStyles.micro.copyWith(
                              color: AppColors.black50,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _relativeTimeLabel(BuildContext context, DateTime createdAt) {
    final now = DateTime.now();
    final local = createdAt.toLocal();
    final diff = now.difference(local);

    if (diff.inDays == 0) {
      final hours = diff.inHours.clamp(0, 23);
      if (hours <= 0) {
        final minutes = diff.inMinutes.clamp(0, 59);
        return '${minutes}m';
      }
      return '${hours}h';
    }

    if (now.year == local.year && now.month == local.month) {
      return '${diff.inDays}d';
    }

    return MaterialLocalizations.of(context).formatMediumDate(local);
  }
}

class _NotificationAvatar extends StatelessWidget {
  const _NotificationAvatar({required this.icon, required this.isUnread});

  final IconData icon;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFE9DD) : AppColors.softGrey,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUnread
              ? AppColors.accent.withValues(alpha: 0.18)
              : AppColors.black10,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: isUnread ? AppColors.accent : AppColors.black80,
        ),
      ),
    );
  }
}

class _InboxEmptyState extends StatelessWidget {
  const _InboxEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
      ),
    );
  }
}

class _InboxErrorState extends StatelessWidget {
  const _InboxErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.notificationsErrorState,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.spacingM),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.notificationsRetryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxState extends StatelessWidget {
  const _InboxState({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
