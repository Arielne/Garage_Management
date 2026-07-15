import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/customer/customer_shell.dart';
import '../features/customer/invoices/invoice_detail_screen.dart';
import '../features/customer/vehicle_detail_screen.dart';
import '../features/forms/add_customer_form.dart';
import '../features/forms/add_vehicle_form.dart';
import '../features/manager/customers/customer_detail_screen.dart';
import '../features/manager/manager_shell.dart';
import '../features/manager/jobs/appointment_management_screen.dart';
import '../features/technician/technician_shell.dart';
import '../features/technician/job_detail_screen.dart';
import '../features/technician/notification_screen.dart';
import '../features/technician/technician_personal_info_screen.dart';
import '../features/manager/jobs/assign_job_screen.dart';
import 'fake_data.dart';

import 'models.dart';

class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Shells
  static const String customerShell = '/customer/shell';
  static const String managerShell = '/manager/shell';
  static const String technicianShell = '/technician/shell';

  // Sub-pages/Forms
  static const String addCustomer = '/add-customer';
  static const String addVehicle = '/add-vehicle';
  static const String vehicleDetail = '/vehicle-detail';
  static const String invoiceDetail = '/invoice-detail';
  static const String customerDetail = '/manager/customer-detail';
  static const String jobDetail = '/technician/job-detail';
  static const String notificationJobs = '/technician/notification';
  static const String technicianPersonalInfo = '/technician/personal-info';
  static const String assignJob = '/manager/jobs/assign';
  static const String appointmentManagement =
      '/manager/jobs/appointment-management';
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
      case technicianShell:
        return MaterialPageRoute(
          builder: (_) => const TechnicianShell(),
          settings: settings,
        );
      case appointmentManagement:
        return MaterialPageRoute(
          builder: (_) => const AppointmentManagementScreen(),
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
      case invoiceDetail:
        if (settings.arguments is! Invoice) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Không tìm thấy hóa đơn.')),
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              InvoiceDetailScreen(invoice: settings.arguments as Invoice),
          settings: settings,
        );
      case customerDetail:
        final phone = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CustomerDetailScreen(customerPhone: phone),
          settings: settings,
        );
      case jobDetail:
        final jobData = settings.arguments as Map<String, dynamic>;

        return MaterialPageRoute(
          builder: (_) => JobDetailScreen(jobData: jobData),
          settings: settings,
        );
      case notificationJobs:
        return MaterialPageRoute(
          builder: (_) => const NotificationScreen(),
          settings: settings,
        );
      case assignJob:
        final apt = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AssignJobScreen(appointment: apt),
          settings: settings,
        );
      case technicianPersonalInfo:
        return MaterialPageRoute(
          builder: (_) => const TechnicianPersonalInfoScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Không tìm thấy trang: ${settings.name}')),
          ),
        );
    }
  }
}
