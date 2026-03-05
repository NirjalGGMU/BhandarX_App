import 'package:bhandarx_flutter/core/error/failures.dart';
import 'package:bhandarx_flutter/features/workspace/domain/entities/workspace_entities.dart';
import 'package:dartz/dartz.dart';

abstract interface class IWorkspaceRepository {
  Future<Either<Failure, List<WorkspaceRecord>>> getProducts({String? search});
  Future<Either<Failure, List<WorkspaceRecord>>> getLowStockProducts();
  Future<Either<Failure, List<WorkspaceRecord>>> getOutOfStockProducts();
  Future<Either<Failure, WorkspaceRecord>> getProductBySku(String sku);
  Future<Either<Failure, WorkspaceSummary>> getInventorySummary();
  Future<Either<Failure, List<WorkspaceRecord>>> getCategories();
  Future<Either<Failure, List<WorkspaceRecord>>> getRootCategories();
  Future<Either<Failure, List<WorkspaceRecord>>> getSubcategories(
      String categoryId);
  Future<Either<Failure, List<WorkspaceRecord>>> getSuppliers({String? search});
  Future<Either<Failure, List<WorkspaceRecord>>> getCustomers({String? search});
  Future<Either<Failure, WorkspaceRecord>> getCustomerById(String id);
  Future<Either<Failure, List<WorkspaceRecord>>> getSales({String? search});
  Future<Either<Failure, WorkspaceRecord>> getSaleById(String id);
  Future<Either<Failure, List<WorkspaceRecord>>> getPurchases();
  Future<Either<Failure, WorkspaceRecord>> getPurchaseById(String id);
  Future<Either<Failure, List<WorkspaceRecord>>> getTransactions(
      {String? search});
  Future<Either<Failure, List<WorkspaceRecord>>> getRecentTransactions();
  Future<Either<Failure, WorkspaceSummary>> getTransactionSummary();
  Future<Either<Failure, WorkspaceSummary>> getDashboardSummary();
  Future<Either<Failure, List<WorkspaceRecord>>> getSalesTopProducts();

  Future<Either<Failure, bool>> createCustomer(CustomerPayload payload);
  Future<Either<Failure, bool>> updateCustomer(
      String id, CustomerPayload payload);
  Future<Either<Failure, bool>> createSale(CreateSalePayload payload);
  Future<Either<Failure, bool>> updateSalePayment(
    String saleId,
    UpdateSalePaymentPayload payload,
  );

  Future<Either<Failure, bool>> createProduct(Map<String, dynamic> payload);
  Future<Either<Failure, bool>> updateProduct(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> deleteProduct(String id);
  Future<Either<Failure, bool>> createCategory(Map<String, dynamic> payload);
  Future<Either<Failure, bool>> updateCategory(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> deleteCategory(String id);
  Future<Either<Failure, bool>> createSupplier(Map<String, dynamic> payload);
  Future<Either<Failure, bool>> updateSupplier(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> deleteSupplier(String id);
  Future<Either<Failure, bool>> reverseSale(String saleId, String reason);
  Future<Either<Failure, bool>> cancelSale(String saleId);
  Future<Either<Failure, bool>> deleteSale(String saleId);
  Future<Either<Failure, List<WorkspaceRecord>>> getSalesFiltered(
      Map<String, dynamic> query);
  Future<Either<Failure, List<WorkspaceRecord>>> getPurchasesFiltered(
      Map<String, dynamic> query);
  Future<Either<Failure, bool>> createPurchase(Map<String, dynamic> payload);
  Future<Either<Failure, bool>> updatePurchase(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> receivePurchase(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> updatePurchasePayment(
      String id, Map<String, dynamic> payload);
  Future<Either<Failure, bool>> cancelPurchase(String id);
  Future<Either<Failure, bool>> deletePurchase(String id);
  Future<Either<Failure, int>> syncPendingWrites();
}
