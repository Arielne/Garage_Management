import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import 'revenue_repository.dart';

/// D10: Thống kê doanh thu.
/// Dữ liệu lấy từ Supabase qua revenueReportProvider (loading/error/data):
/// v_revenue_by_day/week/month (biểu đồ cột), v_revenue_by_type (donut cơ cấu).
class ManagerRevenueStatsScreen extends ConsumerStatefulWidget {
  const ManagerRevenueStatsScreen({super.key});

  @override
  ConsumerState<ManagerRevenueStatsScreen> createState() =>
      _ManagerRevenueStatsScreenState();
}

class _ManagerRevenueStatsScreenState
    extends ConsumerState<ManagerRevenueStatsScreen> {
  RevenueRange _selectedRange = RevenueRange.month;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(revenueReportProvider(_selectedRange));

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(title: const Text('Thống kê doanh thu')),
      body: reportAsync.when(
        // Loading page: spinner màu accent trong lúc chờ Supabase.
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 40,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Không tải được thống kê.\nKiểm tra kết nối mạng rồi thử lại.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () =>
                      ref.invalidate(revenueReportProvider(_selectedRange)),
                  icon: const Icon(Icons.refresh, color: AppColors.accent),
                  label: Text(
                    'Thử lại',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (report) => RefreshIndicator(
          color: AppColors.accent,
          onRefresh: () =>
              ref.refresh(revenueReportProvider(_selectedRange).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RangeSelector(
                selectedRange: _selectedRange,
                onChanged: (range) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              ),
              const SizedBox(height: 16),
              _SummaryGrid(report: report),
              const SizedBox(height: 16),
              _RevenueBarChartCard(points: report.points),
              const SizedBox(height: 16),
              _RevenueMixCard(slices: report.slices),
              const SizedBox(height: 16),
              _TopRevenueCard(items: report.topItems),
            ],
          ),
        ),
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  final RevenueRange selectedRange;
  final ValueChanged<RevenueRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RevenueRange>(
      showSelectedIcon: false,
      selected: {selectedRange},
      onSelectionChanged: (ranges) => onChanged(ranges.first),
      segments: const [
        ButtonSegment(value: RevenueRange.day, label: Text('Ngày')),
        ButtonSegment(value: RevenueRange.week, label: Text('Tuần')),
        ButtonSegment(value: RevenueRange.month, label: Text('Tháng')),
      ],
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.textSecondary;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent;
          }
          return AppColors.surfaceCard;
        }),
        side: const WidgetStatePropertyAll(
          BorderSide(color: AppColors.borderSubtle),
        ),
        textStyle: WidgetStatePropertyAll(
          GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.report});

  final RevenueReport report;

  @override
  Widget build(BuildContext context) {
    final growth = report.growthPercent;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      // 1.65 làm thẻ thấp hơn nội dung ~3px trên một số máy -> tràn đáy.
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          icon: Icons.payments_outlined,
          label: 'Tổng doanh thu',
          value: _formatMoney(report.totalRevenue),
          color: AppColors.accent,
        ),
        _SummaryCard(
          icon: Icons.receipt_long_outlined,
          label: 'Số hóa đơn',
          value: report.invoiceCount.toString(),
          color: AppColors.textPrimary,
        ),
        _SummaryCard(
          icon: Icons.show_chart_outlined,
          label: 'Trung bình',
          value: _formatMoney(report.averageInvoice),
          color: AppColors.statusDone,
        ),
        _SummaryCard(
          icon: Icons.trending_up_outlined,
          label: 'Tăng trưởng',
          value: growth == null
              ? '—'
              : '${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}%',
          color:
              (growth ?? 0) >= 0 ? AppColors.statusDone : AppColors.statusError,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          // FittedBox: số tiền dài tự co lại cho vừa thẻ, không tràn pixel.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBarChartCard extends StatelessWidget {
  const _RevenueBarChartCard({required this.points});

  final List<RevenuePoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<num>(
      0,
      (max, point) => point.revenue > max ? point.revenue : max,
    );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doanh thu theo thời gian',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (points.isEmpty)
            Text(
              'Chưa có dữ liệu doanh thu',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else ...[
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _BarChartPainter(
                  points: points,
                  maxValue: maxValue == 0 ? 1 : maxValue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final point in points)
                  Text(
                    point.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RevenueMixCard extends StatelessWidget {
  const _RevenueMixCard({required this.slices});

  final List<RevenueTypeSlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<num>(0, (sum, slice) => sum + slice.revenue);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cơ cấu doanh thu',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (total == 0)
            Text(
              'Chưa có dữ liệu cơ cấu doanh thu',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CustomPaint(
                    painter: _DonutChartPainter(slices: slices, total: total),
                    child: Center(
                      child: Text(
                        _formatCompactMoney(total),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      for (final slice in slices)
                        _SliceLegend(
                          label: slice.label,
                          value: _formatCompactMoney(slice.revenue),
                          color: _sliceColor(slice.label),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SliceLegend extends StatelessWidget {
  const _SliceLegend({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopRevenueCard extends StatelessWidget {
  const _TopRevenueCard({required this.items});

  final List<TopRevenueItem> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hạng mục nổi bật',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'Chưa có hạng mục nào',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          for (var index = 0; index < items.length; index++) ...[
            _TopRevenueRow(index: index + 1, item: items[index]),
            if (index < items.length - 1)
              const Divider(height: 18, color: AppColors.divider),
          ],
        ],
      ),
    );
  }
}

class _TopRevenueRow extends StatelessWidget {
  const _TopRevenueRow({required this.index, required this.item});

  final int index;
  final TopRevenueItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.accentSoft,
          child: Text(
            index.toString(),
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.name,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _formatMoney(item.revenue),
          style: GoogleFonts.robotoMono(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({required this.points, required this.maxValue});

  final List<RevenuePoint> points;
  final num maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    final mutedPaint = Paint()..color = AppColors.accentSoft;
    final activePaint = Paint()..color = AppColors.accent;

    for (var index = 0; index <= 4; index++) {
      final y = size.height * index / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) {
      return;
    }

    final slotWidth = size.width / points.length;
    final barWidth = slotWidth * 0.44;
    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final normalized = point.revenue / maxValue;
      final barHeight = size.height * normalized.clamp(0.0, 1.0);
      final left = index * slotWidth + (slotWidth - barWidth) / 2;
      final top = size.height - barHeight;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(
        rect,
        index == points.length - 1 ? activePaint : mutedPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.maxValue != maxValue;
  }
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter({required this.slices, required this.total});

  final List<RevenueTypeSlice> slices;
  final num total;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final strokeWidth = radius * 0.32;
    var startAngle = -math.pi / 2;

    for (final slice in slices) {
      if (slice.revenue <= 0) continue;
      final sweepAngle = (slice.revenue / total) * math.pi * 2;
      final paint = Paint()
        ..color = _sliceColor(slice.label)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices || oldDelegate.total != total;
  }
}

Color _sliceColor(String label) {
  switch (label) {
    case 'Dịch vụ':
      return AppColors.accent;
    case 'Phụ tùng':
      return AppColors.statusDone;
    case 'Bộ kit':
      return AppColors.statusWait;
    default:
      return AppColors.textSecondary;
  }
}

String _formatMoney(num value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return '$bufferđ';
}

String _formatCompactMoney(num value) {
  final millionValue = value / 1000000;
  final text = millionValue.toStringAsFixed(millionValue % 1 == 0 ? 0 : 1);
  return '${text.replaceAll('.', ',')}trđ';
}
