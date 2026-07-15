import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleModel {
  final String name;
  final String plate;
  final String statusLabel;
  final String status; // active (đang sửa), done (hoạt động tốt), vv.
  final String lastService;
  final int? engineCc;
  final int? year;
  final int? odometer;
  final String? imageUrl;

  VehicleModel({
    required this.name,
    required this.plate,
    required this.statusLabel,
    required this.status,
    required this.lastService,
    this.engineCc,
    this.year,
    this.odometer,
    this.imageUrl,
  });

  VehicleModel copyWith({
    String? name,
    String? plate,
    String? statusLabel,
    String? status,
    String? lastService,
    int? engineCc,
    int? year,
    int? odometer,
    String? imageUrl,
  }) {
    return VehicleModel(
      name: name ?? this.name,
      plate: plate ?? this.plate,
      statusLabel: statusLabel ?? this.statusLabel,
      status: status ?? this.status,
      lastService: lastService ?? this.lastService,
      engineCc: engineCc ?? this.engineCc,
      year: year ?? this.year,
      odometer: odometer ?? this.odometer,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class ServiceHistoryModel {
  final String date;
  final String workOrder;
  final String cost;
  final String notes;
  final String type;
  final String vehiclePlate;

  ServiceHistoryModel({
    required this.date,
    required this.workOrder,
    required this.cost,
    required this.notes,
    required this.type,
    required this.vehiclePlate,
  });
}

class CustomerDetailModel {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final List<VehicleModel> vehicles;
  final List<ServiceHistoryModel> serviceHistory;
  final String lastVisit;
  final String? userId;

  CustomerDetailModel({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.vehicles,
    required this.serviceHistory,
    required this.lastVisit,
    this.userId,
  });

  CustomerDetailModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    List<VehicleModel>? vehicles,
    List<ServiceHistoryModel>? serviceHistory,
    String? lastVisit,
    String? userId,
  }) {
    return CustomerDetailModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vehicles: vehicles ?? this.vehicles,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      lastVisit: lastVisit ?? this.lastVisit,
      userId: userId ?? this.userId,
    );
  }
}

class CustomerNotifier extends Notifier<List<CustomerDetailModel>> {
  @override
  List<CustomerDetailModel> build() {
    // Trigger async load on build
    Future.microtask(() => loadCustomers());
    return [];
  }

  Future<void> loadCustomers() async {
    try {
      final supabase = Supabase.instance.client;
      // Fetch customers, their vehicles, and nested work_orders + invoices
      final List<dynamic> customersData = await supabase
          .from('customers')
          .select('*, vehicles(*, work_orders(*, invoices(*)))');
      
      String formatCost(dynamic total) {
        if (total == null) return '0đ';
        final int val = (total is num) ? total.toInt() : int.tryParse(total.toString()) ?? 0;
        if (val == 0) return '0đ';
        final String valStr = val.toString();
        final buffer = StringBuffer();
        for (int i = 0; i < valStr.length; i++) {
          if (i > 0 && (valStr.length - i) % 3 == 0) {
            buffer.write('.');
          }
          buffer.write(valStr[i]);
        }
        buffer.write('đ');
        return buffer.toString();
      }

      final List<CustomerDetailModel> loaded = [];
      for (final c in customersData) {
        final List<dynamic> vehiclesData = c['vehicles'] ?? [];
        final List<VehicleModel> vehicles = [];
        final List<ServiceHistoryModel> serviceHistoryList = [];

        for (final v in vehiclesData) {
          final List<dynamic> workOrdersData = v['work_orders'] ?? [];
          final String plate = v['license_plate'] ?? '';
          
          bool isRepairing = false;
          String statusLabel = 'Hoạt động tốt';
          String status = 'done';
          String lastServiceDate = 'Chưa bảo dưỡng';

          for (final wo in workOrdersData) {
            if (wo['status'] == 'dang_xu_ly') {
              isRepairing = true;
            }
            
            final List<dynamic> invoicesData = wo['invoices'] ?? [];
            final dynamic invoice = invoicesData.isNotEmpty ? invoicesData.first : null;
            final dynamic totalAmount = invoice != null ? invoice['total'] : 0;
            
            String dateStr = 'Chưa rõ';
            if (wo['created_at'] != null) {
              try {
                final date = DateTime.parse(wo['created_at'].toString()).toLocal();
                dateStr = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
              } catch (_) {}
            }

            if (dateStr != 'Chưa rõ') {
              lastServiceDate = dateStr;
            }

            serviceHistoryList.add(
              ServiceHistoryModel(
                date: dateStr,
                workOrder: 'WO-${wo['id']}',
                cost: formatCost(totalAmount),
                notes: wo['description'] ?? 'Không có ghi chú.',
                type: wo['description']?.toString().toLowerCase().contains('bảo dưỡng') == true
                    ? 'Bảo dưỡng định kỳ'
                    : 'Sửa chữa hao mòn',
                vehiclePlate: plate,
              ),
            );
          }

          if (isRepairing) {
            statusLabel = 'Đang sửa chữa';
            status = 'active';
          }

          vehicles.add(
            VehicleModel(
              name: v['model'] ?? 'Chưa rõ dòng xe',
              plate: plate,
              statusLabel: statusLabel,
              status: status,
              lastService: lastServiceDate,
              engineCc: v['engine_cc'],
              year: v['year'],
              odometer: v['odometer'],
              imageUrl: v['image_url'],
            ),
          );
        }

        loaded.add(
          CustomerDetailModel(
            id: c['id'] as int?,
            name: c['full_name'] ?? 'Không tên',
            phone: c['phone'] ?? '',
            email: c['email'] ?? '',
            address: 'Địa chỉ chưa cập nhật',
            vehicles: vehicles,
            serviceHistory: serviceHistoryList,
            lastVisit: 'Chưa có thông tin',
            userId: c['user_id']?.toString(),
          ),
        );
      }
      state = loaded;
    } catch (e) {
      print('Error loading customers: $e');
    }
  }

  Future<void> updateCustomer(String originalPhone, CustomerDetailModel updated) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('customers').update({
        'full_name': updated.name,
        'phone': updated.phone,
        'email': updated.email,
      }).eq('phone', originalPhone);
      await loadCustomers();
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(String phone) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('customers').delete().eq('phone', phone);
      await loadCustomers();
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }

  Future<void> addCustomer(CustomerDetailModel customer) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('customers').insert({
        'full_name': customer.name,
        'phone': customer.phone,
        'email': customer.email,
      });
      await loadCustomers();
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  Future<void> addVehicleToCustomer(String identifier, VehicleModel vehicle, {bool isUserId = false}) async {
    try {
      final supabase = Supabase.instance.client;
      final query = supabase.from('customers').select('id');
      final customerData = isUserId
          ? await query.eq('user_id', identifier).maybeSingle()
          : await query.eq('phone', identifier).maybeSingle();
      
      if (customerData != null) {
        final customerId = customerData['id'];
        await supabase.from('vehicles').insert({
          'customer_id': customerId,
          'license_plate': vehicle.plate,
          'model': vehicle.name,
          'engine_cc': vehicle.engineCc,
          'year': vehicle.year,
          'odometer': vehicle.odometer,
          'image_url': vehicle.imageUrl,
        });
        await loadCustomers();
      }
    } catch (e) {
      print('Error adding vehicle to customer: $e');
    }
  }
}

final customerProvider = NotifierProvider<CustomerNotifier, List<CustomerDetailModel>>(() {
  return CustomerNotifier();
});
