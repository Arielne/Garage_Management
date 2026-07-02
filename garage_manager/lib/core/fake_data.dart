import 'models.dart';

const demoInvoices = [
  Invoice(
    code: 'HD-2026-001',
    customerName: 'Nguyễn Văn An',
    vehiclePlate: '59-X1 234.56',
    createdAtText: '21/06/2026',
    subtotalText: '2.350.000đ',
    discountAmountText: '100.000đ',
    taxText: '200.000đ',
    totalText: '2.450.000đ',
    statusLabel: 'Đã thanh toán',
    status: InvoicePaymentStatus.paid,
    lineItems: [
      InvoiceLineItem(
        name: 'Thay nhớt Motul 7100',
        type: InvoiceLineItemType.service,
        quantity: 1,
        unitPriceText: '450.000đ',
        totalText: '450.000đ',
      ),
      InvoiceLineItem(
        name: 'Lọc gió Exciter 150',
        type: InvoiceLineItemType.part,
        quantity: 1,
        unitPriceText: '320.000đ',
        totalText: '320.000đ',
      ),
      InvoiceLineItem(
        name: 'Vệ sinh kim phun',
        type: InvoiceLineItemType.service,
        quantity: 1,
        unitPriceText: '280.000đ',
        totalText: '280.000đ',
      ),
      InvoiceLineItem(
        name: 'Bộ nhông sên dĩa DID',
        type: InvoiceLineItemType.part,
        quantity: 1,
        unitPriceText: '1.300.000đ',
        totalText: '1.300.000đ',
      ),
    ],
  ),
  Invoice(
    code: 'HD-2026-002',
    customerName: 'Trần Minh Khoa',
    vehiclePlate: '60-B2 889.12',
    createdAtText: '22/06/2026',
    subtotalText: '850.000đ',
    discountAmountText: '0đ',
    taxText: '0đ',
    totalText: '850.000đ',
    statusLabel: 'Đang xử lý',
    status: InvoicePaymentStatus.processing,
    lineItems: [
      InvoiceLineItem(
        name: 'Công kiểm tra tổng quát',
        type: InvoiceLineItemType.service,
        quantity: 1,
        unitPriceText: '250.000đ',
        totalText: '250.000đ',
      ),
      InvoiceLineItem(
        name: 'Bố thắng trước',
        type: InvoiceLineItemType.part,
        quantity: 1,
        unitPriceText: '380.000đ',
        totalText: '380.000đ',
      ),
      InvoiceLineItem(
        name: 'Công thay bố thắng',
        type: InvoiceLineItemType.service,
        quantity: 1,
        unitPriceText: '220.000đ',
        totalText: '220.000đ',
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
    title: 'Kiểm tra',
    description: 'Thợ đang kiểm tra phụ tùng và báo giá.',
    status: RepairStageStatus.active,
  ),
  RepairStage(
    title: 'Hoàn tất',
    description: 'Chờ hoàn tất sửa chữa và thanh toán.',
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
    compatibleVehicles: ['Exciter 150', 'Winner X', 'Sonic 150R', 'Raider 150'],
  ),
  InventoryItem(
    id: 'KT001',
    name: 'Bộ Kit Nâng Cấp Piston 62zz',
    sku: 'KIT-62ZZ-EX150',
    category: InventoryCategory.kit,
    stockQuantity: 2,
    minStockWarning: 3,
    priceText: '4.500.000đ',
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
