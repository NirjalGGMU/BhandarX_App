import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';

abstract interface class IWorkspaceRemoteDatasource {
  Future<List<WorkspaceRecord>> getProducts({String? search});
  Future<List<WorkspaceRecord>> getLowStockProducts();
  Future<List<WorkspaceRecord>> getOutOfStockProducts();
  Future<WorkspaceRecord> getProductBySku(String sku);
  Future<WorkspaceSummary> getInventorySummary();
  Future<List<WorkspaceRecord>> getCategories();
  Future<List<WorkspaceRecord>> getRootCategories();
  Future<List<WorkspaceRecord>> getSubcategories(String categoryId);
  Future<List<WorkspaceRecord>> getSuppliers({String? search});
  Future<List<WorkspaceRecord>> getCustomers({String? search});
  Future<WorkspaceRecord> getCustomerById(String id);
  Future<List<WorkspaceRecord>> getSales({String? search});
  Future<WorkspaceRecord> getSaleById(String id);
  Future<List<WorkspaceRecord>> getPurchases();
  Future<WorkspaceRecord> getPurchaseById(String id);
  Future<List<WorkspaceRecord>> getTransactions({String? search});
  Future<List<WorkspaceRecord>> getRecentTransactions();
  Future<WorkspaceSummary> getTransactionSummary();
  Future<WorkspaceSummary> getDashboardSummary();
  Future<List<WorkspaceRecord>> getSalesTopProducts();

  Future<bool> createCustomer(CustomerPayload payload);
  Future<bool> updateCustomer(String id, CustomerPayload payload);
  Future<bool> createSale(CreateSalePayload payload);
  Future<bool> updateSalePayment(
      String saleId, UpdateSalePaymentPayload payload);

  Future<bool> createProduct(Map<String, dynamic> payload);
  Future<bool> updateProduct(String id, Map<String, dynamic> payload);
  Future<bool> deleteProduct(String id);
  Future<bool> createCategory(Map<String, dynamic> payload);
  Future<bool> updateCategory(String id, Map<String, dynamic> payload);
  Future<bool> deleteCategory(String id);
  Future<bool> createSupplier(Map<String, dynamic> payload);
  Future<bool> updateSupplier(String id, Map<String, dynamic> payload);
  Future<bool> deleteSupplier(String id);
  Future<bool> reverseSale(String saleId, String reason);
  Future<bool> cancelSale(String saleId);
  Future<bool> deleteSale(String saleId);
  Future<List<WorkspaceRecord>> getSalesFiltered(Map<String, dynamic> query);
  Future<List<WorkspaceRecord>> getPurchasesFiltered(
      Map<String, dynamic> query);
  Future<bool> createPurchase(Map<String, dynamic> payload);
  Future<bool> updatePurchase(String id, Map<String, dynamic> payload);
  Future<bool> receivePurchase(String id, Map<String, dynamic> payload);
  Future<bool> updatePurchasePayment(String id, Map<String, dynamic> payload);
  Future<bool> cancelPurchase(String id);
  Future<bool> deletePurchase(String id);
}
