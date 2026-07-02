import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

enum _RevenueRange { week, month, quarter }

const _reports = {
  _RevenueRange.week: _RevenueReport(
    totalRevenue: 18450000,
    invoiceCount: 9,
    averageInvoice: 2050000,
    barPoints: [
      _ChartPoint(label: 'T2', value: 1800000),
      _ChartPoint(label: 'T3', value: 2450000),
      _ChartPoint(label: 'T4', value: 3200000),
      _ChartPoint(label: 'T5', value: 2100000),
      _ChartPoint(label: 'T6', value: 3950000),
      _ChartPoint(label: 'T7', value: 2850000),
      _ChartPoint(label: 'CN', value: 2100000),
    ],
    slices: [
      _RevenueSlice(label: 'Dịch vụ', value: 8200000, color: AppColors.accent),
      _RevenueSlice(label: 'Phụ tùng', value: 6650000, color: AppColors.statusDone),
      _RevenueSlice(label: 'Bộ kit', value: 3600000, color: AppColors.statusWait),
    ],
    topItems: [
      _TopRevenueItem(name: 'Thay nhớt & bảo dưỡng nhanh', value: '4.250.000đ'),
      _TopRevenueItem(name: 'Nhông sên dĩa DID', value: '3.800.000đ'),
      _TopRevenueItem(name: 'Vệ sinh kim phun', value: '2.100.000đ'),
    ],
  ),
  _RevenueRange.month: _RevenueReport(
    totalRevenue: 74200000,
    invoiceCount: 34,
    averageInvoice: 2180000,
    barPoints: [
      _ChartPoint(label: 'T1', value: 14200000),
      _ChartPoint(label: 'T2', value: 16800000),
      _ChartPoint(label: 'T3', value: 12800000),
      _ChartPoint(label: 'T4', value: 18400000),
      _ChartPoint(label: 'T5', value: 12000000),
    ],
    slices: [
      _RevenueSlice(label: 'Dịch vụ', value: 31400000, color: AppColors.accent),
      _RevenueSlice(label: 'Phụ tùng', value: 26800000, color: AppColors.statusDone),
      _RevenueSlice(label: 'Bộ kit', value: 16000000, color: AppColors.statusWait),
    ],
    topItems: [
      _TopRevenueItem(name: 'Bộ Kit Nâng Cấp Piston 62zz', value: '18.000.000đ'),
      _TopRevenueItem(name: 'Phuộc RCB C Series', value: '9.600.000đ'),
      _TopRevenueItem(name: 'Công kiểm tra tổng quát', value: '8.500.000đ'),
    ],
  ),
  _RevenueRange.quarter: _RevenueReport(
    totalRevenue: 205600000,
    invoiceCount: 91,
    averageInvoice: 2260000,
    barPoints: [
      _ChartPoint(label: 'T4', value: 58200000),
      _ChartPoint(label: 'T5', value: 68100000),
      _ChartPoint(label: 'T6', value: 79300000),
    ],
    slices: [
      _RevenueSlice(label: 'Dịch vụ', value: 81200000, color: AppColors.accent),
      _RevenueSlice(label: 'Phụ tùng', value: 76200000, color: AppColors.statusDone),
      _RevenueSlice(label: 'Bộ kit', value: 48200000, color: AppColors.statusWait),
    ],
    topItems: [
      _TopRevenueItem(name: 'Gói nâng cấp hiệu năng', value: '48.200.000đ'),
      _TopRevenueItem(name: 'Bảo dưỡng định kỳ', value: '32.800.000đ'),
      _TopRevenueItem(name: 'Sửa chữa hao mòn', value: '27.400.000đ'),
    ],
  ),
};

class ManagerRevenueStatsScreen extends StatefulWidget {
  const ManagerRevenueStatsScreen({super.key});

  @override
  State<ManagerRevenueStatsScreen> createState() =>
      _ManagerRevenueStatsScreenState();
}

class _ManagerRevenueStatsScreenState extends State<ManagerRevenueStatsScreen> {
  _RevenueRange _selectedRange = _RevenueRange.month;

  @override
  Widget build(BuildContext context) {
    final report = _reports[_selectedRange]!;

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(title: const Text('Thống kê doanh thu')),
      body: ListView(
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
          _RevenueBarChartCard(points: report.barPoints),
          const SizedBox(height: 16),
          _RevenueMixCard(slices: report.slices),
          const SizedBox(height: 16),
          _TopRevenueCard(items: report.topItems),
        ],
      ),
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selectedRange,
    required this.onChanged,
  });

  final _RevenueRange selectedRange;
  final ValueChanged<_RevenueRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_RevenueRange>(
      showSelectedIcon: false,
      selected: {selectedRange},
      onSelectionChanged: (ranges) => onChanged(ranges.first),
      segments: const [
        ButtonSegment(value: _RevenueRange.week, label: Text('Tuần')),
        ButtonSegment(value: _RevenueRange.month, label: Text('Tháng')),
        ButtonSegment(value: _RevenueRange.quarter, label: Text('Quý')),
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

  final _RevenueReport report;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.65,
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
        const _SummaryCard(
          icon: Icons.trending_up_outlined,
          label: 'Tăng trưởng',
          value: '+12%',
          color: AppColors.statusDone,
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
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoMono(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
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

  final List<_ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<int>(
      0,
      (max, point) => point.value > max ? point.value : max,
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
      ),
    );
  }
}

class _RevenueMixCard extends StatelessWidget {
  const _RevenueMixCard({required this.slices});

  final List<_RevenueSlice> slices;

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.value);

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
                        value: _formatCompactMoney(slice.value),
                        color: slice.color,
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

  final List<_TopRevenueItem> items;

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
  final _TopRevenueItem item;

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
          item.value,
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

  final List<_ChartPoint> points;
  final int maxValue;

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
      final normalized = point.value / maxValue;
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

  final List<_RevenueSlice> slices;
  final int total;

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
      final sweepAngle = (slice.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = slice.color
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

class _RevenueReport {
  const _RevenueReport({
    required this.totalRevenue,
    required this.invoiceCount,
    required this.averageInvoice,
    required this.barPoints,
    required this.slices,
    required this.topItems,
  });

  final int totalRevenue;
  final int invoiceCount;
  final int averageInvoice;
  final List<_ChartPoint> barPoints;
  final List<_RevenueSlice> slices;
  final List<_TopRevenueItem> topItems;
}

class _ChartPoint {
  const _ChartPoint({required this.label, required this.value});

  final String label;
  final int value;
}

class _RevenueSlice {
  const _RevenueSlice({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class _TopRevenueItem {
  const _TopRevenueItem({required this.name, required this.value});

  final String name;
  final String value;
}

String _formatMoney(int value) {
  final raw = value.toString();
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

String _formatCompactMoney(int value) {
  final millionValue = value / 1000000;
  final text = millionValue.toStringAsFixed(millionValue % 1 == 0 ? 0 : 1);
  return '${text.replaceAll('.', ',')}trđ';
}
