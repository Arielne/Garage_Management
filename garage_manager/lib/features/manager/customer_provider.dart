import 'package:flutter_riverpod/flutter_riverpod.dart';

class VehicleModel {
  final String name;
  final String plate;
  final String statusLabel;
  final String status; // active (đang sửa), done (hoạt động tốt), vv.

  VehicleModel({
    required this.name,
    required this.plate,
    required this.statusLabel,
    required this.status,
  });

  VehicleModel copyWith({
    String? name,
    String? plate,
    String? statusLabel,
    String? status,
  }) {
    return VehicleModel(
      name: name ?? this.name,
      plate: plate ?? this.plate,
      statusLabel: statusLabel ?? this.statusLabel,
      status: status ?? this.status,
    );
  }
}

class ServiceHistoryModel {
  final String date;
  final String workOrder;
  final String cost;
  final String notes;
  final String type;

  ServiceHistoryModel({
    required this.date,
    required this.workOrder,
    required this.cost,
    required this.notes,
    required this.type,
  });
}

class CustomerDetailModel {
  final String name;
  final String phone;
  final String email;
  final String address;
  final List<VehicleModel> vehicles;
  final List<ServiceHistoryModel> serviceHistory;
  final String lastVisit;

  CustomerDetailModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    required this.vehicles,
    required this.serviceHistory,
    required this.lastVisit,
  });

  CustomerDetailModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
    List<VehicleModel>? vehicles,
    List<ServiceHistoryModel>? serviceHistory,
    String? lastVisit,
  }) {
    return CustomerDetailModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      vehicles: vehicles ?? this.vehicles,
      serviceHistory: serviceHistory ?? this.serviceHistory,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}

class CustomerNotifier extends Notifier<List<CustomerDetailModel>> {
  @override
  List<CustomerDetailModel> build() {
    return [
      CustomerDetailModel(
        name: 'Nguyễn Văn An',
        phone: '0987654321',
        email: 'an.nguyen@gmail.com',
        address: '123 Đường Ba Tháng Hai, Quận 10, TP. Hồ Chí Minh',
        vehicles: [
          VehicleModel(
            name: 'Yamaha Exciter 150 RC',
            plate: '59-X1 234.56',
            statusLabel: 'Đang sửa chữa',
            status: 'active',
          ),
          VehicleModel(
            name: 'Honda Vision 110',
            plate: '59-X1 999.88',
            statusLabel: 'Hoạt động tốt',
            status: 'done',
          ),
        ],
        serviceHistory: [
          ServiceHistoryModel(
            date: '01/07/2026',
            workOrder: 'WO-2026-012',
            cost: '2.450.000đ',
            notes: 'Lắp pô độ Akrapovic, căn chỉnh xăng gió (Dynojet).',
            type: 'Độ & Nâng cấp',
          ),
          ServiceHistoryModel(
            date: '15/04/2026',
            workOrder: 'WO-2026-001',
            cost: '1.200.000đ',
            notes: 'Thay lốp trước/sau Michelin City Grip 2.',
            type: 'Bảo dưỡng định kỳ',
          ),
        ],
        lastVisit: 'Hôm qua',
      ),
      CustomerDetailModel(
        name: 'Trần Minh Khoa',
        phone: '0901234567',
        email: 'khoa.tran@yahoo.com',
        address: '456 Lê Hồng Phong, Quận 5, TP. Hồ Chí Minh',
        vehicles: [
          VehicleModel(
            name: 'Honda Vario 150',
            plate: '60-B2 889.12',
            statusLabel: 'Hoạt động tốt',
            status: 'done',
          ),
        ],
        serviceHistory: [
          ServiceHistoryModel(
            date: '20/05/2026',
            workOrder: 'WO-2026-004',
            cost: '850.000đ',
            notes: 'Thay nhớt Motul, lọc gió K&N, vệ sinh nồi xe ga.',
            type: 'Bảo dưỡng định kỳ',
          ),
        ],
        lastVisit: '24/06/2026',
      ),
      CustomerDetailModel(
        name: 'Phạm Quốc Tuấn',
        phone: '0912345678',
        email: 'tuan.pq@gmail.com',
        address: '789 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh',
        vehicles: [
          VehicleModel(
            name: 'Suzuki Raider 150 Fi',
            plate: '59-S3 555.55',
            statusLabel: 'Đang sửa chữa',
            status: 'active',
          ),
          VehicleModel(
            name: 'Honda Winner X 150',
            plate: '59-S3 777.77',
            statusLabel: 'Hoạt động tốt',
            status: 'done',
          ),
          VehicleModel(
            name: 'Vespa Sprint 125',
            plate: '59-S3 888.88',
            statusLabel: 'Hoạt động tốt',
            status: 'done',
          ),
        ],
        serviceHistory: [
          ServiceHistoryModel(
            date: '15/06/2026',
            workOrder: 'WO-2026-009',
            cost: '1.800.000đ',
            notes: 'Thay nhông sên dĩa DID vàng, thay má phanh Nissin.',
            type: 'Sửa chữa hao mòn',
          ),
        ],
        lastVisit: '15/06/2026',
      ),
      CustomerDetailModel(
        name: 'Lê Thị Mai',
        phone: '0977889900',
        email: 'mai.le@outlook.com',
        address: '101 Cách Mạng Tháng Tám, Quận 3, TP. Hồ Chí Minh',
        vehicles: [
          VehicleModel(
            name: 'Honda Lead 125',
            plate: '59-H1 123.45',
            statusLabel: 'Hoạt động tốt',
            status: 'done',
          ),
        ],
        serviceHistory: [
          ServiceHistoryModel(
            date: '30/06/2026',
            workOrder: 'WO-2026-011',
            cost: '320.000đ',
            notes: 'Thay nhớt máy Wolver, nhớt hộp số láp Liqui Moly.',
            type: 'Bảo dưỡng nhanh',
          ),
        ],
        lastVisit: 'Vừa mới đây',
      ),
    ];
  }

  void updateCustomer(String originalPhone, CustomerDetailModel updated) {
    state = [
      for (final customer in state)
        if (customer.phone == originalPhone) updated else customer
    ];
  }

  void deleteCustomer(String phone) {
    state = state.where((customer) => customer.phone != phone).toList();
  }

  void addCustomer(CustomerDetailModel customer) {
    state = [...state, customer];
  }
}

final customerProvider = NotifierProvider<CustomerNotifier, List<CustomerDetailModel>>(() {
  return CustomerNotifier();
});
