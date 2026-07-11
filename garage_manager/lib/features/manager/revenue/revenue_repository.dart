import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Khoảng thống kê của D10: theo ngày / tuần / tháng.
/// Mỗi khoảng ứng với 1 view riêng trong Supabase (cùng công thức).
enum RevenueRange { day, week, month }

/// Repository doanh thu (D10, sau này D1 dùng chung) — đọc các view báo cáo:
/// - v_revenue_by_day / v_revenue_by_week / v_revenue_by_month
///   (chỉ tính hóa đơn da_thanh_toan)
/// - v_revenue_by_type : cơ cấu Dịch vụ / Phụ tùng / Bộ kit
/// Hạng mục nổi bật gộp từ work_order_services + work_order_parts
/// của các phiếu đã thanh toán (chỉ ĐỌC bảng của Vỹ, không sửa).
class RevenueRepository {
  RevenueRepository(this._client);

  final SupabaseClient _client;

  Future<RevenueReport> getRevenueReport(RevenueRange range) async {
    final (viewName, periodColumn, pointLimit) = switch (range) {
      RevenueRange.day => ('v_revenue_by_day', 'day', 7),
      RevenueRange.week => ('v_revenue_by_week', 'week', 8),
      RevenueRange.month => ('v_revenue_by_month', 'month', 6),
    };

    final results = await Future.wait<List<Map<String, dynamic>>>([
      // Lấy N kỳ gần nhất: sắp giảm dần + limit, lát nữa đảo lại cho biểu đồ.
      _client
          .from(viewName)
          .select()
          .order(periodColumn, ascending: false)
          .limit(pointLimit),
      _client.from('v_revenue_by_type').select(),
    ]);

    final periodRows = results[0].reversed.toList();
    final typeRows = results[1];
    final paidWorkOrderIds = await _paidWorkOrderIds();

    final points = [
      for (final row in periodRows)
        RevenuePoint(
          periodStart:
              DateTime.parse(row[periodColumn] as String).toLocal(),
          range: range,
          revenue: _toNum(row['revenue']),
          invoiceCount: (row['invoice_count'] ?? 0) as int,
        ),
    ];

    final slices = [
      for (final row in typeRows)
        RevenueTypeSlice(
          label: (row['type'] ?? '') as String,
          revenue: _toNum(row['revenue']),
        ),
    ];

    final topItems = await _getTopItems(paidWorkOrderIds);

    return RevenueReport(
      points: points,
      slices: slices,
      topItems: topItems,
    );
  }

  /// Id các phiếu công việc đã thanh toán — doanh thu chỉ tính từ đây.
  Future<List<int>> _paidWorkOrderIds() async {
    final rows = await _client
        .from('invoices')
        .select('work_order_id')
        .eq('status', 'da_thanh_toan');
    return [
      for (final row in rows)
        if (row['work_order_id'] != null) row['work_order_id'] as int,
    ];
  }

  /// Top 3 hạng mục doanh thu cao nhất (dịch vụ + phụ tùng gộp theo tên).
  Future<List<TopRevenueItem>> _getTopItems(List<int> workOrderIds) async {
    if (workOrderIds.isEmpty) return const [];

    final results = await Future.wait([
      _client
          .from('work_order_services')
          .select('name, labor_price')
          .inFilter('work_order_id', workOrderIds),
      _client
          .from('work_order_parts')
          .select('name, quantity, unit_price')
          .inFilter('work_order_id', workOrderIds),
    ]);

    final revenueByName = <String, num>{};
    for (final row in results[0]) {
      final name = (row['name'] ?? '') as String;
      revenueByName[name] =
          (revenueByName[name] ?? 0) + _toNum(row['labor_price']);
    }
    for (final row in results[1]) {
      final name = (row['name'] ?? '') as String;
      final amount = _toNum(row['unit_price']) * ((row['quantity'] ?? 1) as int);
      revenueByName[name] = (revenueByName[name] ?? 0) + amount;
    }

    final items = revenueByName.entries
        .map((entry) => TopRevenueItem(name: entry.key, revenue: entry.value))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    return items.take(3).toList();
  }

  num _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '') ?? 0;
  }
}

// ===== Model báo cáo =====

class RevenueReport {
  const RevenueReport({
    required this.points,
    required this.slices,
    required this.topItems,
  });

  final List<RevenuePoint> points;
  final List<RevenueTypeSlice> slices;
  final List<TopRevenueItem> topItems;

  num get totalRevenue =>
      points.fold<num>(0, (sum, point) => sum + point.revenue);

  int get invoiceCount =>
      points.fold<int>(0, (sum, point) => sum + point.invoiceCount);

  num get averageInvoice => invoiceCount == 0 ? 0 : totalRevenue / invoiceCount;

  /// % tăng trưởng tháng gần nhất so với tháng trước; null nếu chưa đủ 2 tháng.
  double? get growthPercent {
    if (points.length < 2) return null;
    final previous = points[points.length - 2].revenue;
    if (previous == 0) return null;
    final latest = points.last.revenue;
    return (latest - previous) / previous * 100;
  }
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
        // Ngày: 12/7 · Tuần: lấy ngày đầu tuần 6/7 · Tháng: T7
        RevenueRange.day => '${periodStart.day}/${periodStart.month}',
        RevenueRange.week => '${periodStart.day}/${periodStart.month}',
        RevenueRange.month => 'T${periodStart.month}',
      };
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

/// Báo cáo doanh thu theo khoảng (ngày/tuần/tháng) — family: mỗi khoảng
/// là 1 provider riêng nên đổi tab không phải tải lại tab cũ.
final revenueReportProvider =
    FutureProvider.family<RevenueReport, RevenueRange>((ref, range) {
  return ref.watch(revenueRepositoryProvider).getRevenueReport(range);
});
