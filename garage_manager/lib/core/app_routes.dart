import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/customer/customer_shell.dart';
import '../features/customer/vehicle_detail_screen.dart';
import '../features/forms/add_customer_form.dart';
import '../features/forms/add_vehicle_form.dart';
import '../features/manager/manager_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // Shells
  static const String customerShell = '/customer/shell';
  static const String managerShell = '/manager/shell';
  
  // Sub-pages/Forms
  static const String addCustomer = '/add-customer';
  static const String addVehicle = '/add-vehicle';
  static const String vehicleDetail = '/vehicle-detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case customerShell:
        return MaterialPageRoute(
          builder: (_) => const CustomerShell(),
          settings: settings,
        );
      case managerShell:
        return MaterialPageRoute(
          builder: (_) => const ManagerShell(),
          settings: settings,
        );
      case addCustomer:
        return MaterialPageRoute(
          builder: (_) => const AddCustomerForm(),
          settings: settings,
        );
      case addVehicle:
        return MaterialPageRoute(
          builder: (_) => const AddVehicleForm(),
          settings: settings,
        );
      case vehicleDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final plate = args?['plate'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => VehicleDetailScreen(vehiclePlate: plate),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
