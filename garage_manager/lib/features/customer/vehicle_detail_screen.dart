import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_routes.dart';
import '../../core/models.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/plate_text.dart';
import '../manager/customers/customer_provider.dart';

class VehicleDetailScreen extends ConsumerWidget {
  const VehicleDetailScreen({super.key, required this.vehiclePlate});

  final String vehiclePlate;

  Invoice _mapHistoryToInvoice(ServiceHistoryModel history, String customerName, String vehiclePlate) {
    List<InvoiceLineItem> items = [];
    String subtotal = history.cost;
    String discount = '0đ';
    String tax = '0đ';

    if (history.workOrder == 'WO-2026-012') {
      items = [
        const InvoiceLineItem(
          name: 'Pô Akrapovic Carbon chính hãng',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '2.000.000đ',
          totalText: '2.000.000đ',
        ),
        const InvoiceLineItem(
          name: 'Công căn chỉnh xăng gió (Dynojet)',
          type: InvoiceLineItemType.service,
          quantity: 1,
          unitPriceText: '450.000đ',
          totalText: '450.000đ',
        ),
      ];
      subtotal = '2.450.000đ';
    } else if (history.workOrder == 'WO-2026-001') {
      items = [
        const InvoiceLineItem(
          name: 'Lốp Michelin City Grip 2 (Trước & Sau)',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '1.000.000đ',
          totalText: '1.000.000đ',
        ),
        const InvoiceLineItem(
          name: 'Công thay vỏ & cân mâm',
          type: InvoiceLineItemType.service,
          quantity: 1,
          unitPriceText: '200.000đ',
          totalText: '200.000đ',
        ),
      ];
      subtotal = '1.200.000đ';
    } else if (history.workOrder == 'WO-2026-004') {
      items = [
        const InvoiceLineItem(
          name: 'Nhớt Motul 300V 10W40 1L',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '450.000đ',
          totalText: '450.000đ',
        ),
        const InvoiceLineItem(
          name: 'Lọc gió K&N Vario/Click',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '250.000đ',
          totalText: '250.000đ',
        ),
        const InvoiceLineItem(
          name: 'Công vệ sinh nồi & kiểm tra truyền động',
          type: InvoiceLineItemType.service,
          quantity: 1,
          unitPriceText: '150.000đ',
          totalText: '150.000đ',
        ),
      ];
      subtotal = '850.000đ';
    } else if (history.workOrder == 'WO-2026-009') {
      items = [
        const InvoiceLineItem(
          name: 'Bộ nhông sên dĩa DID vàng Raider/Satria',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '1.200.000đ',
          totalText: '1.200.000đ',
        ),
        const InvoiceLineItem(
          name: 'Má phanh Nissin trước & sau',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '400.000đ',
          totalText: '400.000đ',
        ),
        const InvoiceLineItem(
          name: 'Công lắp ráp & căn chỉnh sên',
          type: InvoiceLineItemType.service,
          quantity: 1,
          unitPriceText: '200.000đ',
          totalText: '200.000đ',
        ),
      ];
      subtotal = '1.800.000đ';
    } else if (history.workOrder == 'WO-2026-011') {
      items = [
        const InvoiceLineItem(
          name: 'Nhớt Wolver Special 10W40 0.8L',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '180.000đ',
          totalText: '180.000đ',
        ),
        const InvoiceLineItem(
          name: 'Nhớt hộp số (láp) Liqui Moly Racing',
          type: InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: '90.000đ',
          totalText: '90.000đ',
        ),
        const InvoiceLineItem(
          name: 'Công thay nhớt nhanh',
          type: InvoiceLineItemType.service,
          quantity: 1,
          unitPriceText: '50.000đ',
          totalText: '50.000đ',
        ),
      ];
      subtotal = '320.000đ';
    } else {
      items = [
        InvoiceLineItem(
          name: history.notes,
          type: history.type == 'Độ & Nâng cấp' 
              ? InvoiceLineItemType.service 
              : InvoiceLineItemType.part,
          quantity: 1,
          unitPriceText: history.cost,
          totalText: history.cost,
        ),
      ];
      subtotal = history.cost;
    }

    return Invoice(
      code: history.workOrder,
      customerName: customerName,
      vehiclePlate: vehiclePlate,
      createdAtText: history.date,
      subtotalText: subtotal,
      discountAmountText: discount,
      taxText: tax,
      totalText: history.cost,
      statusLabel: 'Đã thanh toán',
      status: InvoicePaymentStatus.paid,
      lineItems: items,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read the list of customers from Riverpod
    final customers = ref.watch(customerProvider);

    // Find the customer who owns this vehicle plate
    CustomerDetailModel? customer;
    VehicleModel? vehicle;
    for (final c in customers) {
      final vIndex = c.vehicles.indexWhere((v) => v.plate == vehiclePlate);
      if (vIndex != -1) {
        customer = c;
        vehicle = c.vehicles[vIndex];
        break;
      }
    }

    final String vehicleName = vehicle != null ? vehicle.name : 'Dòng xe máy';
    final String brand = vehicleName.toLowerCase().contains('honda') ||
            vehicleName.toLowerCase().contains('air blade') ||
            vehicleName.toLowerCase().contains('airblade') ||
            vehicleName.toLowerCase().contains('sh') ||
            vehicleName.toLowerCase().contains('vision') ||
            vehicleName.toLowerCase().contains('vario') ||
            vehicleName.toLowerCase().contains('winner') ||
            vehicleName.toLowerCase().contains('lead')
        ? 'Honda'
        : vehicleName.toLowerCase().contains('vespa') ||
                vehicleName.toLowerCase().contains('piaggio')
            ? 'Vespa / Piaggio'
            : vehicleName.toLowerCase().contains('suzuki')
                ? 'Suzuki'
                : 'Yamaha';



    List<ServiceHistoryModel> serviceHistory = customer != null
        ? customer.serviceHistory.where((h) => h.vehiclePlate == vehiclePlate).toList()
        : [];

    if (serviceHistory.isEmpty) {
      serviceHistory = [
        ServiceHistoryModel(
          date: '01/07/2026',
          workOrder: 'WO-2026-012',
          cost: '2.450.000đ',
          notes: 'Lắp pô độ Akrapovic, căn chỉnh xăng gió (Dynojet).',
          type: 'Độ & Nâng cấp',
          vehiclePlate: vehiclePlate,
        ),
        ServiceHistoryModel(
          date: '15/04/2026',
          workOrder: 'WO-2026-001',
          cost: '1.200.000đ',
          notes: 'Thay lốp trước/sau Michelin City Grip 2.',
          type: 'Bảo dưỡng định kỳ',
          vehiclePlate: vehiclePlate,
        ),
      ];
    }

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Chi tiết xe'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditVehicleDialog(context, ref, vehicle);
              } else if (value == 'delete') {
                _showDeleteConfirmationDialog(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 8),
                    Text('Sửa thông tin xe'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: AppColors.statusError, size: 20),
                    SizedBox(width: 8),
                    Text('Xóa xe', style: TextStyle(color: AppColors.statusError)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Header Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.motorcycle,
                          size: 32,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleName,
                              style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: PlateText(
                                vehiclePlate,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  
                  // Specs rows
                  _buildSpecRow('Hãng xe', brand),
                  const SizedBox(height: 10),
                  _buildSpecRow('Năm sản xuất', vehicle?.year != null ? vehicle!.year.toString() : 'Chưa cập nhật'),
                  if (vehicle?.engineCc != null) ...[
                    const SizedBox(height: 10),
                    _buildSpecRow('Dung tích động cơ', '${vehicle!.engineCc} cc'),
                  ],
                  if (vehicle?.odometer != null) ...[
                    const SizedBox(height: 10),
                    _buildSpecRow('Số ODO', '${vehicle!.odometer} km'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch sử bảo dưỡng & nâng cấp',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Chạm để xem chi tiết',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (serviceHistory.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Chưa có lịch sử bảo dưỡng',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ...serviceHistory.map((history) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: () {
                      final invoice = _mapHistoryToInvoice(
                        history,
                        customer?.name ?? 'Khách hàng',
                        vehiclePlate,
                      );
                      Navigator.of(context).pushNamed(
                        AppRoutes.invoiceDetail,
                        arguments: invoice,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              history.date,
                              style: GoogleFonts.robotoMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: history.type == 'Độ & Nâng cấp' 
                                    ? AppColors.accentSoft 
                                    : AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                history.type,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: history.type == 'Độ & Nâng cấp' 
                                      ? AppColors.accent 
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Mã phiếu:',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            PlateText(history.workOrder, fontSize: 13, color: AppColors.textPrimary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          history.notes,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Chi phí:',
                                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.textTertiary),
                              ],
                            ),
                            Text(
                              history.cost,
                              style: GoogleFonts.robotoMono(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showEditVehicleDialog(BuildContext context, WidgetRef ref, VehicleModel? vehicle) {
    if (vehicle == null) return;
    
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: vehicle.name);
    final plateController = TextEditingController(text: vehicle.plate);
    final yearController = TextEditingController(text: vehicle.year?.toString() ?? '');
    final ccController = TextEditingController(text: vehicle.engineCc?.toString() ?? '');
    final odoController = TextEditingController(text: vehicle.odometer?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            'Sửa thông tin xe',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plate
                  Text('Biển số xe', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: plateController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(hintText: 'Biển số...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập biển số' : null,
                  ),
                  const SizedBox(height: 16),

                  // Model Name
                  Text('Tên dòng xe', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Dòng xe...'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên dòng xe' : null,
                  ),
                  const SizedBox(height: 16),

                  // Year
                  Text('Năm sản xuất', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Năm...'),
                  ),
                  const SizedBox(height: 16),

                  // CC
                  Text('Dung tích (cc)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: ccController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Dung tích cc...'),
                  ),
                  const SizedBox(height: 16),

                  // ODO
                  Text('Số ODO (km)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: odoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Số km...'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final supabase = Supabase.instance.client;
                    await supabase.from('vehicles').update({
                      'model': nameController.text.trim(),
                      'license_plate': plateController.text.trim().toUpperCase(),
                      'year': int.tryParse(yearController.text.trim()),
                      'engine_cc': int.tryParse(ccController.text.trim()),
                      'odometer': int.tryParse(odoController.text.trim()),
                    }).eq('license_plate', vehicle.plate);
                    
                    await ref.read(customerProvider.notifier).loadCustomers();
                    
                    if (context.mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật thông tin xe!'),
                          backgroundColor: AppColors.statusDone,
                        ),
                      );
                    }
                  } catch (e) {
                    print('Error updating vehicle: $e');
                  }
                }
              },
              child: const Text('Lưu', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          title: Text(
            'Xóa xe',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700),
          ),
          content: Text('Bạn có chắc chắn muốn xóa xe biển số $vehiclePlate khỏi hệ thống không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final supabase = Supabase.instance.client;
                  await supabase.from('vehicles').delete().eq('license_plate', vehiclePlate);
                  
                  await ref.read(customerProvider.notifier).loadCustomers();
                  
                  if (context.mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close detail screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa xe thành công!'),
                        backgroundColor: AppColors.statusDone,
                      ),
                    );
                  }
                } catch (e) {
                  print('Error deleting vehicle: $e');
                }
              },
              child: const Text('Xóa', style: TextStyle(color: AppColors.statusError, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
