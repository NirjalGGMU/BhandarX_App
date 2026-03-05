import 'package:bhandarx_flutter/features/notifications/data/repositories/notification_repository.dart';
import 'package:bhandarx_flutter/features/notifications/presentation/state/notifications_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsViewModelProvider =
    NotifierProvider<NotificationsViewModel, NotificationsState>(
  NotificationsViewModel.new,
);

class NotificationsViewModel extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    return const NotificationsState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final isRead = switch (state.filter) {
      NotificationFilter.read => true,
      NotificationFilter.unread => false,
      NotificationFilter.all => null,
    };

    final result = await ref
        .read(notificationRepositoryProvider)
        .getNotifications(isRead: isRead);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (items) =>
          state = state.copyWith(isLoading: false, items: items, error: null),
    );
  }

  Future<void> setFilter(NotificationFilter filter) async {
    state = state.copyWith(filter: filter);
    await load();
  }

  Future<void> markAsRead(String id) async {
    final result =
        await ref.read(notificationRepositoryProvider).markAsRead(id);
    result.fold(
      (_) {},
      (_) {
        state = state.copyWith(
          items: [
            for (final item in state.items)
              if (item.id == id) item.copyWith(isRead: true) else item,
          ],
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result =
        await ref.read(notificationRepositoryProvider).markAllAsRead();
    result.fold(
      (_) {},
      (_) {
        state = state.copyWith(
          items: state.items.map((e) => e.copyWith(isRead: true)).toList(),
        );
      },
    );
  }
}
