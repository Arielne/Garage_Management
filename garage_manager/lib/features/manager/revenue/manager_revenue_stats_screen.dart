import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';
import 'revenue_repository.dart';

/// D10: Thống kê doanh thu.
/// - Tab Tuần: 7 cột ngày của 1 tuần, có nút ← → chuyển tuần.
/// - Tab Tháng: 6 cột tháng gần nhất.
/// - Nút lịch 📅: xem doanh thu 1 ngày bất kỳ.
class ManagerRevenueStatsScreen extends ConsumerStatefulWidget {
  const ManagerRevenueStatsScreen({super.key});

  @override
  ConsumerState<ManagerRevenueStatsScreen> createState() =>
      _ManagerRevenueStatsScreenState();
}

class _ManagerRevenueStatsScreenState
    extends ConsumerState<ManagerRevenueStatsScreen> {
  RevenueRange _range = RevenueRange.month;
  DateTime _weekStart = RevenueRepository.mondayOf(DateTime.now());
  DateTime? _selectedDay;

  RevenueQuery get _query {
    if (_selectedDay != null) {
      return (range: _range, weekStart: null, day: _selectedDay);
    }
    return (
      range: _range,
      weekStart: _range == RevenueRange.week ? _weekStart : null,
      day: null,
    );
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Chọn ngày xem doanh thu',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDay = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(revenueReportProvider(_query));

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Thống kê doanh thu'),
        actions: [
          IconButton(
            tooltip: 'Chọn ngày',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: _pickDay,
          ),
        ],
      ),
      body: reportAsync.when(
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
                      ref.invalidate(revenueReportProvider(_query)),
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
          onRefresh: () => ref.refresh(revenueReportProvider(_query).future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Chế độ ngày -> chip ngày; còn lại -> segmented Tuần/Tháng.
              if (report.isDay)
                _SelectedDayChip(
                  day: report.day!,
                  onClear: () => setState(() => _selectedDay = null),
                )
              else
                _RangeSelector(
                  selectedRange: _range,
                  onChanged: (range) => setState(() {
                    _range = range;
                    // Vào tab Tuần luôn bắt đầu từ tuần hiện tại cho dễ đoán.
                    if (range == RevenueRange.week) {
                      _weekStart = RevenueRepository.mondayOf(DateTime.now());
                    }
                  }),
                ),
              // Thanh chuyển tuần (chỉ ở tab Tuần).
              if (report.isWeek) ...[
                const SizedBox(height: 12),
                _WeekNavigator(
                  weekStart: report.weekStart!,
                  onPrev: () => setState(
                    () => _weekStart =
                        _weekStart.subtract(const Duration(days: 7)),
                  ),
                  onNext: _canGoNextWeek()
                      ? () => setState(
                            () => _weekStart =
                                _weekStart.add(const Duration(days: 7)),
                          )
                      : null,
                ),
              ],
              // Tab Tháng cộng nhiều tháng chứ không phải tháng hiện tại.
              // Không ghi ra thì lệch với thẻ "Doanh thu tháng này" bên D1.
              // Thẻ chỉ rộng 1/3 màn (maxLines 1) nên để kỳ ở ngoài thẻ.
              if (!report.isWeek && !report.isDay && report.points.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Cộng ${report.points.length} tháng: '
                  '${report.points.first.fullLabel} – ${report.points.last.fullLabel}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _SummaryGrid(report: report),
              const SizedBox(height: 16),
              if (!report.isDay) ...[
                _RevenueBarChartCard(points: report.points),
                const SizedBox(height: 16),
              ],
              _RevenueMixCard(slices: report.slices),
              const SizedBox(height: 16),
              _TopRevenueCard(items: report.topItems),
            ],
          ),
        ),
      ),
    );
  }

  bool _canGoNextWeek() {
    final thisWeek = RevenueRepository.mondayOf(DateTime.now());
    return _weekStart.isBefore(thisWeek);
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

/// Thanh ← Tuần dd/mm – dd/mm → để chuyển qua lại giữa các tuần.
class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({
    required this.weekStart,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime weekStart;
  final VoidCallback onPrev;
  final VoidCallback? onNext; // null = đã là tuần hiện tại -> khoá nút tiến

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final label =
        'Tuần ${weekStart.day}/${weekStart.month} – ${weekEnd.day}/${weekEnd.month}';

    return AppCard(
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.accent,
            tooltip: 'Tuần trước',
          ),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: onNext == null ? AppColors.textTertiary : AppColors.accent,
            tooltip: 'Tuần sau',
          ),
        ],
      ),
    );
  }
}

