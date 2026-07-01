import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/discount_card.dart';
import '../forms/create_voucher_form.dart';

class VoucherManagementScreen extends StatelessWidget {
  const VoucherManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Quản lý Voucher',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateVoucherScreen()),
          );
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo mã', style: TextStyle(color: Colors.white)),
      ),
      body: ListScaffold(
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: DiscountCard(
              title: 'Giảm 20% phí nhân công',
              code: 'LABOR20',
              description: 'Áp dụng cho mọi hóa đơn bảo dưỡng toàn bộ',
              expiration: '31/12/2026',
              isActive: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: DiscountCard(
              title: 'Giảm 50K thay nhớt',
              code: 'OIL50K',
              description: 'Áp dụng cho khách hàng mới',
              expiration: '15/10/2026',
              isActive: true,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: DiscountCard(
              title: 'Tặng rửa xe miễn phí',
              code: 'WASHFREE',
              description: 'Áp dụng khi hóa đơn trên 1.000.000đ',
              expiration: '30/11/2026',
              isActive: false,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: DiscountCard(
              title: 'Giảm 10% phụ tùng',
              code: 'PART10',
              description: 'Tối đa 200K, áp dụng dòng Honda',
              expiration: '01/01/2026',
              isActive: false,
            ),
          ),
        ],
      ),
    );
  }
}
