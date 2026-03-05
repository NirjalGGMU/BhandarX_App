import 'package:bhandarx_flutter/features/notifications/domain/entities/notification_entity.dart';

enum NotificationFilter { all, unread, read }

class NotificationsState {
  final bool isLoading;
  final List<NotificationEntity> items;
  final NotificationFilter filter;
  final String? error;

  const NotificationsState({
    this.isLoading = false,
    this.items = const [],
    this.filter = NotificationFilter.all,
    this.error,
  });

  NotificationsState copyWith({
    bool? isLoading,
    List<NotificationEntity>? items,
    NotificationFilter? filter,
    String? error,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      filter: filter ?? this.filter,
      error: error,
    );
  }
}
