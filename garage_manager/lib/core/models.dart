enum InvoicePaymentStatus { paid, unpaid, processing }

enum RepairStageStatus { done, active, waiting }

class Invoice {
  const Invoice({
    required this.code,
    required this.customerName,
    required this.vehiclePlate,
    required this.totalText,
    required this.statusLabel,
    required this.status,
  });

  final String code;
  final String customerName;
  final String vehiclePlate;
  final String totalText;
  final String statusLabel;
  final InvoicePaymentStatus status;
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
