import 'models.dart';

final demoInvoices = [
  Invoice(
    code: 'HD-2026-001',
    customerName: 'Nguyễn Văn An',
    vehiclePlate: '59-X1 234.56',
    createdAt: DateTime(2026, 6, 21),
    subtotal: 2350000,
    discountAmount: 100000,
    tax: 200000,
    total: 2450000,
    status: InvoicePaymentStatus.paid,
    lineItems: const [
      InvoiceLineItem(
        name: 'Thay nhớt Motul 7100',
        type: InvoiceLineItemType.service,
        unitPrice: 450000,
      ),
      InvoiceLineItem(
        name: 'Lọc gió Exciter 150',
        type: InvoiceLineItemType.part,
        unitPrice: 320000,
      ),
      InvoiceLineItem(
        name: 'Vệ sinh kim phun',
        type: InvoiceLineItemType.service,
        unitPrice: 280000,
      ),
      InvoiceLineItem(
        name: 'Bộ nhông sên dĩa DID',
        type: InvoiceLineItemType.part,
        unitPrice: 1300000,
      ),
    ],
  ),
  Invoice(
    code: 'HD-2026-002',
    customerName: 'Trần Minh Khoa',
    vehiclePlate: '60-B2 889.12',
    createdAt: DateTime(2026, 6, 22),
    subtotal: 850000,
    total: 850000,
    status: InvoicePaymentStatus.processing,
    lineItems: const [
      InvoiceLineItem(
        name: 'Công kiểm tra tổng quát',
        type: InvoiceLineItemType.service,
        unitPrice: 250000,
      ),
      InvoiceLineItem(
        name: 'Bố thắng trước',
        type: InvoiceLineItemType.part,
        unitPrice: 380000,
      ),
      InvoiceLineItem(
        name: 'Công thay bố thắng',
        type: InvoiceLineItemType.service,
        unitPrice: 220000,
      ),
    ],
  ),
  Invoice(
    code: 'HD-2026-003',
    customerName: 'Lê Hoàng Hải',
    vehiclePlate: '51-F1 999.99',
    createdAt: DateTime(2026, 7, 5),
    subtotal: 1200000,
    total: 1200000,
    status: InvoicePaymentStatus.unpaid,
    lineItems: const [
      InvoiceLineItem(
        name: 'Sửa chữa phanh xe',
        type: InvoiceLineItemType.service,
        unitPrice: 200000,
      ),
      InvoiceLineItem(
        name: 'Thay lốp trước',
        type: InvoiceLineItemType.part,
        unitPrice: 1000000,
      ),
    ],
  ),
];

const demoRepairStages = [
  RepairStage(
    title: 'Tiếp nhận xe',
    description: 'Khách đã gửi xe và mô tả tình trạng.',
    status: RepairStageStatus.done,
  ),
  RepairStage(
    title: 'Kiểm tra & báo giá',
    description: 'Thợ đã kiểm tra tổng quát và gửi báo giá cho khách.',
    status: RepairStageStatus.done,
  ),
  RepairStage(
    title: 'Chuẩn bị phụ tùng',
    description: 'Garage đang xác nhận phụ tùng và bộ kit cần thay.',
    status: RepairStageStatus.done,
  ),
  RepairStage(
    title: 'Sửa chữa & nâng cấp',
    description: 'Thợ đang thực hiện các hạng mục sửa chữa chính.',
    status: RepairStageStatus.active,
  ),
  RepairStage(
    title: 'Bàn giao & thanh toán',
    description: 'Chờ kiểm tra lần cuối, bàn giao xe và thanh toán.',
    status: RepairStageStatus.waiting,
  ),
];

const demoInventoryItems = [
  InventoryItem(
    id: 'PT001',
    name: 'Bố thắng trước Nissin',
    sku: 'NISSIN-FRONT-01',
    category: InventoryCategory.part,
    stockQuantity: 45,
    minStockWarning: 10,
    priceText: '350.000đ',
    rawPrice: 350000,
    compatibleVehicles: ['Exciter 150', 'Winner X', 'Sirius FI'],
  ),
  InventoryItem(
    id: 'PT002',
    name: 'Phuộc RCB C Series',
    sku: 'RCB-CSERIES-02',
    category: InventoryCategory.part,
    stockQuantity: 4,
    minStockWarning: 5,
    priceText: '1.200.000đ',
    rawPrice: 1200000,
    compatibleVehicles: ['Exciter 150', 'Winner 150'],
  ),
  InventoryItem(
    id: 'PT003',
    name: 'Nhông sên dĩa DID',
    sku: 'DID-CHAIN-01',
    category: InventoryCategory.part,
    stockQuantity: 12,
    minStockWarning: 15,
    priceText: '950.000đ',
    rawPrice: 950000,
    compatibleVehicles: ['Exciter 150', 'Winner X', 'Sonic 150R', 'Raider 150'],
  ),
  InventoryItem(
    id: 'KT001',
    name: 'Bộ Kit Nâng Cấp Piston 62zz',
    sku: 'KIT-62ZZ-EX150',
    category: InventoryCategory.kit,
    stockQuantity: 2,
    minStockWarning: 5,
    priceText: '8.500.000đ',
    rawPrice: 8500000,
    compatibleVehicles: ['Exciter 150'],
  ),
];

const demoInventoryTransactions = [
  InventoryTransaction(
    id: 'TX001',
    itemId: 'PT002',
    itemName: 'Phuộc RCB C Series',
    type: TransactionType.import,
    quantity: 10,
    dateText: '20/06/2026',
    note: 'Nhập hàng đợt 1 tháng 6',
  ),
  InventoryTransaction(
    id: 'TX002',
    itemId: 'KT001',
    itemName: 'Bộ Kit Nâng Cấp Piston 62zz',
    type: TransactionType.export,
    quantity: 1,
    dateText: '22/06/2026',
    note: 'Xuất dùng cho phiếu HD-2026-003',
  ),
];
