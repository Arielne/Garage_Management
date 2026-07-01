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
