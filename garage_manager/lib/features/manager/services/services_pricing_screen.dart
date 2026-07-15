import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../widgets/list_scaffold.dart';
import '../../../widgets/price_row.dart';
import '../../forms/add_service_form.dart';
import 'service_repository.dart';

class ServicesPricingScreen extends ConsumerWidget {
  const ServicesPricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceListAsync = ref.watch(serviceListProvider);

    return AppScaffold(
      title: 'Dịch vụ & Bảng giá',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddServiceScreen()),
          );
          ref.invalidate(serviceListProvider); // Refresh list after adding
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm DV', style: TextStyle(color: Colors.white)),
      ),
      body: serviceListAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return const Center(child: Text('Chưa có dịch vụ nào.'));
          }
          return ListScaffold(
            children: services.map((service) {
              return PriceRow(
                serviceName: service.name,
                category: 'Dịch vụ',
                price: service.laborPriceText,
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (err, stack) => Center(child: Text('Lỗi: $err')),
      ),
    );
  }
}
