import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  int? _selectedVehicleId;
  String? _selectedServiceName;

  final _noteController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingData = true;

  List<Map<String, dynamic>> _myVehicles = [];
  List<Map<String, dynamic>> _availableServices = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final customerData = await supabase
          .from('customers')
          .select('id')
          .eq('user_id', user.id)
          .single();
      final customerId = customerData['id'];

      final vehiclesData = await supabase
          .from('vehicles')
          .select()
          .eq('customer_id', customerId);

      final servicesData = await supabase
          .from('services')
          .select('id, name, labor_price');

      if (mounted) {
        setState(() {
          _myVehicles = List<Map<String, dynamic>>.from(vehiclesData);
          _availableServices = List<Map<String, dynamic>>.from(servicesData);

          if (_myVehicles.isNotEmpty) {
            _selectedVehicleId = _myVehicles.first['id'];
          }
          if (_availableServices.isNotEmpty) {
            _selectedServiceName = _availableServices.first['name'];
          }

          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Lỗi tải dữ liệu: $e');
      if (mounted) setState(() => _isLoadingData = false);
    }
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

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ hẹn')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      final customerData = await supabase
          .from('customers')
          .select('id')
          .eq('user_id', user!.id)
          .single();
      final customerId = customerData['id'];

      await supabase.from('appointments').insert({
        'customer_id': customerId,
        'vehicle_id': _selectedVehicleId,
        'scheduled_at': scheduledDateTime.toIso8601String(),
        'note':
            'Dịch vụ: ${_selectedServiceName ?? ''} | Ghi chú: ${_noteController.text.trim()}',
      });

      if (mounted) {
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
                  setState(() {
                    _selectedDate = null;
                    _selectedTime = null;
                    _noteController.clear();
                  });
                },
                child: const Text(
                  'Đóng',
                  style: TextStyle(color: AppColors.accent),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đặt lịch dịch vụ',
                style: GoogleFonts.sora(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chọn thời gian và dịch vụ phù hợp với bạn.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle(Icons.motorcycle_outlined, 'CHỌN XE CỦA BẠN'),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                isExpanded: true,
                value: _selectedVehicleId,
                decoration: _inputDecoration(null),
                items: _myVehicles.map((vehicle) {
                  return DropdownMenuItem<int>(
                    value: vehicle['id'],
                    child: Text(
                      '${vehicle['model']} (${vehicle['license_plate']})',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedVehicleId = val),
                validator: (val) => val == null ? 'Vui lòng chọn xe' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(Icons.build_circle_outlined, 'LOẠI DỊCH VỤ'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedServiceName,
                decoration: _inputDecoration(null),
                items: _availableServices.map((service) {
                  final price = service['labor_price'] ?? 0;
                  final formattedPrice = NumberFormat('#,###').format(price);
                  return DropdownMenuItem<String>(
                    value: service['name'],
                    child: Text(
                      '${service['name']} • ${formattedPrice}đ',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedServiceName = val),
                validator: (val) =>
                    val == null ? 'Vui lòng chọn dịch vụ' : null,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(
                Icons.calendar_month_outlined,
                'THỜI GIAN HẸN',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _boxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ngày hẹn',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? 'Chọn ngày'
                                  : DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_selectedDate!),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: _selectedDate == null
                                    ? AppColors.textTertiary
                                    : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: _boxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giờ hẹn',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedTime == null
                                  ? 'Chọn giờ'
                                  : _selectedTime!.format(context),
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700,
                                color: _selectedTime == null
                                    ? AppColors.textTertiary
                                    : AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle(Icons.edit_note_outlined, 'GHI CHÚ THÊM'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: _inputDecoration(
                  'Tình trạng xe, yêu cầu đặc biệt...',
                ),
              ),
              const SizedBox(height: 40),

              _isSubmitting
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    )
                  : PrimaryButton(
                      label: 'XÁC NHẬN ĐẶT LỊCH',
                      onPressed: _handleBooking,
                    ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.sora(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.accent, width: 2),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.borderSubtle),
    );
  }
}
