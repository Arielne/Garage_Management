import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingJobs();
  }

  // Kéo danh sách phiếu đang ở trạng thái chờ nhận (pending)
  Future<void> _fetchPendingJobs() async {
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

        final response = await _supabase
            .from('work_orders')
            .select('*, vehicles(license_plate, model), customers(full_name)')
            .eq('employee_id', mechanicId)
            .eq('status', 'cho_nhan')
            .order('created_at', ascending: false);

        if (mounted) {
          setState(() {
            _pendingJobs = List<Map<String, dynamic>>.from(response);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải thông báo: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm xử lý khi thợ bấm nút Nhận việc
  Future<void> _acceptJob(int workOrderId) async {
    try {
      // Khi thợ bấm xác nhận, chuyển trạng thái từ 'cho_nhan' sang 'dang_xu_ly'
      await _supabase
          .from('work_orders')
          .update({'status': 'dang_xu_ly'})
          .eq('id', workOrderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã xác nhận nhận việc thành công! Phiếu đã chuyển sang mục Phiếu của tôi.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _fetchPendingJobs(); // Tải lại danh sách để làm mất cái phiếu vừa nhận
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi nhận việc: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Thông báo & Nhận việc',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _pendingJobs.isEmpty
          ? Center(
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
                      Icons.notifications_none_rounded,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bạn đã hoàn thành hết việc!',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có công việc mới nào cần nhận.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchPendingJobs,
              color: AppColors.accent,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _pendingJobs.length,
                itemBuilder: (context, index) {
                  final job = _pendingJobs[index];
                  final vehicleModel =
                      job['vehicles']?['model'] ?? 'Xe chưa rõ';
                  final vehiclePlate =
                      job['vehicles']?['license_plate'] ?? 'Chưa rõ biển số';
                  final customerName =
                      job['customers']?['full_name'] ?? 'Khách lẻ';
                  final description = job['description'] ?? 'Không có ghi chú';

                  final rawDate = job['created_at'] != null
                      ? DateTime.parse(job['created_at']).toLocal()
                      : DateTime.now();
                  final formattedDate = DateFormat(
                    'HH:mm • dd/MM/yyyy',
                  ).format(rawDate);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.08),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: AppCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'YÊU CẦU MỚI',
                                    style: GoogleFonts.sora(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              vehicleModel,
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vehiclePlate,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Khách hàng: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  customerName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.bgApp,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      description,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: AppColors.textPrimary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () => _acceptJob(job['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  'XÁC NHẬN NHẬN VIỆC',
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
