import 'package:bhandarx_flutter/core/api/api_client.dart';
import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
import 'package:bhandarx_flutter/features/notifications/data/datasources/notification_datasource.dart';
import 'package:bhandarx_flutter/features/notifications/data/models/notification_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRemoteDatasourceProvider =
    Provider<INotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class NotificationRemoteDatasource implements INotificationRemoteDatasource {
  NotificationRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<NotificationApiModel>> getNotifications({bool? isRead}) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.notifications,
      queryParameters: {
        if (isRead != null) 'isRead': isRead,
        'pageSize': 50,
      },
    );

    final list = response.data['data'] as List<dynamic>? ?? <dynamic>[];
    return list
        .whereType<Map<String, dynamic>>()
        .map(NotificationApiModel.fromJson)
        .toList();
  }

  @override
  Future<NotificationApiModel> markAsRead(String id) async {
    final response =
        await _apiClient.dio.patch(ApiEndpoints.markNotificationRead(id));
    return NotificationApiModel.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<bool> markAllAsRead() async {
    await _apiClient.dio.patch(ApiEndpoints.markAllNotificationsRead);
    return true;
  }
}
