import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'widgets/app_card.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/invoice_card.dart';
import 'widgets/list_scaffold.dart';
import 'widgets/primary_button.dart';
import 'widgets/stage_timeline.dart';
import 'widgets/status_chip.dart';

void main() {
  runApp(const GarageManagerApp());
}

class GarageManagerApp extends StatelessWidget {
  const GarageManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePlaceholderScreen(),
    );
  }
}

class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          const AppCard(
            child: StageTimeline(
              stages: [
                TimelineStage(
                  title: 'Tiếp nhận xe',
                  description: 'Khách đã gửi xe và mô tả tình trạng.',
                  status: AppStatus.done,
                ),
                TimelineStage(
                  title: 'Kiểm tra',
                  description: 'Thợ đang kiểm tra phụ tùng và báo giá.',
                  status: AppStatus.active,
                ),
                TimelineStage(
                  title: 'Hoàn tất',
                  description: 'Chờ hoàn tất sửa chữa và thanh toán.',
                  status: AppStatus.idle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InvoiceCard(
            code: 'HD-2026-001',
            customerName: 'Nguyễn Văn An',
            vehiclePlate: '59-X1 234.56',
            totalText: '2.450.000đ',
            statusLabel: 'Đã thanh toán',
            status: AppStatus.done,
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
