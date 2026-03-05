import 'package:bhandarx_flutter/features/notifications/domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String priority;
  final bool isRead;
  final DateTime createdAt;

  NotificationApiModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: (json['_id'] ?? '').toString(),
      type: (json['type'] ?? 'CUSTOM').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? '').toString(),
      priority: (json['priority'] ?? 'MEDIUM').toString(),
      isRead: (json['isRead'] ?? false) as bool,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      type: type,
      title: title,
      message: message,
      priority: priority,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}
