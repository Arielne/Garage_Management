import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVehicle;
  String? _selectedServiceType;
  final _noteController = TextEditingController();

  final List<String> _vehicles = [
    'Yamaha Exciter 150 RC (59-X1 234.56)',
    'Honda Winner X (60-B2 889.12)',
  ];

  final List<String> _serviceTypes = [
    'Bảo dưỡng định kỳ',
    'Sửa chữa hư hỏng',
    'Thay nhớt / Phụ tùng',
    'Nâng cấp / Độ xe',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _handleBooking() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn ngày và giờ hẹn')),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Đặt lịch thành công',
            style: GoogleFonts.sora(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Yêu cầu đặt lịch của bạn đã được gửi. Garage sẽ liên hệ xác nhận sớm nhất.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear form or navigate
              },
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin đặt lịch',
              style: GoogleFonts.sora(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Vehicle Selection
            Text(
              'Chọn xe của bạn',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedVehicle,
              decoration: const InputDecoration(
                hintText: 'Chọn xe...',
                prefixIcon: Icon(Icons.motorcycle_outlined),
              ),
              items: _vehicles
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedVehicle = val),
              validator: (val) => val == null ? 'Vui lòng chọn xe' : null,
            ),
            const SizedBox(height: 16),

            // Service Type
            Text(
              'Loại dịch vụ',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedServiceType,
              decoration: const InputDecoration(
                hintText: 'Chọn dịch vụ...',
                prefixIcon: Icon(Icons.build_outlined),
              ),
              items: _serviceTypes
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedServiceType = val),
              validator: (val) => val == null ? 'Vui lòng chọn dịch vụ' : null,
            ),
            const SizedBox(height: 16),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ngày hẹn',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate == null
                                    ? 'Chọn ngày'
                                    : DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(_selectedDate!),
                                style: GoogleFonts.inter(
                                  color: _selectedDate == null
                                      ? AppColors.textTertiary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giờ hẹn',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.divider),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime == null
                                    ? 'Chọn giờ'
                                    : _selectedTime!.format(context),
                                style: GoogleFonts.inter(
                                  color: _selectedTime == null
                                      ? AppColors.textTertiary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            Text(
              'Ghi chú / Tình trạng xe',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Mô tả thêm về tình trạng xe hoặc yêu cầu riêng...',
              ),
            ),
            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Xác nhận đặt lịch',
              onPressed: _handleBooking,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
