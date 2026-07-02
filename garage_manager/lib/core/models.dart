enum InvoicePaymentStatus { paid, unpaid, processing }

enum InvoiceLineItemType { service, part }

enum RepairStageStatus { done, active, waiting }

class Invoice {
  const Invoice({
    required this.code,
    required this.customerName,
    required this.vehiclePlate,
    required this.createdAtText,
    required this.subtotalText,
    required this.discountAmountText,
    required this.taxText,
    required this.totalText,
    required this.statusLabel,
    required this.status,
    required this.lineItems,
  });

  final String code;
  final String customerName;
  final String vehiclePlate;
  final String createdAtText;
  final String subtotalText;
  final String discountAmountText;
  final String taxText;
  final String totalText;
  final String statusLabel;
  final InvoicePaymentStatus status;
  final List<InvoiceLineItem> lineItems;
}

class InvoiceLineItem {
  const InvoiceLineItem({
    required this.name,
    required this.type,
    required this.quantity,
    required this.unitPriceText,
    required this.totalText,
  });

  final String name;
  final InvoiceLineItemType type;
  final int quantity;
  final String unitPriceText;
  final String totalText;
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
    required this.compatibleVehicles,
  });

  final String id;
  final String name;
  final String sku;
  final InventoryCategory category;
  final int stockQuantity;
  final int minStockWarning;
  final String priceText;
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
