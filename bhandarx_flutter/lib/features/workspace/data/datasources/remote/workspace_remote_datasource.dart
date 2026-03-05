import 'package:bhandarx_flutter/core/api/api_client.dart';
import 'package:bhandarx_flutter/core/api/api_endpoints.dart';
import 'package:bhandarx_flutter/features/workspace/data/datasources/workspace_datasource.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workspaceRemoteDatasourceProvider =
    Provider<IWorkspaceRemoteDatasource>((ref) {
  return WorkspaceRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class WorkspaceRemoteDatasource implements IWorkspaceRemoteDatasource {
  WorkspaceRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<WorkspaceRecord>> getProducts({String? search}) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.products,
      queryParameters: {
        'pageSize': 50,
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
    return _mapProducts(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getLowStockProducts() async {
    final response = await _apiClient.dio.get(ApiEndpoints.lowStockProducts);
    return _mapProducts(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getOutOfStockProducts() async {
    final response = await _apiClient.dio.get(ApiEndpoints.outOfStockProducts);
    return _mapProducts(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<WorkspaceRecord> getProductBySku(String sku) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productBySku(sku));
    return _mapProduct(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<WorkspaceSummary> getInventorySummary() async {
    final response = await _apiClient.dio.get(ApiEndpoints.inventorySummary);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return WorkspaceSummary(
      totalIn: (data['totalValue'] ?? 0).toDouble(),
      totalOut: (data['totalCost'] ?? 0).toDouble(),
      totalTransactions: ((data['totalProducts'] ?? 0) as num).toInt(),
    );
  }

  @override
  Future<List<WorkspaceRecord>> getCategories() async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.categories, queryParameters: {'pageSize': 50});
    return _mapCategories(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getRootCategories() async {
    final response = await _apiClient.dio.get(ApiEndpoints.rootCategories);
    return _mapCategories(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getSubcategories(String categoryId) async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.categorySubcategories(categoryId));
    return _mapCategories(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getSuppliers({String? search}) async {
    final endpoint = (search != null && search.isNotEmpty)
        ? ApiEndpoints.searchSuppliers
        : ApiEndpoints.suppliers;
    final response = await _apiClient.dio.get(
      endpoint,
      queryParameters: {
        'pageSize': 50,
        if (search != null && search.isNotEmpty) 'q': search,
      },
    );
    return _mapSuppliers(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getCustomers({String? search}) async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.customers, queryParameters: {
      'pageSize': 50,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _mapCustomers(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<WorkspaceRecord> getCustomerById(String id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.customerById(id));
    return _mapCustomer(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<WorkspaceRecord>> getSales({String? search}) async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.sales, queryParameters: {
      'pageSize': 50,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _mapSales(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<WorkspaceRecord> getSaleById(String id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.saleById(id));
    return _mapSale(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<WorkspaceRecord>> getPurchases() async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.purchases, queryParameters: {'pageSize': 50});
    return _mapPurchases(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<WorkspaceRecord> getPurchaseById(String id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.purchaseById(id));
    return _mapPurchase(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<WorkspaceRecord>> getTransactions({String? search}) async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.transactions, queryParameters: {
      'pageSize': 50,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return _mapTransactions(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getRecentTransactions() async {
    final response = await _apiClient.dio.get(ApiEndpoints.recentTransactions);
    return _mapTransactions(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<WorkspaceSummary> getTransactionSummary() async {
    final response = await _apiClient.dio.get(ApiEndpoints.transactionSummary);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return WorkspaceSummary(
      totalIn: (data['totalIn'] ?? 0).toDouble(),
      totalOut: (data['totalOut'] ?? 0).toDouble(),
      totalTransactions:
          ((data['totalTransactions'] ?? data['count'] ?? 0) as num).toInt(),
    );
  }

  @override
  Future<WorkspaceSummary> getDashboardSummary() async {
    final response =
        await _apiClient.dio.get(ApiEndpoints.reportDashboardSummary);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final sales = data['sales'] as Map<String, dynamic>? ?? {};
    final inventory = data['inventory'] as Map<String, dynamic>? ?? {};
    return WorkspaceSummary(
      totalIn: (sales['total'] ?? 0).toDouble(),
      totalOut: (inventory['totalValue'] ?? 0).toDouble(),
      totalTransactions: ((inventory['totalProducts'] ?? 0) as num).toInt(),
    );
  }

  @override
  Future<List<WorkspaceRecord>> getSalesTopProducts() async {
    final response =
        await _apiClient.dio.get(ApiEndpoints.reportSalesTopProducts);
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.whereType<Map<String, dynamic>>().map((item) {
      return WorkspaceRecord(
        id: (item['_id'] ?? item['productId'] ?? '').toString(),
        title: (item['productName'] ?? item['name'] ?? 'Product').toString(),
        subtitle: 'Top selling',
        status: 'Qty: ${(item['totalQuantity'] ?? item['quantity'] ?? 0)}',
        amount: 'Rs ${(item['totalAmount'] ?? item['sales'] ?? 0)}',
        raw: item,
      );
    }).toList();
  }

  @override
  Future<bool> createCustomer(CustomerPayload payload) async {
    await _apiClient.dio.post(ApiEndpoints.customers, data: payload.toJson());
    return true;
  }

  @override
  Future<bool> updateCustomer(String id, CustomerPayload payload) async {
    await _apiClient.dio
        .put(ApiEndpoints.customerById(id), data: payload.toJson());
    return true;
  }

  @override
  Future<bool> createSale(CreateSalePayload payload) async {
    await _apiClient.dio.post(ApiEndpoints.sales, data: payload.toJson());
    return true;
  }

  @override
  Future<bool> updateSalePayment(
      String saleId, UpdateSalePaymentPayload payload) async {
    await _apiClient.dio
        .patch(ApiEndpoints.updateSalePayment(saleId), data: payload.toJson());
    return true;
  }

  @override
  Future<bool> createProduct(Map<String, dynamic> payload) async {
    await _apiClient.dio.post(ApiEndpoints.products, data: payload);
    return true;
  }

  @override
  Future<bool> updateProduct(String id, Map<String, dynamic> payload) async {
    await _apiClient.dio.put(ApiEndpoints.productById(id), data: payload);
    return true;
  }

  @override
  Future<bool> deleteProduct(String id) async {
    await _apiClient.dio.delete(ApiEndpoints.productById(id));
    return true;
  }

  @override
  Future<bool> createCategory(Map<String, dynamic> payload) async {
    await _apiClient.dio.post(ApiEndpoints.categories, data: payload);
    return true;
  }

  @override
  Future<bool> updateCategory(String id, Map<String, dynamic> payload) async {
    await _apiClient.dio.put(ApiEndpoints.categoryById(id), data: payload);
    return true;
  }

  @override
  Future<bool> deleteCategory(String id) async {
    await _apiClient.dio.delete(ApiEndpoints.categoryById(id));
    return true;
  }

  @override
  Future<bool> createSupplier(Map<String, dynamic> payload) async {
    await _apiClient.dio.post(ApiEndpoints.suppliers, data: payload);
    return true;
  }

  @override
  Future<bool> updateSupplier(String id, Map<String, dynamic> payload) async {
    await _apiClient.dio.put(ApiEndpoints.supplierById(id), data: payload);
    return true;
  }

  @override
  Future<bool> deleteSupplier(String id) async {
    await _apiClient.dio.delete(ApiEndpoints.supplierById(id));
    return true;
  }

  @override
  Future<bool> reverseSale(String saleId, String reason) async {
    await _apiClient.dio.post(ApiEndpoints.reverseSale(saleId), data: {
      'reversalReason': reason,
    });
    return true;
  }

  @override
  Future<bool> cancelSale(String saleId) async {
    await _apiClient.dio.patch(ApiEndpoints.cancelSale(saleId));
    return true;
  }

  @override
  Future<bool> deleteSale(String saleId) async {
    await _apiClient.dio.delete(ApiEndpoints.saleById(saleId));
    return true;
  }

  @override
  Future<List<WorkspaceRecord>> getSalesFiltered(
      Map<String, dynamic> query) async {
    final response =
        await _apiClient.dio.get(ApiEndpoints.sales, queryParameters: query);
    return _mapSales(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<List<WorkspaceRecord>> getPurchasesFiltered(
      Map<String, dynamic> query) async {
    final response = await _apiClient.dio
        .get(ApiEndpoints.purchases, queryParameters: query);
    return _mapPurchases(response.data['data'] as List<dynamic>? ?? []);
  }

  @override
  Future<bool> createPurchase(Map<String, dynamic> payload) async {
    await _apiClient.dio.post(ApiEndpoints.purchases, data: payload);
    return true;
  }

  @override
  Future<bool> updatePurchase(String id, Map<String, dynamic> payload) async {
    await _apiClient.dio.put(ApiEndpoints.updatePurchase(id), data: payload);
    return true;
  }

  @override
  Future<bool> receivePurchase(String id, Map<String, dynamic> payload) async {
    await _apiClient.dio.post(ApiEndpoints.receivePurchase(id), data: payload);
    return true;
  }

  @override
  Future<bool> updatePurchasePayment(
      String id, Map<String, dynamic> payload) async {
    await _apiClient.dio
        .patch(ApiEndpoints.updatePurchasePayment(id), data: payload);
    return true;
  }

  @override
  Future<bool> cancelPurchase(String id) async {
    await _apiClient.dio.patch(ApiEndpoints.cancelPurchase(id));
    return true;
  }

  @override
  Future<bool> deletePurchase(String id) async {
    await _apiClient.dio.delete(ApiEndpoints.purchaseById(id));
    return true;
  }

  List<WorkspaceRecord> _mapProducts(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map(_mapProduct).toList();

  List<WorkspaceRecord> _mapCategories(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map((item) {
        return WorkspaceRecord(
          id: (item['_id'] ?? '').toString(),
          title: (item['name'] ?? 'Category').toString(),
          subtitle: 'Code: ${(item['code'] ?? '-').toString()}',
          status: ((item['isActive'] ?? true) as bool) ? 'ACTIVE' : 'INACTIVE',
          amount: 'Products: ${(item['productCount'] ?? 0).toString()}',
          raw: item,
        );
      }).toList();

  List<WorkspaceRecord> _mapSuppliers(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map((item) {
        return WorkspaceRecord(
          id: (item['_id'] ?? '').toString(),
          title: (item['name'] ?? 'Supplier').toString(),
          subtitle: (item['email'] ?? item['phone'] ?? '-').toString(),
          status: (item['status'] ?? '').toString(),
          amount: 'Code: ${(item['code'] ?? '-').toString()}',
          raw: item,
        );
      }).toList();

  List<WorkspaceRecord> _mapCustomers(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map(_mapCustomer).toList();

  List<WorkspaceRecord> _mapSales(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map(_mapSale).toList();

  List<WorkspaceRecord> _mapPurchases(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map(_mapPurchase).toList();

  List<WorkspaceRecord> _mapTransactions(List<dynamic> list) =>
      list.whereType<Map<String, dynamic>>().map((item) {
        final product = item['product'];
        final productName = product is Map<String, dynamic>
            ? (product['name'] ?? 'Product').toString()
            : 'Product';
        return WorkspaceRecord(
          id: (item['_id'] ?? '').toString(),
          title: productName,
          subtitle: (item['type'] ?? 'Transaction').toString(),
          status: 'Qty: ${(item['quantity'] ?? 0).toString()}',
          amount: 'Rs ${(item['totalAmount'] ?? 0).toString()}',
          raw: item,
        );
      }).toList();

  WorkspaceRecord _mapProduct(Map<String, dynamic> item) {
    return WorkspaceRecord(
      id: (item['_id'] ?? '').toString(),
      title: (item['name'] ?? 'Product').toString(),
      subtitle: 'SKU: ${(item['sku'] ?? '-').toString()}',
      status: (item['status'] ?? '').toString(),
      amount: 'Qty: ${(item['quantity'] ?? 0).toString()}',
      raw: item,
    );
  }

  WorkspaceRecord _mapCustomer(Map<String, dynamic> item) {
    return WorkspaceRecord(
      id: (item['_id'] ?? '').toString(),
      title: (item['name'] ?? 'Customer').toString(),
      subtitle: (item['phone'] ?? item['email'] ?? '-').toString(),
      status: ((item['isActive'] ?? true) as bool) ? 'ACTIVE' : 'INACTIVE',
      amount: 'Balance: ${(item['outstandingBalance'] ?? 0).toString()}',
      raw: item,
    );
  }

  WorkspaceRecord _mapSale(Map<String, dynamic> item) {
    final customer = item['customer'];
    final customerName = customer is Map<String, dynamic>
        ? (customer['name'] ?? 'Customer').toString()
        : 'Customer';
    return WorkspaceRecord(
      id: (item['_id'] ?? '').toString(),
      title: (item['invoiceNumber'] ?? 'Sale').toString(),
      subtitle: customerName,
      status: (item['paymentStatus'] ?? '').toString(),
      amount: 'Rs ${(item['totalAmount'] ?? 0).toString()}',
      raw: item,
    );
  }

  WorkspaceRecord _mapPurchase(Map<String, dynamic> item) {
    final supplier = item['supplier'];
    final supplierName = supplier is Map<String, dynamic>
        ? (supplier['name'] ?? 'Supplier').toString()
        : 'Supplier';
    return WorkspaceRecord(
      id: (item['_id'] ?? '').toString(),
      title: (item['poNumber'] ?? 'Purchase').toString(),
      subtitle: supplierName,
      status: (item['status'] ?? '').toString(),
      amount: 'Rs ${(item['totalAmount'] ?? 0).toString()}',
      raw: item,
    );
  }
}
