import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_scaffold.dart';
import 'customer_notifications_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key});

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    String title;

    switch (_currentIndex) {
      case 0:
        title = 'Xe của tôi';
        body = const Center(child: Text('Màn hình Xe của tôi (Chưa làm)'));
        break;
      case 1:
        title = 'Tiến độ';
        body = const Center(child: Text('Màn hình Tiến độ (Chưa làm)'));
        break;
      case 2:
        title = 'Đặt lịch';
        body = const Center(child: Text('Màn hình Đặt lịch (Chưa làm)'));
        break;
      case 3:
        title = 'Hóa đơn';
        body = const Center(child: Text('Màn hình Hóa đơn (Chưa làm)'));
        break;
      case 4:
        title = 'Hồ sơ';
        body = const Center(child: Text('Màn hình Hồ sơ (Chưa làm)'));
        break;
      default:
        title = '';
        body = const SizedBox();
    }

    return AppScaffold(
      title: title,
      currentIndex: _currentIndex,
      onNavChanged: (index) => setState(() => _currentIndex = index),
      actions: [
        IconButton(
          icon: const Badge(
            child: Icon(Icons.notifications_outlined),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerNotificationsScreen()),
            );
          },
        ),
      ],
      navItems: const [
        AppNavItem(icon: Icons.two_wheeler, label: 'Xe của tôi'),
        AppNavItem(icon: Icons.show_chart, label: 'Tiến độ'),
        AppNavItem(icon: Icons.calendar_today, label: 'Đặt lịch'),
        AppNavItem(icon: Icons.receipt_long_outlined, label: 'Hóa đơn'),
        AppNavItem(icon: Icons.person_outline, label: 'Hồ sơ'),
      ],
      body: body,
    );
  }
}
