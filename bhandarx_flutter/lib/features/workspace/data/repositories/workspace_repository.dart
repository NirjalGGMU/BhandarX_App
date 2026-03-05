import 'dart:math';

import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/core/services/connectivity/network_info.dart';
import 'package:bhandarx_flutter/core/services/offline/offline_queue_service.dart';
import 'package:bhandarx_flutter/features/workspace/data/datasources/workspace_datasource.dart';
import 'package:bhandarx_flutter/features/workspace/data/datasources/remote/workspace_remote_datasource.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:bhandarx_flutter/features/workspace/domain/repositories/workspace_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workspaceRepositoryProvider = Provider<IWorkspaceRepository>((ref) {
  return WorkspaceRepository(
    remote: ref.read(workspaceRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
    offlineQueueService: ref.read(offlineQueueServiceProvider),
  );
});

class WorkspaceRepository implements IWorkspaceRepository {
  WorkspaceRepository({
    required IWorkspaceRemoteDatasource remote,
    required NetworkInfo networkInfo,
    required OfflineQueueService offlineQueueService,
  })  : _remote = remote,
        _networkInfo = networkInfo,
        _offlineQueueService = offlineQueueService;

  final IWorkspaceRemoteDatasource _remote;
  final NetworkInfo _networkInfo;
  final OfflineQueueService _offlineQueueService;

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getProducts(
          {String? search}) =>
      _guardList(() => _remote.getProducts(search: search));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getLowStockProducts() =>
      _guardList(_remote.getLowStockProducts);

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getOutOfStockProducts() =>
      _guardList(_remote.getOutOfStockProducts);

  @override
  Future<Either<Failure, WorkspaceRecord>> getProductBySku(String sku) =>
      _guardOne(() => _remote.getProductBySku(sku));

  @override
  Future<Either<Failure, WorkspaceSummary>> getInventorySummary() =>
      _guardSummary(_remote.getInventorySummary);

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getCategories() =>
      _guardList(_remote.getCategories);

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getRootCategories() =>
      _guardList(_remote.getRootCategories);

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getSubcategories(
          String categoryId) =>
      _guardList(() => _remote.getSubcategories(categoryId));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getSuppliers(
          {String? search}) =>
      _guardList(() => _remote.getSuppliers(search: search));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getCustomers(
          {String? search}) =>
      _guardList(() => _remote.getCustomers(search: search));

  @override
  Future<Either<Failure, WorkspaceRecord>> getCustomerById(String id) =>
      _guardOne(() => _remote.getCustomerById(id));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getSales({String? search}) =>
      _guardList(() => _remote.getSales(search: search));

  @override
  Future<Either<Failure, WorkspaceRecord>> getSaleById(String id) =>
      _guardOne(() => _remote.getSaleById(id));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getPurchases() =>
      _guardList(_remote.getPurchases);

  @override
  Future<Either<Failure, WorkspaceRecord>> getPurchaseById(String id) =>
      _guardOne(() => _remote.getPurchaseById(id));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getTransactions(
          {String? search}) =>
      _guardList(() => _remote.getTransactions(search: search));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getRecentTransactions() =>
      _guardList(_remote.getRecentTransactions);

  @override
  Future<Either<Failure, WorkspaceSummary>> getTransactionSummary() =>
      _guardSummary(_remote.getTransactionSummary);

  @override
  Future<Either<Failure, WorkspaceSummary>> getDashboardSummary() =>
      _guardSummary(_remote.getDashboardSummary);

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getSalesTopProducts() =>
      _guardList(_remote.getSalesTopProducts);

