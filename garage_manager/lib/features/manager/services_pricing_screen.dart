import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/price_row.dart';
import '../forms/add_service_form.dart';

class ServicesPricingScreen extends StatelessWidget {
  const ServicesPricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dịch vụ & Bảng giá',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm DV', style: TextStyle(color: Colors.white)),
      ),
      body: ListScaffold(
        children: const [
          PriceRow(
            serviceName: 'Thay nhớt máy',
            category: 'Bảo dưỡng định kỳ',
            price: '150.000đ',
          ),
          PriceRow(
            serviceName: 'Rửa xe bọt tuyết',
            category: 'Vệ sinh',
            price: '50.000đ',
          ),
          PriceRow(
            serviceName: 'Bảo dưỡng toàn bộ',
            category: 'Bảo dưỡng lớn',
            price: '2.500.000đ',
          ),
          PriceRow(
            serviceName: 'Thay lọc gió',
            category: 'Phụ tùng',
            price: '85.000đ',
          ),
        ],
      ),
    );
  }
}
