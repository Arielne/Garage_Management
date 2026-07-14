import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Khoảng thống kê của D10: theo ngày / tuần / tháng.
/// Mỗi khoảng ứng với 1 view riêng trong Supabase (cùng công thức).
enum RevenueRange { day, week, month }

/// Tham số truy vấn D10: khoảng (ngày/tuần/tháng) HOẶC 1 ngày cụ thể do
/// người dùng chọn từ lịch (Phương án B). Dùng làm key cho provider.family —
/// record Dart có sẵn so sánh theo giá trị nên đổi tham số là tự tải lại.
typedef RevenueQuery = ({RevenueRange range, DateTime? day});

/// Repository doanh thu (D10) — mọi khối trên màn cùng lấy theo 1 khoảng
/// thời gian nên số liệu nhất quán:
/// - Biểu đồ cột: view v_revenue_by_day / week / month (chỉ chế độ khoảng).
/// - Thẻ tổng quan: cộng từ bảng invoices trong khoảng.
/// - Donut cơ cấu + Hạng mục nổi bật: RPC revenue_type_between /
///   revenue_top_items_between (đọc bảng của Vỹ + Trường, không sửa).
class RevenueRepository {
  RevenueRepository(this._client);

  final SupabaseClient _client;

  Future<RevenueReport> getRevenueReport(RevenueQuery query) async {
    final day = query.day;

    // 1. Xác định khoảng [start, end) + các cột biểu đồ.
    final DateTime start;
    final DateTime end;
    List<RevenuePoint> points;

    if (day != null) {
      // Chế độ 1 ngày: cả màn chỉ tính đúng ngày đó, không vẽ nhiều cột.
      start = DateTime(day.year, day.month, day.day);
      end = start.add(const Duration(days: 1));
      points = const [];
    } else {
      final (viewName, periodColumn, pointLimit) = switch (query.range) {
        RevenueRange.day => ('v_revenue_by_day', 'day', 7),
        RevenueRange.week => ('v_revenue_by_week', 'week', 8),
        RevenueRange.month => ('v_revenue_by_month', 'month', 6),
      };

      final rows = await _client
          .from(viewName)
          .select()
          .order(periodColumn, ascending: false)
          .limit(pointLimit);
      final ordered = rows.reversed.toList();

      points = [
        for (final row in ordered)
          RevenuePoint(
            periodStart:
                DateTime.parse(row[periodColumn] as String).toLocal(),
            range: query.range,
            revenue: _toNum(row['revenue']),
            invoiceCount: (row['invoice_count'] ?? 0) as int,
          ),
      ];

      // Khoảng = từ đầu kỳ cũ nhất đang hiện tới hiện tại -> thẻ tổng quan,
      // donut, hạng mục đều khớp đúng các cột trên biểu đồ.
      start = points.isEmpty
          ? DateTime.fromMillisecondsSinceEpoch(0)
          : points.first.periodStart;
      end = DateTime.now().add(const Duration(days: 1));
    }

    final startIso = start.toUtc().toIso8601String();
    final endIso = end.toUtc().toIso8601String();

    // 2. Thẻ tổng quan + phương thức thanh toán: từ invoices trong khoảng.
    final invoiceRows = await _client
        .from('invoices')
        .select('total, payment_method')
        .eq('status', 'da_thanh_toan')
        .gte('created_at', startIso)
        .lt('created_at', endIso);

    num totalRevenue = 0;
    for (final row in invoiceRows) {
      totalRevenue += _toNum(row['total']);
    }
    final invoiceCount = invoiceRows.length;

    // 3. Donut cơ cấu + Hạng mục nổi bật: 2 RPC lọc theo cùng khoảng.
    final typeRows = await _client.rpc(
      'revenue_type_between',
      params: {'p_start': startIso, 'p_end': endIso},
    ) as List;
    final topRows = await _client.rpc(
      'revenue_top_items_between',
      params: {'p_start': startIso, 'p_end': endIso, 'p_limit': 3},
    ) as List;

    // RPC trả doanh thu hạng mục TRƯỚC thuế/giảm giá. Ta giữ đúng TỈ LỆ
    // giữa Dịch vụ/Phụ tùng/Bộ kit nhưng nhân lại cho khớp Tổng doanh thu
    // (đã gồm thuế 8%, đã trừ giảm giá) -> donut cộng ra đúng bằng thẻ tổng.
    final rawSlices = [
      for (final row in typeRows)
        RevenueTypeSlice(
          label: (row['type'] ?? '') as String,
          revenue: _toNum(row['revenue']),
        ),
    ];
    final rawSum = rawSlices.fold<num>(0, (sum, s) => sum + s.revenue);
    final slices = (rawSum > 0 && totalRevenue > 0)
        ? [
            for (final s in rawSlices)
              RevenueTypeSlice(
                label: s.label,
                revenue: s.revenue / rawSum * totalRevenue,
              ),
          ]
        : rawSlices;

    // Hạng mục nổi bật cũng scale theo cùng hệ số cho đồng bộ với donut.
    final scale = (rawSum > 0 && totalRevenue > 0) ? totalRevenue / rawSum : 1;
    final topItems = [
      for (final row in topRows)
        TopRevenueItem(
          name: (row['name'] ?? '') as String,
          revenue: _toNum(row['revenue']) * scale,
        ),
    ];

    return RevenueReport(
      day: day,
      points: points,
      totalRevenue: totalRevenue,
      invoiceCount: invoiceCount,
      averageInvoice: invoiceCount == 0 ? 0 : totalRevenue / invoiceCount,
      growthPercent: _growthPercent(points),
      paymentSummary: _paymentSummary(invoiceRows),
      slices: slices,
      topItems: topItems,
    );
  }

