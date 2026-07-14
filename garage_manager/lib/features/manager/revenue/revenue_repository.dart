import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tab của D10: Tuần (7 ngày, chuyển tuần được) hoặc Tháng (6 tháng).
enum RevenueRange { week, month }

/// Kiểu báo cáo thực tế đang hiển thị.
enum RevenueMode { day, week, month }

/// Tham số truy vấn D10 (key cho provider.family — record so sánh theo giá trị):
/// - day != null  -> xem 1 ngày cụ thể (nút lịch 📅).
/// - range == week -> xem tuần bắt đầu từ weekStart (mặc định tuần này).
/// - range == month -> 6 tháng gần nhất.
typedef RevenueQuery = ({RevenueRange range, DateTime? weekStart, DateTime? day});

/// Repository doanh thu (D10). Mọi khối cùng lấy theo 1 khoảng thời gian
/// nên số liệu nhất quán. Donut + hạng mục scale lại cho khớp Tổng doanh thu
/// (đã gồm thuế 8%, trừ giảm giá).
class RevenueRepository {
  RevenueRepository(this._client);

  final SupabaseClient _client;

  /// Thứ 2 đầu tuần chứa ngày [d] (giờ VN của máy).
  static DateTime mondayOf(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<RevenueReport> getRevenueReport(RevenueQuery query) async {
    if (query.day != null) {
      final d = query.day!;
      return _dayReport(DateTime(d.year, d.month, d.day), d);
    }
    if (query.range == RevenueRange.week) {
      return _weekReport(query.weekStart ?? mondayOf(DateTime.now()));
    }
    return _monthReport();
  }

  // ----- 3 kiểu báo cáo -----

  Future<RevenueReport> _monthReport() async {
    final rows = await _client
        .from('v_revenue_by_month')
        .select()
        .order('month', ascending: false)
        .limit(6);
    final ordered = rows.reversed.toList();

    final points = <RevenuePoint>[];
    for (final row in ordered) {
      final m = DateTime.parse(row['month'] as String).toLocal();
      points.add(RevenuePoint(
        periodStart: m,
        revenue: _toNum(row['revenue']),
        invoiceCount: (row['invoice_count'] ?? 0) as int,
        label: 'T${m.month}',
        fullLabel: 'Tháng ${m.month}/${m.year}',
      ));
    }

    final start = points.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : points.first.periodStart;
    final end = DateTime.now().add(const Duration(days: 1));
    final w = await _windowStats(start, end);

    return _report(RevenueMode.month, w, points: points);
  }

  Future<RevenueReport> _weekReport(DateTime weekStart) async {
    final end = weekStart.add(const Duration(days: 7));
    final w = await _windowStats(weekStart, end);

    // Gom hóa đơn trong tuần thành 7 cột ngày (Thứ 2 -> Chủ nhật).
    final revenues = List<num>.filled(7, 0);
    final counts = List<int>.filled(7, 0);
    for (final row in w.invoiceRows) {
      final created = DateTime.parse(row['created_at'] as String).toLocal();
      final idx = DateTime(created.year, created.month, created.day)
          .difference(weekStart)
          .inDays;
      if (idx >= 0 && idx < 7) {
        revenues[idx] += _toNum(row['total']);
        counts[idx] += 1;
      }
    }

    const weekdayNames = [
      'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật',
    ];
    final points = <RevenuePoint>[];
    for (var i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      points.add(RevenuePoint(
        periodStart: day,
        revenue: revenues[i],
        invoiceCount: counts[i],
        label: '${day.day}/${day.month}',
        fullLabel: '${weekdayNames[i]} · ${day.day}/${day.month}',
      ));
    }

    return _report(RevenueMode.week, w, points: points, weekStart: weekStart);
  }

  Future<RevenueReport> _dayReport(DateTime start, DateTime pickedDay) async {
    final w = await _windowStats(start, start.add(const Duration(days: 1)));
    return _report(RevenueMode.day, w, points: const [], day: pickedDay);
  }

  RevenueReport _report(
    RevenueMode mode,
    _Window w, {
    required List<RevenuePoint> points,
    DateTime? day,
    DateTime? weekStart,
  }) {
    return RevenueReport(
      mode: mode,
      day: day,
      weekStart: weekStart,
      points: points,
      totalRevenue: w.total,
      invoiceCount: w.count,
      averageInvoice: w.count == 0 ? 0 : w.total / w.count,
      paymentSummary: w.pay,
      slices: w.slices,
      topItems: w.top,
    );
  }

  /// Thống kê dùng chung cho 1 khoảng [start, end): hóa đơn, tổng, cơ cấu,
  /// top hạng mục. Donut/top đã scale cho khớp Tổng doanh thu.
  Future<_Window> _windowStats(DateTime start, DateTime end) async {
    final startIso = start.toUtc().toIso8601String();
    final endIso = end.toUtc().toIso8601String();

    final invoiceRows = await _client
        .from('invoices')
        .select('total, payment_method, created_at')
        .eq('status', 'da_thanh_toan')
        .gte('created_at', startIso)
        .lt('created_at', endIso);

    num total = 0;
    for (final row in invoiceRows) {
      total += _toNum(row['total']);
    }

    final typeRows = await _client.rpc(
      'revenue_type_between',
      params: {'p_start': startIso, 'p_end': endIso},
    ) as List;
    final topRows = await _client.rpc(
      'revenue_top_items_between',
      params: {'p_start': startIso, 'p_end': endIso, 'p_limit': 3},
    ) as List;

    // RPC trả số TRƯỚC thuế/giảm giá -> giữ tỉ lệ, nhân lại cho khớp tổng.
    final rawSlices = [
      for (final row in typeRows)
        RevenueTypeSlice(
          label: (row['type'] ?? '') as String,
          revenue: _toNum(row['revenue']),
        ),
    ];
    final rawSum = rawSlices.fold<num>(0, (sum, s) => sum + s.revenue);
    final scale = (rawSum > 0 && total > 0) ? total / rawSum : 1;
    final slices = [
      for (final s in rawSlices)
        RevenueTypeSlice(label: s.label, revenue: s.revenue * scale),
    ];
    final top = [
      for (final row in topRows)
        TopRevenueItem(
          name: (row['name'] ?? '') as String,
          revenue: _toNum(row['revenue']) * scale,
        ),
    ];

    return _Window(
      invoiceRows: invoiceRows,
      total: total,
      count: invoiceRows.length,
      pay: _paymentSummary(invoiceRows),
      slices: slices,
      top: top,
    );
  }

  String _paymentSummary(List<Map<String, dynamic>> rows) {
    final methods = <String>{
      for (final row in rows)
        if (row['payment_method'] != null) row['payment_method'] as String,
    };
    if (methods.isEmpty) return '—';
    if (methods.length > 1) return 'Cả hai';
    return methods.first == 'tien_mat' ? 'Tiền mặt' : 'Chuyển khoản';
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

/// Gói dữ liệu chung của 1 khoảng thời gian (nội bộ repository).
class _Window {
  _Window({
    required this.invoiceRows,
    required this.total,
    required this.count,
    required this.pay,
    required this.slices,
    required this.top,
  });

  final List<Map<String, dynamic>> invoiceRows;
  final num total;
  final int count;
  final String pay;
  final List<RevenueTypeSlice> slices;
  final List<TopRevenueItem> top;
}

// ===== Model báo cáo =====

class RevenueReport {
  const RevenueReport({
    required this.mode,
    required this.day,
    required this.weekStart,
    required this.points,
    required this.totalRevenue,
    required this.invoiceCount,
    required this.averageInvoice,
    required this.paymentSummary,
    required this.slices,
    required this.topItems,
  });

  final RevenueMode mode;
  final DateTime? day;
  final DateTime? weekStart;

  /// Tuần: 7 cột ngày · Tháng: 6 cột tháng · Ngày: rỗng (không vẽ biểu đồ).
  final List<RevenuePoint> points;
  final num totalRevenue;
  final int invoiceCount;
  final num averageInvoice;
  final String paymentSummary;
  final List<RevenueTypeSlice> slices;
  final List<TopRevenueItem> topItems;

  bool get isDay => mode == RevenueMode.day;
  bool get isWeek => mode == RevenueMode.week;
}

class RevenuePoint {
  const RevenuePoint({
    required this.periodStart,
    required this.revenue,
    required this.invoiceCount,
    required this.label,
    required this.fullLabel,
  });

  final DateTime periodStart;
  final num revenue;
  final int invoiceCount;

  /// Nhãn ngắn dưới cột (T7 / 12/7).
  final String label;

  /// Nhãn đầy đủ khi chạm cột (Tháng 7/2026 / Thứ 3 · 7/7).
  final String fullLabel;
}

class RevenueTypeSlice {
  const RevenueTypeSlice({required this.label, required this.revenue});

  final String label;
  final num revenue;
}

class TopRevenueItem {
  const TopRevenueItem({required this.name, required this.revenue});

  final String name;
  final num revenue;
}

// ===== Riverpod providers =====

final revenueRepositoryProvider = Provider<RevenueRepository>((ref) {
  return RevenueRepository(Supabase.instance.client);
});

/// Báo cáo doanh thu theo tham số (tuần/tháng/ngày). family: đổi tham số
/// (đổi tab, chuyển tuần, chọn ngày) là tự tải lại đúng bộ dữ liệu.
final revenueReportProvider =
    FutureProvider.family<RevenueReport, RevenueQuery>((ref, query) {
  return ref.watch(revenueRepositoryProvider).getRevenueReport(query);
});
