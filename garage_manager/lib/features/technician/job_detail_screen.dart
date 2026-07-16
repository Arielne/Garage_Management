import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

class JobDetailScreen extends StatefulWidget {
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

  Future<void> _fetchJobStages() async {
    try {
      final workOrderId = widget.jobData['id'];
      final response = await _supabase
          .from('work_order_stages')
          .select()
          .eq('work_order_id', workOrderId)
          .order('id', ascending: true);

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

  Future<void> _updateCurrentStage(String stageValue) async {
    if (stageValue == 'ban_giao') {
      await _fetchJobStages();
      final allDone = _stages.every((s) => s['done'] == true);
      if (!allDone) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể Bàn giao! Vẫn còn công đoạn chưa xong.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {});
        }
        return;
      }
    }
    try {
      await _supabase
          .from('work_orders')
          .update({'current_stage': stageValue})
          .eq('id', widget.jobData['id']);

      if (mounted) {
        setState(() {
          widget.jobData['current_stage'] = stageValue;
        });

        if (stageValue != 'ban_giao') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã cập nhật giai đoạn xe!'),
              backgroundColor: Colors.blue,
            ),
          );
        }

        if (stageValue == 'ban_giao') {
          await _checkAndFinalizeInvoice();
        }
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật giai đoạn: $e');
    }
  }

  Future<void> _checkAndFinalizeInvoice() async {
    await _fetchJobStages();

    final allDone = _stages.every((s) => s['done'] == true);
    if (!allDone) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu ý: Vẫn còn công đoạn chưa tích hoàn thành!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      final workOrderId = widget.jobData['id'];

      final servicesRes = await _supabase
          .from('work_order_services')
          .select('labor_price')
          .eq('work_order_id', workOrderId);

      num totalLabor = 0;
      for (final s in servicesRes) {
        totalLabor += (s['labor_price'] ?? 0) as num;
      }

      final partsRes = await _supabase
          .from('work_order_parts')
          .select('part_id, quantity, unit_price')
          .eq('work_order_id', workOrderId);

      num totalParts = 0;
      for (final p in partsRes) {
        final qty = (p['quantity'] ?? 1) as num;
        final price = (p['unit_price'] ?? 0) as num;
        totalParts += (qty * price);

        if (p['part_id'] != null) {
          try {
            await _supabase.from('stock_transactions').insert({
              'part_id': p['part_id'],
              'type': 'xuat',
              'quantity': qty,
              'note': 'Tự động xuất kho cho phiếu PH-$workOrderId',
              'date': DateTime.now().toIso8601String(),
            });
            final currentPart = await _supabase
                .from('parts')
                .select('stock_qty')
                .eq('id', p['part_id'])
                .single();

            final currentStock = (currentPart['stock_qty'] ?? 0) as num;

            await _supabase
                .from('parts')
                .update({'stock_qty': currentStock - qty})
                .eq('id', p['part_id']);
          } catch (e) {
            debugPrint('Lỗi ghi sổ kho: $e');
          }
        }
      }

      final num subtotal = totalLabor + totalParts;
      final num tax = (subtotal * 0.08).round();
      final num totalAmount = subtotal + tax;

      await _supabase
          .from('work_orders')
          .update({'status': 'da_ban_giao'})
          .eq('id', workOrderId);

      if (mounted) {
        setState(() {
          widget.jobData['status'] = 'da_ban_giao';
        });
      }

      final existingInvoice = await _supabase
          .from('invoices')
          .select('id')
          .eq('work_order_id', workOrderId)
          .maybeSingle();

      if (existingInvoice == null) {
        final insertResponse = await _supabase
            .from('invoices')
            .insert({
              'work_order_id': workOrderId,
              'code':
                  'HD-${DateFormat('yyyyMMdd').format(DateTime.now())}-$workOrderId',
              'subtotal': subtotal,
              'tax': tax,
              'discount_amount': 0,
              'total': totalAmount,
              'status': 'chua_thanh_toan',
            })
            .select('id');

        if (insertResponse.isNotEmpty) {
          final insertedId = insertResponse[0]['id'];
          await _supabase
              .from('invoices')
              .update({'payment_code': 'GARAHD$insertedId'})
              .eq('id', insertedId);
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Hoàn tất & Xuất hóa đơn'),
              content: Text(
                'Hệ thống đã tự động tính toán:\n'
                '- Tiền dịch vụ: ${totalLabor.toInt()}đ\n'
                '- Tiền phụ tùng: ${totalParts.toInt()}đ\n'
                '- Thuế VAT (8%): ${tax.toInt()}đ\n\n'
                'Tổng cộng: ${totalAmount.toInt()}đ\n\n'
                'Hóa đơn đã được tạo và sẵn sàng thanh toán.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi chốt hóa đơn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không xuất được hóa đơn: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _completeStage(int stageId) async {
    try {
      await _supabase
          .from('work_order_stages')
          .update({
            'done': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', stageId);

      await _fetchJobStages();

      final allDone = _stages.every((s) => s['done'] == true);

      if (allDone) {
        await _updateCurrentStage('ban_giao');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hoàn thành công đoạn!'),
              backgroundColor: Colors.green,
            ),
          );
        }
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giai đoạn hiện tại:',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              _buildStageSelector(),
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

  Widget _buildStageSelector() {
    final currentStage = widget.jobData['current_stage'] ?? 'tiep_nhan';
    final stages = {
      'tiep_nhan': 'Tiếp nhận',
      'thao_lap': 'Tháo lắp',
      'thay_do': 'Thay đồ',
      'chay_thu': 'Chạy thử',
      'ban_giao': 'Bàn giao',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgApp,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStage,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.accent),
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _updateCurrentStage(newValue);
            }
          },
          items: stages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
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
