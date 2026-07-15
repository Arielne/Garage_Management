import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class TechnicianScheduleScreen extends StatefulWidget {
  const TechnicianScheduleScreen({super.key});

  @override
  State<TechnicianScheduleScreen> createState() =>
      _TechnicianScheduleScreenState();
}

class _TechnicianScheduleScreenState extends State<TechnicianScheduleScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final mechanicData = await _supabase
          .from('mechanics')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (mechanicData != null) {
        final mechanicId = mechanicData['id'];

        // Lấy các lịch hẹn tương lai được gán cho thợ này
        final response = await _supabase
            .from('appointments')
            .select(
              '*, vehicles(license_plate, model), customers(full_name, phone)',
            )
            .eq('employee_id', mechanicId)
            .order('scheduled_at', ascending: true);

        if (mounted) {
          setState(() {
            _schedules = List<Map<String, dynamic>>.from(response);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Lỗi tải lịch làm việc: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: RefreshIndicator(
        onRefresh: _fetchSchedules,
        color: AppColors.accent,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
            : _schedules.isEmpty
            ? _buildEmptyState()
            : _buildScheduleList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lịch làm việc đang trống',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn chưa có lịch hẹn nào được phân công.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList() {
    // Nhóm các lịch hẹn theo ngày
    Map<String, List<Map<String, dynamic>>> groupedSchedules = {};
    for (var schedule in _schedules) {
      final scheduledAt = schedule['scheduled_at'] != null
          ? DateTime.parse(schedule['scheduled_at']).toLocal()
          : DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(scheduledAt);
      if (!groupedSchedules.containsKey(dateStr)) {
        groupedSchedules[dateStr] = [];
      }
      groupedSchedules[dateStr]!.add(schedule);
    }

    final sortedDates = groupedSchedules.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final dateKey = sortedDates[dateIndex];
        final daySchedules = groupedSchedules[dateKey]!;
        final dateObj = DateTime.parse(dateKey);
        final isToday = _isSameDay(dateObj, DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16, top: 8),
              child: Row(
                children: [
                  Text(
                    isToday
                        ? 'Hôm nay'
                        : DateFormat('EEEE, dd/MM', 'vi').format(dateObj),
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isToday
                          ? AppColors.accent
                          : AppColors.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...daySchedules.asMap().entries.map((entry) {
              final index = entry.key;
              final schedule = entry.value;
              final isLast = index == daySchedules.length - 1;

              final scheduledAt = DateTime.parse(
                schedule['scheduled_at'],
              ).toLocal();
              final timeStr = DateFormat('HH:mm').format(scheduledAt);
              final vehicleModel =
                  schedule['vehicles']?['model'] ?? 'Xe chưa rõ';
              final vehiclePlate =
                  schedule['vehicles']?['license_plate'] ?? 'Chưa rõ biển số';
              final customerName =
                  schedule['customers']?['full_name'] ?? 'Khách lẻ';

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cột Timeline
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 24),
                          decoration: BoxDecoration(
                            color: isToday ? AppColors.accent : Colors.white,
                            border: Border.all(
                              color: isToday
                                  ? AppColors.accent
                                  : AppColors.borderSubtle,
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast || dateIndex < sortedDates.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: AppColors.borderSubtle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Thẻ thông tin
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AppCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      timeStr,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'SÁNG', // Tạm thời hardcode hoặc tính toán AM/PM
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppColors.divider,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        vehicleModel,
                                        style: GoogleFonts.sora(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vehiclePlate,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: AppColors.textTertiary,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              customerName,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
