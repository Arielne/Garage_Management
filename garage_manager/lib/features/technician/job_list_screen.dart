import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../core/app_routes.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _myJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchMyJobs();
  }

  Future<void> _fetchMyJobs() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final mechanicData = await _supabase
          .from('mechanics')
          .select('id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (mechanicData == null) {
        debugPrint('Không tìm thấy bản ghi thợ cho user: ${user.id}');
        if (mounted) {
          setState(() {
            _myJobs = [];
            _isLoading = false;
          });
        }
        return;
      }

      final mechanicId = mechanicData['id'];

      // Lấy danh sách phiếu công việc của thợ này
      // Hiển thị các phiếu đang xử lý hoặc đã hoàn thành (nhưng chưa bàn giao)
      final response = await _supabase
          .from('work_orders')
          .select('*, vehicles(license_plate, model), customers(full_name)')
          .eq('employee_id', mechanicId)
          .inFilter('status', ['dang_xu_ly', 'hoan_thanh'])
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _myJobs = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải danh sách công việc: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchMyJobs,
      color: AppColors.accent,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (_myJobs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.accentSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hiện tại chưa có phiếu sửa chữa nào.',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy kiểm tra mục Thông báo để nhận việc mới.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myJobs.length,
      itemBuilder: (context, index) {
        final job = _myJobs[index];

        final vehicleModel = job['vehicles']?['model'] ?? 'Chưa rõ xe';
        final vehiclePlate =
            job['vehicles']?['license_plate'] ?? 'Chưa rõ biển số';
        final status = job['status'] ?? 'dang_xu_ly';
        final rawDate = job['created_at'] != null
            ? DateTime.parse(job['created_at']).toLocal()
            : DateTime.now();
        final formattedDate = DateFormat('dd/MM, HH:mm').format(rawDate);

        final isDone = status == 'hoan_thanh';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Status Sidebar
                    Container(
                      width: 6,
                      color: isDone ? AppColors.statusDone : AppColors.accent,
                    ),
                    Expanded(
                      child: AppCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.jobDetail,
                            arguments: job,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    vehicleModel,
                                    style: GoogleFonts.sora(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgApp,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'PH-${job['id']}',
                                    style: GoogleFonts.robotoMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              vehiclePlate,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusBadge(status),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: AppColors.textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'dang_xu_ly':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFFF7A00);
        label = '• Đang thực hiện';
        break;
      case 'hoan_thanh':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF4CAF50);
        label = '• Đã hoàn thành';
        break;
      case 'da_ban_giao':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF2196F3);
        label = '• Đã bàn giao';
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF9E9E9E);
        label = '• Chờ xử lý';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
