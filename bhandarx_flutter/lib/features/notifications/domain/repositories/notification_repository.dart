import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/features/notifications/domain/entities/notification_entity.dart';
import 'package:dartz/dartz.dart';

abstract interface class INotificationRepository {
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
      {bool? isRead});
  Future<Either<Failure, NotificationEntity>> markAsRead(String id);
  Future<Either<Failure, bool>> markAllAsRead();
}
