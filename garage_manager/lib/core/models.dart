import 'package:intl/intl.dart';

enum InvoicePaymentStatus { paid, unpaid, processing }

enum InvoiceLineItemType { service, part }

enum RepairStageStatus { done, active, waiting }

/// Định dạng tiền kiểu Việt Nam: 2450000 -> '2.450.000đ'
final _moneyFormat = NumberFormat('#,##0', 'vi_VN');
String formatMoney(num value) => '${_moneyFormat.format(value)}đ';

/// Map chuỗi enum của Supabase (invoice_status) sang enum Dart.
InvoicePaymentStatus invoicePaymentStatusFromDb(String value) {
  switch (value) {
    case 'da_thanh_toan':
      return InvoicePaymentStatus.paid;
    case 'dang_xu_ly':
      return InvoicePaymentStatus.processing;
    default:
      return InvoicePaymentStatus.unpaid;
  }
}

class Invoice {
  Invoice({
    this.id,
    this.workOrderId,
    required this.code,
    required this.customerName,
    required this.vehiclePlate,
    required this.createdAt,
    required this.subtotal,
    this.discountAmount = 0,
    this.tax = 0,
    required this.total,
    required this.status,
    this.paymentCode,
    this.paidAt,
    this.lineItems = const [],
  });

  final int? id;
  final int? workOrderId;
  final String code;
  final String customerName;
  final String vehiclePlate;
  final DateTime createdAt;
  final num subtotal;
  final num discountAmount;
  final num tax;
  final num total;
  final InvoicePaymentStatus status;
  final String? paymentCode;
  final DateTime? paidAt;
  final List<InvoiceLineItem> lineItems;

  // Getter giữ nguyên tên như model cũ — các màn/widget đang dùng không phải sửa.
  String get createdAtText => DateFormat('dd/MM/yyyy').format(createdAt);
  String get subtotalText => formatMoney(subtotal);
  String get discountAmountText => formatMoney(discountAmount);
  String get taxText => formatMoney(tax);
  String get totalText => formatMoney(total);

  String get statusLabel {
    switch (status) {
      case InvoicePaymentStatus.paid:
        return 'Đã thanh toán';
      case InvoicePaymentStatus.processing:
        return 'Đang xử lý';
      case InvoicePaymentStatus.unpaid:
        return 'Chưa thanh toán';
    }
  }
}

class InvoiceLineItem {
  const InvoiceLineItem({
    required this.name,
    required this.type,
    this.quantity = 1,
    required this.unitPrice,
  });

  final String name;
  final InvoiceLineItemType type;
  final int quantity;
  final num unitPrice;

  num get total => quantity * unitPrice;
  String get unitPriceText => formatMoney(unitPrice);
  String get totalText => formatMoney(total);
}

class RepairStage {
  const RepairStage({
    required this.title,
    required this.description,
    required this.status,
  });

  final String title;
  final String description;
  final RepairStageStatus status;
}

enum InventoryCategory { part, kit }

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.stockQuantity,
    required this.minStockWarning,
    required this.priceText,
    required this.rawPrice,
    required this.compatibleVehicles,
  });

  final String id;
  final String name;
  final String sku;
  final InventoryCategory category;
  final int stockQuantity;
  final int minStockWarning;
  final String priceText;
  final num rawPrice;
  final List<String> compatibleVehicles;

  bool get isLowStock => stockQuantity <= minStockWarning;
}

enum TransactionType { import, export }

class InventoryTransaction {
  const InventoryTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    required this.dateText,
    required this.note,
  });

  final String id;
  final String itemId;
  final String itemName;
  final TransactionType type;
  final int quantity;
  final String dateText;
  final String note;
}

class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.laborPrice,
  });

  final int id;
  final String name;
  final num laborPrice;

  String get laborPriceText => formatMoney(laborPrice);

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as int,
      name: json['name'] as String,
      laborPrice: json['labor_price'] as num,
    );
  }
}

enum VoucherType { percent, amount }

class VoucherModel {
  const VoucherModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minOrder,
    this.expiryDate,
    required this.active,
  });

  final int id;
  final String code;
  final VoucherType type;
  final num value;
  final num minOrder;
  final DateTime? expiryDate;
  final bool active;

  String get valueText => type == VoucherType.percent ? '$value%' : formatMoney(value);
  String get minOrderText => formatMoney(minOrder);
  String get expiryDateText => expiryDate != null ? DateFormat('dd/MM/yyyy').format(expiryDate!) : 'Không giới hạn';

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as int,
      code: json['code'] as String,
      type: json['type'] == 'percent' ? VoucherType.percent : VoucherType.amount,
      value: json['value'] as num,
      minOrder: json['min_order'] as num,
      expiryDate: json['expiry_date'] != null ? DateTime.parse(json['expiry_date'] as String).toLocal() : null,
      active: json['active'] as bool,
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    this.customerId,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String? customerId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  String get createdAtText => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'].toString(),
      customerId: json['customer_id']?.toString(),
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
