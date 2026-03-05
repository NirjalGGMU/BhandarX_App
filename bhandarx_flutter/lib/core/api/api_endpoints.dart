class ApiEndpoints {
  ApiEndpoints._();

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static String resetPassword(String token) => '/auth/reset-password/$token';
  static const String resetPasswordOtp = '/auth/reset-password-otp';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/update-profile';
  static const String updatePreferences = '/auth/preferences';
  static const String changePassword = '/auth/change-password';
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/mark-all-read';

  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String lowStockProducts = '/products/low-stock';
  static const String outOfStockProducts = '/products/out-of-stock';
  static const String inventorySummary = '/products/inventory-summary';
  static String productBySku(String sku) => '/products/sku/$sku';
  static String productById(String id) => '/products/$id';
  static const String categories = '/categories';
  static const String rootCategories = '/categories/root';
  static String categoryById(String id) => '/categories/$id';
  static String categorySubcategories(String id) =>
      '/categories/$id/subcategories';
  static const String suppliers = '/suppliers';
  static const String searchSuppliers = '/suppliers/search';
  static String supplierById(String id) => '/suppliers/$id';
  static const String customers = '/customers';
  static String customerById(String id) => '/customers/$id';
  static const String sales = '/sales';
  static String saleById(String id) => '/sales/$id';
  static String updateSalePayment(String id) => '/sales/$id/payment';
  static String reverseSale(String id) => '/sales/$id/reverse';
  static String cancelSale(String id) => '/sales/$id/cancel';
  static const String purchases = '/purchases';
  static String purchaseById(String id) => '/purchases/$id';
  static String updatePurchase(String id) => '/purchases/$id';
  static String receivePurchase(String id) => '/purchases/$id/receive';
  static String updatePurchasePayment(String id) => '/purchases/$id/payment';
  static String cancelPurchase(String id) => '/purchases/$id/cancel';
  static const String transactions = '/transactions';
  static const String recentTransactions = '/transactions/recent';
  static const String transactionSummary = '/transactions/summary';
  static const String reportDashboardSummary = '/reports/dashboard/summary';
  static const String reportSalesTopProducts = '/reports/sales/top-products';
}
