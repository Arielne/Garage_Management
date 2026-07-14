import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models.dart';

/// Repository hóa đơn — lớp trung gian giữa UI và Supabase.
/// UI (B4, B4.1, D9) chỉ gọi các hàm ở đây, KHÔNG query database trực tiếp.
/// Lợi ích: đổi nguồn dữ liệu / sửa query chỉ sửa 1 file này.
class InvoiceRepository {
  InvoiceRepository(this._client);

  final SupabaseClient _client;

  /// Lấy danh sách hóa đơn từ view `v_invoice_list`.
  /// View đã join sẵn tên khách + biển số nên chỉ cần 1 câu select.
  /// Dùng cho: B4 (hóa đơn của khách), D9 (toàn bộ hóa đơn của quản lý).
  Future<List<Invoice>> getInvoices() async {
    final rows = await _client
        .from('v_invoice_list')
        .select()
        .order('created_at', ascending: false);

    return rows.map<Invoice>(_invoiceFromRow).toList();
  }

  /// Lấy các dòng hạng mục (dịch vụ + phụ tùng) của MỘT hóa đơn
  /// theo work_order_id, rồi trả về bản Invoice đã gắn đủ lineItems.
  /// Dùng cho: B4.1 (chi tiết hóa đơn).
  Future<Invoice> getInvoiceWithItems(Invoice invoice) async {
    final workOrderId = invoice.workOrderId;
    if (workOrderId == null) return invoice;

    // 2 query chạy song song cho nhanh: dịch vụ (tiền công) + phụ tùng.
    final results = await Future.wait([
      _client
          .from('work_order_services')
          .select('name, labor_price')
          .eq('work_order_id', workOrderId),
      _client
          .from('work_order_parts')
          .select('name, quantity, unit_price')
          .eq('work_order_id', workOrderId),
    ]);

    final serviceRows = results[0];
    final partRows = results[1];

    final lineItems = <InvoiceLineItem>[
      for (final row in serviceRows)
        InvoiceLineItem(
          name: (row['name'] ?? '') as String,
          type: InvoiceLineItemType.service,
          unitPrice: (row['labor_price'] ?? 0) as num,
        ),
      for (final row in partRows)
        InvoiceLineItem(
          name: (row['name'] ?? '') as String,
          type: InvoiceLineItemType.part,
          quantity: (row['quantity'] ?? 1) as int,
          unitPrice: (row['unit_price'] ?? 0) as num,
        ),
    ];

    return _copyWithItems(invoice, lineItems);
  }

  /// Map 1 dòng JSON của view thành object Invoice (kiểu số).
  Invoice _invoiceFromRow(Map<String, dynamic> row) {
    return Invoice(
      id: row['id'] as int?,
      workOrderId: row['work_order_id'] as int?,
      code: (row['code'] ?? '') as String,
      customerName: (row['customer_name'] ?? '') as String,
      vehiclePlate: (row['license_plate'] ?? '') as String,
      createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      subtotal: (row['subtotal'] ?? 0) as num,
      discountAmount: (row['discount_amount'] ?? 0) as num,
      tax: (row['tax'] ?? 0) as num,
      total: (row['total'] ?? 0) as num,
      // Chuỗi enum của Postgres ('da_thanh_toan'...) -> enum Dart.
      status: invoicePaymentStatusFromDb((row['status'] ?? '') as String),
      paymentCode: row['payment_code'] as String?,
      paidAt: row['paid_at'] == null
          ? null
          : DateTime.parse(row['paid_at'] as String).toLocal(),
    );
  }

  /// Model Invoice là immutable (final hết) nên muốn "gắn" lineItems
  /// phải tạo object mới copy lại các field cũ.
  Invoice _copyWithItems(Invoice invoice, List<InvoiceLineItem> lineItems) {
    return Invoice(
      id: invoice.id,
      workOrderId: invoice.workOrderId,
      code: invoice.code,
      customerName: invoice.customerName,
      vehiclePlate: invoice.vehiclePlate,
      createdAt: invoice.createdAt,
      subtotal: invoice.subtotal,
      discountAmount: invoice.discountAmount,
      tax: invoice.tax,
      total: invoice.total,
      status: invoice.status,
      paymentCode: invoice.paymentCode,
      paidAt: invoice.paidAt,
      lineItems: lineItems,
    );
  }
}

// ===== Riverpod providers =====

/// Cung cấp repository cho toàn app.
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  return InvoiceRepository(Supabase.instance.client);
});

/// Danh sách hóa đơn dạng async — UI watch provider này là có sẵn
/// 3 trạng thái: loading (hiện spinner) / error (hiện lỗi) / data (hiện list).
final invoiceListProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceRepositoryProvider).getInvoices();
});

/// Chi tiết 1 hóa đơn kèm hạng mục (B4.1).
/// family: mỗi hóa đơn là 1 provider riêng; autoDispose: rời màn là giải phóng.
final invoiceWithItemsProvider =
    FutureProvider.autoDispose.family<Invoice, Invoice>((ref, invoice) {
  return ref.watch(invoiceRepositoryProvider).getInvoiceWithItems(invoice);
});
