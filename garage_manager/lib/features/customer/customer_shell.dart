import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/invoice_card.dart';
import '../../widgets/stage_timeline.dart';
import '../../widgets/status_chip.dart';
import '../../core/fake_data.dart';
import '../../core/models.dart';
import '../../core/app_routes.dart';
import 'vehicle_list_screen.dart';
import 'profile_screen.dart';
import 'customer_notifications_screen.dart';
import 'booking_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _currentIndex = 0;
  InvoicePaymentStatus? _invoiceFilter;

  void _showInvoiceFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Tất cả hóa đơn'),
                leading: const Icon(Icons.receipt_long_outlined),
                selected: _invoiceFilter == null,
                onTap: () {
                  setState(() {
                    _invoiceFilter = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Đã thanh toán'),
                leading: const Icon(Icons.check_circle_outline),
                selected: _invoiceFilter == InvoicePaymentStatus.paid,
                onTap: () {
                  setState(() {
                    _invoiceFilter = InvoicePaymentStatus.paid;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Đang xử lý'),
                leading: const Icon(Icons.hourglass_empty_outlined),
                selected: _invoiceFilter == InvoicePaymentStatus.processing,
                onTap: () {
                  setState(() {
                    _invoiceFilter = InvoicePaymentStatus.processing;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Chưa thanh toán'),
                leading: const Icon(Icons.error_outline),
                selected: _invoiceFilter == InvoicePaymentStatus.unpaid,
                onTap: () {
                  setState(() {
                    _invoiceFilter = InvoicePaymentStatus.unpaid;
                  });
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const VehicleListScreen(),
      const _CustomerProgressTab(),
      const BookingScreen(),
      _CustomerInvoicesTab(statusFilter: _invoiceFilter),
      const ProfileScreen(),
    ];

    final titles = [
      'Xe của tôi',
      'Tiến độ sửa chữa',
      'Đặt lịch hẹn',
      'Hóa đơn của tôi',
      'Hồ sơ khách hàng',
    ];

    return AppScaffold(
      title: titles[_currentIndex],
      currentIndex: _currentIndex,
      onNavChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      navItems: const [
        AppNavItem(icon: Icons.motorcycle_outlined, label: 'Xe của tôi'),
        AppNavItem(icon: Icons.timeline_outlined, label: 'Tiến độ'),
        AppNavItem(icon: Icons.calendar_month_outlined, label: 'Đặt lịch'),
        AppNavItem(icon: Icons.receipt_long_outlined, label: 'Hóa đơn'),
        AppNavItem(icon: Icons.person_outline, label: 'Hồ sơ'),
      ],
      actions: [
        if (_currentIndex == 3)
          IconButton(
            tooltip: 'Lọc hóa đơn',
            icon: const Icon(Icons.filter_list),
            onPressed: _showInvoiceFilterSheet,
          ),
        IconButton(
          icon: const Badge(child: Icon(Icons.notifications_outlined)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CustomerNotificationsScreen(),
              ),
            );
          },
        ),
      ],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_road_outlined),
              onPressed: () {
                // Navigate to F1 Form (Thêm xe)
                Navigator.of(context).pushNamed(AppRoutes.addVehicle);
              },
            )
          : null,
      body: pages[_currentIndex],
    );
  }
}

// B2: Progress tracking tab integrating StageTimeline
class _CustomerProgressTab extends StatelessWidget {
  const _CustomerProgressTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yamaha Exciter 150 RC',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const StatusChip(
                      label: 'Đang làm',
                      status: AppStatus.active,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Biển số: 59-X1 234.56',
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quy trình dịch vụ',
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: StageTimeline(
              stages: demoRepairStages
                  .map(
                    (stage) => TimelineStage(
                      title: stage.title,
                      description: stage.description,
                      status: _repairStageToAppStatus(stage.status),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  AppStatus _repairStageToAppStatus(RepairStageStatus status) {
    switch (status) {
      case RepairStageStatus.done:
        return AppStatus.done;
      case RepairStageStatus.active:
        return AppStatus.active;
      case RepairStageStatus.waiting:
        return AppStatus.idle;
    }
  }
}

// B4: Invoices tracking tab integrating InvoiceCard
class _CustomerInvoicesTab extends StatelessWidget {
  const _CustomerInvoicesTab({this.statusFilter});

  final InvoicePaymentStatus? statusFilter;

  @override
  Widget build(BuildContext context) {
    final invoices = demoInvoices
        .where(
          (invoice) => statusFilter == null || invoice.status == statusFilter,
        )
        .toList();

    if (invoices.isEmpty) {
      return Center(
        child: Text(
          'Không có hóa đơn phù hợp',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InvoiceCard(
          code: invoice.code,
          customerName: invoice.customerName,
          vehiclePlate: invoice.vehiclePlate,
          totalText: invoice.totalText,
          statusLabel: invoice.statusLabel,
          status: _invoiceStatusToAppStatus(invoice.status),
          onTap: () {
            Navigator.of(
              context,
            ).pushNamed(AppRoutes.invoiceDetail, arguments: invoice);
          },
        );
      },
    );
  }

  AppStatus _invoiceStatusToAppStatus(InvoicePaymentStatus status) {
    switch (status) {
      case InvoicePaymentStatus.paid:
        return AppStatus.done;
      case InvoicePaymentStatus.unpaid:
        return AppStatus.error;
      case InvoicePaymentStatus.processing:
        return AppStatus.wait;
    }
  }
}
