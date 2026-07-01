import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/plate_text.dart';
import '../../widgets/status_chip.dart';
import 'customer_provider.dart';

class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({super.key, required this.customerPhone});

  final String customerPhone;

  @override
  ConsumerState<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> with SingleTickerProviderStateMixin {
  late String _currentPhone;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _currentPhone = widget.customerPhone;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  AppStatus _mapStringStatusToAppStatus(String status) {
    switch (status) {
      case 'active':
        return AppStatus.active;
      case 'done':
        return AppStatus.done;
      case 'wait':
        return AppStatus.wait;
      case 'error':
        return AppStatus.error;
      default:
        return AppStatus.idle;
    }
  }

  void _showDeleteConfirmation(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text(
          'Xác nhận xóa',
          style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa khách hàng "$name" và tất cả thông tin phương tiện liên quan không?',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: GoogleFonts.inter(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              ref.read(customerProvider.notifier).deleteCustomer(_currentPhone);
              Navigator.pop(context); // Đóng dialog
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa khách hàng $name thành công'),
                  backgroundColor: AppColors.surfaceDark,
                ),
              );
              // Pop screen sẽ được gọi tự động trong build() khi không tìm thấy customer nữa
            },
            child: Text('Xóa', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showEditBottomSheet(BuildContext context, CustomerDetailModel customer) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final emailController = TextEditingController(text: customer.email);
    final addressController = TextEditingController(text: customer.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgApp,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chỉnh sửa thông tin khách hàng',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Name field
                  Text('Họ và tên', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Nhập họ và tên...'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
                  ),
                  const SizedBox(height: 16),

                  // Phone field
                  Text('Số điện thoại', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'Nhập số điện thoại...'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập số điện thoại' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  Text('Email', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Nhập email...'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập email' : null,
                  ),
                  const SizedBox(height: 16),

                  // Address field
                  Text('Địa chỉ', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Nhập địa chỉ...'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final updated = customer.copyWith(
                            name: nameController.text.trim(),
                            phone: phoneController.text.trim(),
                            email: emailController.text.trim(),
                            address: addressController.text.trim(),
                          );

                          ref.read(customerProvider.notifier).updateCustomer(_currentPhone, updated);
                          
                          setState(() {
                            _currentPhone = updated.phone; // Cập nhật lại số điện thoại truy vấn nếu đổi SĐT
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã cập nhật thông tin thành công'),
                              backgroundColor: AppColors.accent,
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Lưu thay đổi',
                        style: GoogleFonts.sora(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customerProvider);
    final customerIndex = customers.indexWhere((c) => c.phone == _currentPhone);

    if (customerIndex == -1) {
      // Tự động pop về màn hình trước khi khách hàng bị xóa
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final customer = customers[customerIndex];

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Chi tiết khách hàng'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () => _showEditBottomSheet(context, customer),
            tooltip: 'Chỉnh sửa thông tin',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showDeleteConfirmation(context, customer.name),
            tooltip: 'Xóa khách hàng',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Customer Profile Info Card
          Container(
            width: double.infinity,
            color: AppColors.surfaceDark,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.accentSoft,
                        child: const Icon(Icons.person, size: 28, color: AppColors.accent),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Hoạt động gần nhất: ${customer.lastVisit}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),

                  // Phone info
                  Row(
                    children: [
                      const Icon(Icons.phone_android, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        customer.phone,
                        style: GoogleFonts.robotoMono(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Email info
                  Row(
                    children: [
                      const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        customer.email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Address info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          customer.address,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar headers
          Container(
            color: AppColors.surfaceCard,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.normal),
              tabs: [
                Tab(text: 'Danh sách xe (${customer.vehicles.length})'),
                const Tab(text: 'Lịch sử sửa chữa'),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Danh sách xe
                customer.vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.motorcycle_outlined, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'Khách hàng chưa đăng ký xe nào',
                              style: GoogleFonts.inter(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customer.vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = customer.vehicles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: AppCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.motorcycle, size: 24, color: AppColors.accent),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle.name,
                                          style: GoogleFonts.sora(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceSunken,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(color: AppColors.divider),
                                              ),
                                              child: PlateText(vehicle.plate, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusChip(
                                    label: vehicle.statusLabel,
                                    status: _mapStringStatusToAppStatus(vehicle.status),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                // TAB 2: Lịch sử sửa chữa
                customer.serviceHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_toggle_off_outlined, size: 48, color: AppColors.textTertiary),
                            const SizedBox(height: 12),
                            Text(
                              'Không có lịch sử sửa chữa nào',
                              style: GoogleFonts.inter(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customer.serviceHistory.length,
                        itemBuilder: (context, index) {
                          final history = customer.serviceHistory[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentSoft,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          history.type,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.accent,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        history.date,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    history.notes,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1, color: AppColors.divider),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Mã phiếu: ${history.workOrder}',
                                        style: GoogleFonts.robotoMono(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        history.cost,
                                        style: GoogleFonts.sora(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
