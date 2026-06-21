import 'models.dart';

const demoInvoices = [
  Invoice(
    code: 'HD-2026-001',
    customerName: 'Nguyễn Văn An',
    vehiclePlate: '59-X1 234.56',
    totalText: '2.450.000đ',
    statusLabel: 'Đã thanh toán',
    status: InvoicePaymentStatus.paid,
  ),
  Invoice(
    code: 'HD-2026-002',
    customerName: 'Trần Minh Khoa',
    vehiclePlate: '60-B2 889.12',
    totalText: '850.000đ',
    statusLabel: 'Đang xử lý',
    status: InvoicePaymentStatus.processing,
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