  @override
  Future<Either<Failure, bool>> createCustomer(CustomerPayload payload) async {
    if (!await _networkInfo.isConnected) {
      await _enqueue(
        type: 'create_customer',
        payload: payload.toJson(),
      );
      return const Right(true);
    }
    try {
      await _remote.createCustomer(payload);
      return const Right(true);
    } on DioException catch (e) {
      if (_isOfflineDio(e)) {
        await _enqueue(
          type: 'create_customer',
          payload: payload.toJson(),
        );
        return const Right(true);
      }
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Request failed'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCustomer(
          String id, CustomerPayload payload) =>
      _guardBool(() => _remote.updateCustomer(id, payload));

  @override
  Future<Either<Failure, bool>> createSale(CreateSalePayload payload) async {
    if (!await _networkInfo.isConnected) {
      await _enqueue(
        type: 'create_sale',
        payload: payload.toJson(),
      );
      return const Right(true);
    }
    try {
      await _remote.createSale(payload);
      return const Right(true);
    } on DioException catch (e) {
      if (_isOfflineDio(e)) {
        await _enqueue(
          type: 'create_sale',
          payload: payload.toJson(),
        );
        return const Right(true);
      }
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Request failed'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateSalePayment(
    String saleId,
    UpdateSalePaymentPayload payload,
  ) =>
      _guardBool(() => _remote.updateSalePayment(saleId, payload));

  @override
  Future<Either<Failure, bool>> createProduct(Map<String, dynamic> payload) =>
      _guardBool(() => _remote.createProduct(payload));

  @override
  Future<Either<Failure, bool>> updateProduct(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.updateProduct(id, payload));

  @override
  Future<Either<Failure, bool>> deleteProduct(String id) =>
      _guardBool(() => _remote.deleteProduct(id));

  @override
  Future<Either<Failure, bool>> createCategory(Map<String, dynamic> payload) =>
      _guardBool(() => _remote.createCategory(payload));

  @override
  Future<Either<Failure, bool>> updateCategory(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.updateCategory(id, payload));

  @override
  Future<Either<Failure, bool>> deleteCategory(String id) =>
      _guardBool(() => _remote.deleteCategory(id));

  @override
  Future<Either<Failure, bool>> createSupplier(Map<String, dynamic> payload) =>
      _guardBool(() => _remote.createSupplier(payload));

  @override
  Future<Either<Failure, bool>> updateSupplier(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.updateSupplier(id, payload));

  @override
  Future<Either<Failure, bool>> deleteSupplier(String id) =>
      _guardBool(() => _remote.deleteSupplier(id));

  @override
  Future<Either<Failure, bool>> reverseSale(String saleId, String reason) =>
      _guardBool(() => _remote.reverseSale(saleId, reason));

  @override
  Future<Either<Failure, bool>> cancelSale(String saleId) =>
      _guardBool(() => _remote.cancelSale(saleId));

  @override
  Future<Either<Failure, bool>> deleteSale(String saleId) =>
      _guardBool(() => _remote.deleteSale(saleId));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getSalesFiltered(
          Map<String, dynamic> query) =>
      _guardList(() => _remote.getSalesFiltered(query));

  @override
  Future<Either<Failure, List<WorkspaceRecord>>> getPurchasesFiltered(
          Map<String, dynamic> query) =>
      _guardList(() => _remote.getPurchasesFiltered(query));

  @override
  Future<Either<Failure, bool>> createPurchase(Map<String, dynamic> payload) =>
      _guardBool(() => _remote.createPurchase(payload));

  @override
  Future<Either<Failure, bool>> updatePurchase(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.updatePurchase(id, payload));

  @override
  Future<Either<Failure, bool>> receivePurchase(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.receivePurchase(id, payload));

  @override
  Future<Either<Failure, bool>> updatePurchasePayment(
          String id, Map<String, dynamic> payload) =>
      _guardBool(() => _remote.updatePurchasePayment(id, payload));

  @override
  Future<Either<Failure, bool>> cancelPurchase(String id) =>
      _guardBool(() => _remote.cancelPurchase(id));

  @override
  Future<Either<Failure, bool>> deletePurchase(String id) =>
      _guardBool(() => _remote.deletePurchase(id));

  @override
  Future<Either<Failure, int>> syncPendingWrites() async {
    if (!await _networkInfo.isConnected) {
      return const Right(0);
    }
    try {
      final queue = await _offlineQueueService.getQueue();
      var synced = 0;
      for (final item in queue) {
        final id = item['id']?.toString() ?? '';
        final type = item['type']?.toString() ?? '';
        final payload = item['payload'];
        if (payload is! Map) {
          continue;
        }
        final data = Map<String, dynamic>.from(payload);
        try {
          if (type == 'create_customer') {
            await _remote.createCustomer(
              CustomerPayload(
                name: data['name']?.toString() ?? '',
                phone: data['phone']?.toString() ?? '',
                email: data['email']?.toString(),
                address: data['address']?.toString(),
                customerType: data['customerType']?.toString() ?? 'RETAIL',
              ),
            );
          } else if (type == 'create_sale') {
            final itemsData = (data['items'] as List<dynamic>? ?? const []);
            final items = itemsData
                .whereType<Map>()
                .map((item) => SaleItemPayload(
                      product: item['product']?.toString(),
                      variant: item['variant']?.toString(),
                      productName: item['productName']?.toString() ?? '',
                      sku: item['sku']?.toString() ?? '',
                      quantity: (item['quantity'] as num?)?.toInt() ?? 0,
                      unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0,
                      discount: (item['discount'] as num?)?.toDouble() ?? 0,
                      tax: (item['tax'] as num?)?.toDouble() ?? 0,
                    ))
                .toList();
            await _remote.createSale(
              CreateSalePayload(
                customerId: data['customer']?.toString() ?? '',
                items: items,
                paidAmount: (data['paidAmount'] as num?)?.toDouble() ?? 0,
                paymentMethod: data['paymentMethod']?.toString() ?? 'CASH',
                notes: data['notes']?.toString(),
              ),
            );
          }
          if (id.isNotEmpty) {
            await _offlineQueueService.removeById(id);
          }
          synced += 1;
        } on DioException catch (e) {
          if (_isOfflineDio(e)) {
            break;
          }
        }
      }
      return Right(synced);
    } catch (_) {
      return const Left(ApiFailure(message: 'Unable to sync offline data'));
    }
  }

  Future<Either<Failure, List<WorkspaceRecord>>> _guardList(
    Future<List<WorkspaceRecord>> Function() action,
  ) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Unable to load records'));
    }
  }

  Future<Either<Failure, WorkspaceRecord>> _guardOne(
    Future<WorkspaceRecord> Function() action,
  ) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Unable to load record details'));
    }
  }

  Future<Either<Failure, WorkspaceSummary>> _guardSummary(
    Future<WorkspaceSummary> Function() action,
  ) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Unable to load summary'));
    }
  }

  Future<Either<Failure, bool>> _guardBool(
      Future<bool> Function() action) async {
    try {
      await action();
      return const Right(true);
    } on DioException catch (e) {
      return Left(ApiFailure(message: _message(e)));
    } catch (_) {
      return const Left(ApiFailure(message: 'Request failed'));
    }
  }

  String _message(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) {
        return data['message'] as String;
      }
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final first = (data['errors'] as List).first;
        if (first is Map<String, dynamic> && first['msg'] is String) {
          return first['msg'] as String;
        }
      }
    }
    return e.message ?? 'Request failed';
  }

  Future<void> _enqueue({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final random = Random();
    final id = '${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(999999)}';
    await _offlineQueueService.enqueue({
      'id': id,
      'type': type,
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  bool _isOfflineDio(DioException e) {
    if (e.response != null) {
      return false;
    }
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
  }
}
