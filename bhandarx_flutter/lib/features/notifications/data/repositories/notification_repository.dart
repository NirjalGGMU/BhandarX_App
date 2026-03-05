import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/core/services/connectivity/network_info.dart';
import 'package:bhandarx_flutter/features/notifications/data/datasources/notification_datasource.dart';
import 'package:bhandarx_flutter/features/notifications/data/datasources/remote/notification_remote_datasource.dart';
import 'package:bhandarx_flutter/features/notifications/domain/entities/notification_entity.dart';
import 'package:bhandarx_flutter/features/notifications/domain/repositories/notification_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(
    remoteDatasource: ref.read(notificationRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepository implements INotificationRepository {
  NotificationRepository({
    required INotificationRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  final INotificationRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> getNotifications(
      {bool? isRead}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }
    try {
      final items = await _remoteDatasource.getNotifications(isRead: isRead);
      return Right(items.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(
          ApiFailure(message: e.message ?? 'Failed to load notifications'));
    } catch (_) {
      return const Left(ApiFailure(message: 'Failed to load notifications'));
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markAsRead(String id) async {
    try {
      final item = await _remoteDatasource.markAsRead(id);
      return Right(item.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(message: e.message ?? 'Failed to mark as read'));
    } catch (_) {
      return const Left(ApiFailure(message: 'Failed to mark as read'));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      await _remoteDatasource.markAllAsRead();
      return const Right(true);
    } on DioException catch (e) {
      return Left(
          ApiFailure(message: e.message ?? 'Failed to mark all as read'));
    } catch (_) {
      return const Left(ApiFailure(message: 'Failed to mark all as read'));
    }
  }
}
