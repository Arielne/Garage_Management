import 'package:flutter/material.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/app_scaffold.dart';
import 'widgets/list_scaffold.dart';
import 'features/manager/screens/manager_main_screen.dart';
import 'features/customer/screens/customer_main_screen.dart';

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
      home: const RoleSelectionScreen(),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Garage Manager (Test)',
      body: ListScaffold(
        children: [
          const Text(
            'Chọn phân hệ để Test',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagerMainScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: AppColors.accent, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quản lý (Manager)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Xem luồng D7, D8, D6, F5'),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerMainScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.statusDone),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person, color: AppColors.statusDone, size: 40),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Khách hàng (Customer)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Xem luồng B5 (Thông báo)'),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

