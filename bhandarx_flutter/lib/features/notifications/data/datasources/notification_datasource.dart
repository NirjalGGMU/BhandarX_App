import 'package:bhandarx_flutter/features/notifications/data/models/notification_api_model.dart';

abstract interface class INotificationRemoteDatasource {
  Future<List<NotificationApiModel>> getNotifications({bool? isRead});
  Future<NotificationApiModel> markAsRead(String id);
  Future<bool> markAllAsRead();
}
