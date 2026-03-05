import 'package:equatable/equatable.dart';

class WorkspaceRecord extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final String amount;
  final Map<String, dynamic> raw;

  const WorkspaceRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.amount,
    required this.raw,
  });

  @override
  List<Object?> get props => [id, title, subtitle, status, amount, raw];
}

class WorkspaceSummary extends Equatable {
  final double totalIn;
  final double totalOut;
  final int totalTransactions;

  const WorkspaceSummary({
    required this.totalIn,
    required this.totalOut,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [totalIn, totalOut, totalTransactions];
}

class CustomerPayload {
  final String name;
  final String phone;
  final String? email;
  final String customerType;
  final String? address;

  const CustomerPayload({
    required this.name,
    required this.phone,
    this.email,
    this.customerType = 'RETAIL',
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        if (email != null && email!.isNotEmpty) 'email': email,
        'customerType': customerType,
        if (address != null && address!.isNotEmpty) 'address': address,
      };
}

class SaleItemPayload {
  final String? product;
  final String? variant;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double discount;
  final double tax;

  const SaleItemPayload({
    this.product,
    this.variant,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.tax = 0,
  });

  Map<String, dynamic> toJson() => {
        if (product != null && product!.isNotEmpty) 'product': product,
        if (variant != null && variant!.isNotEmpty) 'variant': variant,
        'productName': productName,
        'sku': sku,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discount': discount,
        'tax': tax,
      };
}

class CreateSalePayload {
  final String customerId;
  final List<SaleItemPayload> items;
  final double paidAmount;
  final String paymentMethod;
  final String? notes;

  const CreateSalePayload({
    required this.customerId,
    required this.items,
    required this.paidAmount,
    this.paymentMethod = 'CASH',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'customer': customerId,
        'items': items.map((e) => e.toJson()).toList(),
        'paidAmount': paidAmount,
        'paymentMethod': paymentMethod,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class UpdateSalePaymentPayload {
  final double paidAmount;
  final String paymentMethod;

  const UpdateSalePaymentPayload({
    required this.paidAmount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'paidAmount': paidAmount,
        'paymentMethod': paymentMethod,
      };
}
