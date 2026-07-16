import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';

class AssignJobScreen extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const AssignJobScreen({super.key, required this.appointment});

  @override
  State<AssignJobScreen> createState() => _AssignJobScreenState();
}

class _AssignJobScreenState extends State<AssignJobScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _mechanics = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _parts = [];

  int? _selectedMechanicId;
  List<Map<String, dynamic>> _selectedServices = [];
  List<Map<String, dynamic>> _selectedParts = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final mechanicsData = await _supabase
          .from('mechanics')
          .select('id, full_name');
      final servicesData = await _supabase
          .from('services')
          .select('id, name, labor_price');
      final partsData = await _supabase
          .from('parts')
          .select('id, name, price, stock_qty')
          .gt('stock_qty', 0); // Chỉ lấy phụ tùng còn hàng

      if (mounted) {
        setState(() {
          _mechanics = List<Map<String, dynamic>>.from(mechanicsData);
          _services = List<Map<String, dynamic>>.from(servicesData);
          _parts = List<Map<String, dynamic>>.from(partsData);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createWorkOrder() async {
    setState(() => _isSubmitting = true);
    try {
      final appointment = widget.appointment;
      final serviceNames = _selectedServices.map((s) => s['name']).join(', ');

      final insertedWorkOrder = await _supabase
          .from('work_orders')
          .insert({
            'vehicle_id': appointment['vehicle_id'],
            'customer_id': appointment['customer_id'],
            'employee_id': _selectedMechanicId,
            'status': 'cho_nhan',
            'description':
                'Dịch vụ chốt: $serviceNames\nKhách note: ${appointment['note'] ?? ''}',
          })
          .select()
          .single();

      final workOrderId = insertedWorkOrder['id'];

      // 2. Lưu danh sách dịch vụ đã chọn vào bảng work_order_services
      final servicesToInsert = _selectedServices
          .map(
            (service) => {
              'work_order_id': workOrderId,
              'service_id': service['id'],
              'name': service['name'],
              'labor_price': service['labor_price'],
            },
          )
          .toList();
      await _supabase.from('work_order_services').insert(servicesToInsert);

      // 3. Lưu danh sách phụ tùng (Linh kiện) và Trừ tồn kho
      if (_selectedParts.isNotEmpty) {
        final partsToInsert = _selectedParts
            .map(
              (part) => {
                'work_order_id': workOrderId,
                'part_id': part['id'],
                'name': part['name'],
                'quantity': 1, // Tạm thời mặc định mỗi loại 1 cái
                'unit_price': part['price'],
              },
            )
            .toList();

        await _supabase.from('work_order_parts').insert(partsToInsert);

        // Trừ kho và ghi log cho từng món
        for (var part in _selectedParts) {
          await _supabase.from('stock_transactions').insert({
            'part_id': part['id'],
            'type': 'xuat',
            'quantity': 1, // Tạm thời mặc định mỗi loại 1 cái
            'note': 'Lễ tân giao phụ tùng cho phiếu PH-$workOrderId',
          });

          await _supabase
              .from('parts')
              .update({'stock_qty': part['stock_qty'] - 1})
              .eq('id', part['id']);
        }
      }

      // 4. Tạo các công đoạn (checklist) cho thợ
      final stagesToInsert = _selectedServices
          .map(
            (service) => {
              'work_order_id': workOrderId,
              'stage': 'Thực hiện: ${service['name']}',
              'done': false,
            },
          )
          .toList();

      await _supabase.from('work_order_stages').insert(stagesToInsert);

      // 5. Xóa lịch hẹn (vì đã chuyển thành phiếu công việc)
      await _supabase.from('appointments').delete().eq('id', appointment['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo phiếu và giao việc thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        // Đóng màn hình và trả về true báo hiệu đã làm xong
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi giao việc: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _preAssignAppointment() async {
    setState(() => _isSubmitting = true);
    try {
      await _supabase
          .from('appointments')
          .update({'employee_id': _selectedMechanicId})
          .eq('id', widget.appointment['id']);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã gán thợ vào lịch hẹn thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gán thợ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: Text(
          'Chi tiết Giao việc',
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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Service Selection
                  Row(
                    children: [
                      const Icon(
                        Icons.build_circle_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '1. CHỐT DỊCH VỤ THỰC TẾ',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _services.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, index) {
                            final service = _services[index];
                            final isSelected = _selectedServices.any(
                              (s) => s['id'] == service['id'],
                            );
                            return CheckboxListTile(
                              title: Text(
                                service['name'],
                                style: GoogleFonts.inter(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              subtitle: Text(
                                '${NumberFormat('#,###').format(service['labor_price'])}đ',
                                style: GoogleFonts.robotoMono(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              value: isSelected,
                              activeColor: AppColors.accent,
                              checkboxShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedServices.add(service);
                                  } else {
                                    _selectedServices.removeWhere(
                                      (s) => s['id'] == service['id'],
                                    );
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 2. Mechanic Assignment
                  Row(
                    children: [
                      const Icon(
                        Icons.person_search_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '2. PHÂN CÔNG THỢ PHỤ TRÁCH',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _selectedMechanicId,
                      hint: Text(
                        'Chọn thợ sửa xe...',
                        style: GoogleFonts.inter(color: AppColors.textTertiary),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgApp,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: _mechanics.map((mechanic) {
                        return DropdownMenuItem<int>(
                          value: mechanic['id'],
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.accentSoft,
                                child: Icon(
                                  Icons.person,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${mechanic['full_name']}',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedMechanicId = val),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 3. Parts Selection
                  Row(
                    children: [
                      const Icon(
                        Icons.settings_suggest_outlined,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '3. CHỌN PHỤ TÙNG TỪ KHO',
                        style: GoogleFonts.sora(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        if (_parts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Kho hiện đang hết phụ tùng.',
                              style: GoogleFonts.inter(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _parts.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                            ),
                            itemBuilder: (context, index) {
                              final part = _parts[index];
                              final isSelected = _selectedParts.any(
                                (p) => p['id'] == part['id'],
                              );
                              return CheckboxListTile(
                                title: Text(
                                  part['name'],
                                  style: GoogleFonts.inter(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                subtitle: Text(
                                  'Giá: ${NumberFormat('#,###').format(part['price'])}đ • Tồn: ${part['stock_qty']}',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                value: isSelected,
                                activeColor: AppColors.accent,
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      _selectedParts.add(part);
                                    } else {
                                      _selectedParts.removeWhere(
                                        (p) => p['id'] == part['id'],
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed:
                              (_selectedMechanicId == null || _isSubmitting)
                              ? null
                              : _preAssignAppointment,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.accent,
                              width: 2,
                            ),
                            foregroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'GÁN LỊCH HẸN',
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              (_selectedMechanicId == null ||
                                  _selectedServices.isEmpty ||
                                  _isSubmitting)
                              ? null
                              : _createWorkOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: AppColors.accent.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'TẠO PHIẾU NGAY',
                                  style: GoogleFonts.sora(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