  /// % tăng trưởng kỳ gần nhất so với kỳ liền trước (chỉ chế độ khoảng);
  /// null nếu chưa đủ 2 kỳ hoặc kỳ trước bằng 0.
  double? _growthPercent(List<RevenuePoint> points) {
    if (points.length < 2) return null;
    final previous = points[points.length - 2].revenue;
    if (previous == 0) return null;
    final latest = points.last.revenue;
    return (latest - previous) / previous * 100;
  }

  /// Gộp phương thức thanh toán trong ngày -> hiện ở thẻ thứ 4 (chế độ ngày).
  String _paymentSummary(List<Map<String, dynamic>> rows) {
    final methods = <String>{
      for (final row in rows)
        if (row['payment_method'] != null) row['payment_method'] as String,
    };
    if (methods.isEmpty) return '—';
    if (methods.length > 1) return 'TM + CK';
    return methods.first == 'tien_mat' ? 'Tiền mặt' : 'CK';
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ===== Model báo cáo =====

class RevenueReport {
  const RevenueReport({
    required this.day,
    required this.points,
    required this.totalRevenue,
    required this.invoiceCount,
    required this.averageInvoice,
    required this.growthPercent,
    required this.paymentSummary,
    required this.slices,
    required this.topItems,
  });

  /// Ngày cụ thể đang xem; null = đang xem theo khoảng (ngày/tuần/tháng).
  final DateTime? day;
  final List<RevenuePoint> points;
  final num totalRevenue;
  final int invoiceCount;
  final num averageInvoice;
  final double? growthPercent;
  final String paymentSummary;
  final List<RevenueTypeSlice> slices;
  final List<TopRevenueItem> topItems;

  bool get isDay => day != null;
}

class RevenuePoint {
  const RevenuePoint({
    required this.periodStart,
    required this.range,
    required this.revenue,
    required this.invoiceCount,
  });

  final DateTime periodStart;
  final RevenueRange range;
  final num revenue;
  final int invoiceCount;

  String get label => switch (range) {
        // Ngày & Tuần: hiện ngày đầu kỳ dd/M · Tháng: T{số}
        RevenueRange.day => '${periodStart.day}/${periodStart.month}',
        RevenueRange.week => '${periodStart.day}/${periodStart.month}',
        RevenueRange.month => 'T${periodStart.month}',
      };

  /// Nhãn đầy đủ để hiện khi người dùng chạm vào cột.
  String get fullLabel {
    final d = periodStart.day.toString().padLeft(2, '0');
    final m = periodStart.month.toString().padLeft(2, '0');
    return switch (range) {
      RevenueRange.day => 'Ngày $d/$m/${periodStart.year}',
      RevenueRange.week => 'Tuần từ $d/$m',
      RevenueRange.month => 'Tháng ${periodStart.month}/${periodStart.year}',
    };
  }
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

/// Báo cáo doanh thu theo tham số (khoảng hoặc 1 ngày) — family: mỗi tham số
/// là 1 provider riêng nên đổi tab / đổi ngày không phải tải lại cái cũ.
final revenueReportProvider =
    FutureProvider.family<RevenueReport, RevenueQuery>((ref, query) {
  return ref.watch(revenueRepositoryProvider).getRevenueReport(query);
});