class _SelectedDayChip extends StatelessWidget {
  const _SelectedDayChip({required this.day, required this.onClear});

  final DateTime day;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 7, 10, 7),
          decoration: BoxDecoration(
            color: AppColors.accentSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.accent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 15,
                color: AppColors.accent,
              ),
              const SizedBox(width: 7),
              Text(
                _fullDayLabel(day),
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 7),
              const Icon(Icons.close, size: 15, color: AppColors.accent),
            ],
          ),
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
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _SummaryCard(
          icon: Icons.payments_outlined,
          label: report.isDay
              ? 'Doanh thu ${report.day!.day}/${report.day!.month}'
              : 'Tổng doanh thu',
          value: _formatMoney(report.totalRevenue),
          color: AppColors.accent,
        ),
        _SummaryCard(
          icon: Icons.receipt_long_outlined,
          label: report.isDay ? 'Hóa đơn trong ngày' : 'Số hóa đơn',
          value: report.invoiceCount.toString(),
          color: AppColors.textPrimary,
        ),
        _SummaryCard(
          icon: Icons.show_chart_outlined,
          label: 'TB/hóa đơn',
          value: _formatMoney(report.averageInvoice),
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

/// Biểu đồ cột — chạm vào cột để xem số cụ thể của kỳ đó.
class _RevenueBarChartCard extends StatefulWidget {
  const _RevenueBarChartCard({required this.points});

  final List<RevenuePoint> points;

  @override
  State<_RevenueBarChartCard> createState() => _RevenueBarChartCardState();
}

class _RevenueBarChartCardState extends State<_RevenueBarChartCard> {
  int? _selectedIndex;

  @override
  void didUpdateWidget(_RevenueBarChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _selectedIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final points = widget.points;
    final hasData = points.any((point) => point.revenue > 0);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Doanh thu theo thời gian',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'Chạm cột để xem số',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Chưa có doanh thu trong kỳ này',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else ...[
            _SelectedBarInfo(
              point: points[_selectedIndex ?? _defaultIndex(points)],
            ),
            const SizedBox(height: 10),
          ],
          if (points.isNotEmpty) ...[
            SizedBox(
              height: 150,
              child: _InteractiveBars(
                points: points,
                selectedIndex: _selectedIndex ?? _defaultIndex(points),
                onTap: (index) => setState(() => _selectedIndex = index),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final point in points)
                  Expanded(
                    child: Text(
                      point.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Mặc định chọn cột có doanh thu gần nhất (cuối danh sách), nếu không có
  /// thì cột cuối.
  int _defaultIndex(List<RevenuePoint> points) {
    for (var i = points.length - 1; i >= 0; i--) {
      if (points[i].revenue > 0) return i;
    }
    return points.length - 1;
  }
}

class _SelectedBarInfo extends StatelessWidget {
  const _SelectedBarInfo({required this.point});

  final RevenuePoint point;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              point.fullLabel,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${_formatMoney(point.revenue)} · ${point.invoiceCount} HĐ',
            style: GoogleFonts.robotoMono(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveBars extends StatelessWidget {
  const _InteractiveBars({
    required this.points,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<RevenuePoint> points;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.fold<num>(
      0,
      (max, point) => point.revenue > max ? point.revenue : max,
    );
    final safeMax = maxValue == 0 ? 1 : maxValue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var index = 0; index < points.length; index++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor:
                      (points[index].revenue / safeMax).clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: index == selectedIndex
                          ? AppColors.accent
                          : AppColors.accentSoft,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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

const _weekdays = {
  1: 'Thứ 2',
  2: 'Thứ 3',
  3: 'Thứ 4',
  4: 'Thứ 5',
  5: 'Thứ 6',
  6: 'Thứ 7',
  7: 'Chủ nhật',
};

String _fullDayLabel(DateTime day) {
  final dd = day.day.toString().padLeft(2, '0');
  final mm = day.month.toString().padLeft(2, '0');
  return '${_weekdays[day.weekday]}, $dd/$mm/${day.year}';
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
