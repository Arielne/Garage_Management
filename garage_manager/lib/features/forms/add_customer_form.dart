import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/form_scaffold.dart';

class AddCustomerForm extends StatefulWidget {
  const AddCustomerForm({super.key});

  @override
  State<AddCustomerForm> createState() => _AddCustomerFormState();
}

class _AddCustomerFormState extends State<AddCustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving new customer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã thêm khách hàng mới thành công!'),
          backgroundColor: AppColors.statusDone,
        ),
      );
      Navigator.of(context).pop({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vehiclesCount': 0,
        'lastVisit': 'Vừa tạo',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Thêm khách hàng'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: FormScaffold(
            submitLabel: 'Lưu khách hàng',
            onSubmit: _handleSubmit,
            children: [
              const SizedBox(height: 12),
              // Full Name field
              Text(
                'Họ và tên',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: 'Nhập họ và tên khách hàng...',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondary, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone number field
              Text(
                'Số điện thoại',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Nhập số điện thoại...',
                  prefixIcon: Icon(Icons.phone_android_outlined, color: AppColors.textSecondary, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  final phoneRegex = RegExp(r'^(0[3|5|7|8|9])+([0-9]{8})$');
                  if (!phoneRegex.hasMatch(value.trim())) {
                    return 'Số điện thoại không hợp lệ (ví dụ: 0987654321)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Address field
              Text(
                'Địa chỉ (Không bắt buộc)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.text,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Nhập địa chỉ khách hàng...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
