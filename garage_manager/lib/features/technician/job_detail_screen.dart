import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class JobDetailScreen extends StatefulWidget {
  // Thay đổi kiểu dữ liệu nhận vào thành Map từ Supabase
  const JobDetailScreen({super.key, required this.jobData});

  final Map<String, dynamic> jobData;

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _stages = [];

  @override
  void initState() {
    super.initState();
    _fetchJobStages();
  }

  // Kéo danh sách công đoạn từ bảng work_order_stages
  Future<void> _fetchJobStages() async {
    try {
      final workOrderId = widget.jobData['id'];
      final response = await _supabase
          .from('work_order_stages')
          .select()
          .eq('work_order_id', workOrderId)
          .order('id', ascending: true); // Sắp xếp theo thứ tự công đoạn

      if (mounted) {
        setState(() {
          _stages = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải công đoạn: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Cập nhật trạng thái công đoạn (done = true)
  Future<void> _completeStage(int stageId) async {
    try {
      // 1. Cập nhật công đoạn
      await _supabase
          .from('work_order_stages')
          .update({
            'done': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stageId);

      // 2. Kiểm tra xem đây có phải công đoạn cuối cùng chưa hoàn thành không
      final remainingStages = _stages
          .where((s) => s['id'] != stageId && s['done'] != true)
          .toList();

      if (remainingStages.isEmpty) {
        // Nếu đã xong hết các công đoạn, tự động cập nhật status của work_order thành 'hoan_thanh'
        await _supabase
            .from('work_orders')
            .update({'status': 'hoan_thanh'})
            .eq('id', widget.jobData['id']);
      }

      // Tải lại danh sách sau khi cập nhật
      _fetchJobStages();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              remainingStages.isEmpty
                  ? 'Đã hoàn thành toàn bộ công đoạn và cập nhật trạng thái phiếu!'
                  : 'Đã hoàn thành công đoạn!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trích xuất thông tin cơ bản từ jobData truyền sang
    final vehicleModel = widget.jobData['vehicles']?['model'] ?? 'Xe chưa rõ';
    final vehiclePlate =
        widget.jobData['vehicles']?['license_plate'] ?? 'Chưa rõ biển số';
    final customerName =
        widget.jobData['customers']?['full_name'] ?? 'Khách lẻ';
    final jobId = widget.jobData['id'];

    final status = widget.jobData['status'] ?? 'dang_xu_ly';

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Chi tiết phiếu',
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
          : RefreshIndicator(
              onRefresh: _fetchJobStages,
              color: AppColors.accent,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Card (Vehicle & Customer)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusBadge(status),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.bgApp,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PH-$jobId',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            vehicleModel,
                            style: GoogleFonts.sora(
                              fontSize: 24,
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
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: AppColors.accentSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.accent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Khách hàng',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  Text(
                                    customerName,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 2. Stages Timeline
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.checklist_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'CÔNG ĐOẠN SỬA CHỮA',
                            style: GoogleFonts.sora(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_stages.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AppCard(
                          child: Center(
                            child: Text(
                              'Chưa có công đoạn nào được tạo.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: _stages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stage = entry.value;
                            final isDone = stage['done'] == true;
                            final isLast = index == _stages.length - 1;

                            return _buildStageItem(
                              stageName: stage['stage'] ?? 'Công đoạn',
                              isDone: isDone,
                              isLast: isLast,
                              onComplete: () => _completeStage(stage['id']),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'dang_xu_ly':
        color = AppColors.accent;
        label = 'Đang thực hiện';
        break;
      case 'hoan_thanh':
        color = AppColors.statusDone;
        label = 'Đã hoàn thành';
        break;
      case 'da_ban_giao':
        color = Colors.blue;
        label = 'Đã bàn giao';
        break;
      default:
        color = AppColors.textTertiary;
        label = 'Chờ xử lý';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ từng bước công đoạn
  Widget _buildStageItem({
    required String stageName,
    required bool isDone,
    required bool isLast,
    required VoidCallback onComplete,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cột Timeline
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.statusDone : Colors.white,
                  border: Border.all(
                    color: isDone
                        ? AppColors.statusDone
                        : AppColors.borderSubtle,
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.borderSubtle,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? AppColors.statusDone
                        : AppColors.borderSubtle,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          // Nội dung công đoạn
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: isDone ? FontWeight.w600 : FontWeight.w700,
                      color: isDone
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (!isDone) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xác nhận hoàn thành',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
