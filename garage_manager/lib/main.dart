import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';


import 'providers/inventory_provider.dart'; 

import 'core/fake_data.dart';
import 'core/models.dart';
import 'theme/app_theme.dart';
import 'widgets/app_card.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/invoice_card.dart';
import 'widgets/list_scaffold.dart';
import 'widgets/primary_button.dart';
import 'widgets/stage_timeline.dart';
import 'widgets/status_chip.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const GarageManagerApp());
}

class GarageManagerApp extends StatelessWidget {
  const GarageManagerApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        

      ],
      child: MaterialApp(
        title: 'Garage Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomePlaceholderScreen(),
      ),
    );
  }
}

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featuredInvoice = demoInvoices.first;

    return AppScaffold(
      title: 'Garage Manager',
      navItems: const [
        AppNavItem(icon: Icons.home_outlined, label: 'Tổng quan'),
        AppNavItem(icon: Icons.receipt_long_outlined, label: 'Hóa đơn'),
        AppNavItem(icon: Icons.person_outline, label: 'Tài khoản'),
      ],
      body: ListScaffold(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khung app chung cho team',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Theme, card, chip, button, timeline và invoice card đã sẵn sàng để các nhánh khác dùng chung.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(label: 'Đã xong', status: AppStatus.done),
                    StatusChip(label: 'Đang làm', status: AppStatus.active),
                    StatusChip(label: 'Chờ', status: AppStatus.wait),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          InvoiceCard(
            code: featuredInvoice.code,
            customerName: featuredInvoice.customerName,
            vehiclePlate: featuredInvoice.vehiclePlate,
            totalText: featuredInvoice.totalText,
            statusLabel: featuredInvoice.statusLabel,
            status: _invoiceStatusToAppStatus(featuredInvoice.status),
          ),
          const SizedBox(height: 4),
          PrimaryButton(
            label: 'Tạo phiếu mới',
            icon: Icons.add,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
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