import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models.dart';
import '../invoices/invoice_repository.dart' show authUserIdProvider;

/// 5 công đoạn cố định của một phiếu sửa xe (khớp enum `work_stage` trong DB).
/// Thứ tự này quyết định giai đoạn nào đã xong / đang làm / chờ.
/// Nhãn đã chốt theo kế hoạch — nếu Vỹ đổi tên thì sửa map ở đây.
const _stageOrder = ['tiep_nhan', 'thao_lap', 'thay_do', 'chay_thu', 'ban_giao'];

const _stageTitles = {
  'tiep_nhan': 'Tiếp nhận xe',
  'thao_lap': 'Kiểm tra & tháo lắp',
  'thay_do': 'Thay thế & nâng cấp',
  'chay_thu': 'Chạy thử',
  'ban_giao': 'Bàn giao & thanh toán',
};

const _stageDefaultDesc = {
  'tiep_nhan': 'Khách đã gửi xe và mô tả tình trạng.',
  'thao_lap': 'Thợ kiểm tra tổng quát và tháo lắp cần thiết.',
  'thay_do': 'Thay thế phụ tùng và nâng cấp theo báo giá.',
  'chay_thu': 'Chạy thử, kiểm tra lại toàn bộ hạng mục.',
  'ban_giao': 'Bàn giao xe và hoàn tất thanh toán.',
};

/// Tiến độ sửa chữa của MỘT phiếu công việc (1 xe đang sửa).
class VehicleProgress {
  const VehicleProgress({
    required this.workOrderId,
    required this.vehicleName,
    required this.plate,
    required this.statusLabel,
    required this.status,
    required this.stages,
  });

  final int workOrderId;
  final String vehicleName;
  final String plate;
  final String statusLabel;
  final RepairStageStatus status;
  final List<RepairStage> stages;
}

/// Repository B2 — chỉ đọc phiếu công việc CỦA KHÁCH ĐANG ĐĂNG NHẬP.
/// Lọc theo `work_orders.customer_id` = khách khớp `auth.currentUser`
/// nên khách chỉ thấy xe của mình. Đọc bảng của Vỹ (work_orders,
/// work_order_stages), không sửa.
class ProgressRepository {
  ProgressRepository(this._client);

  final SupabaseClient _client;

  Future<List<VehicleProgress>> getMyActiveProgress() async {
    final user = _client.auth.currentUser;
    if (user == null) return const [];

    // Tìm id khách khớp tài khoản đang đăng nhập (theo user_id hoặc email).
    final orParts = <String>['user_id.eq.${user.id}'];
    final email = user.email;
    if (email != null && email.isNotEmpty) {
      orParts.add('email.eq.$email');
    }
    final customerRows = await _client
        .from('customers')
        .select('id')
        .or(orParts.join(','))
        .limit(1);
    if (customerRows.isEmpty) return const [];
    final customerId = customerRows.first['id'];

    // Phiếu đang theo dõi = chưa bàn giao. Kèm xe + các công đoạn.
    final rows = await _client
        .from('work_orders')
        .select(
          'id, current_stage, status, '
          'vehicles(license_plate, model), '
          'work_order_stages(stage, done, note)',
        )
        .eq('customer_id', customerId)
        .neq('status', 'da_ban_giao')
        .order('created_at', ascending: false);

    return rows.map<VehicleProgress>(_toProgress).toList();
  }

  VehicleProgress _toProgress(Map<String, dynamic> row) {
    final vehicle = (row['vehicles'] ?? {}) as Map<String, dynamic>;
    final currentStage = (row['current_stage'] ?? 'tiep_nhan') as String;
    final workStatus = (row['status'] ?? 'dang_xu_ly') as String;
    final currentIndex = _stageOrder.indexOf(currentStage);

    // Gom các dòng work_order_stages theo tên giai đoạn (nếu Vỹ có ghi).
    final stageRows = (row['work_order_stages'] ?? []) as List;
    final byStage = <String, Map<String, dynamic>>{
      for (final s in stageRows.cast<Map<String, dynamic>>())
        (s['stage'] ?? '') as String: s,
    };

    final allDone = workStatus == 'da_ban_giao' || workStatus == 'hoan_thanh';

    final stages = <RepairStage>[];
    for (var i = 0; i < _stageOrder.length; i++) {
      final key = _stageOrder[i];
      final stageRow = byStage[key];
      final markedDone = (stageRow?['done'] ?? false) as bool;

      final RepairStageStatus st;
      if (allDone || markedDone || (currentIndex >= 0 && i < currentIndex)) {
        st = RepairStageStatus.done;
      } else if (i == currentIndex) {
        st = RepairStageStatus.active;
      } else {
        st = RepairStageStatus.waiting;
      }

      final note = (stageRow?['note'] ?? '') as String;
      stages.add(
        RepairStage(
          title: _stageTitles[key] ?? key,
          description: note.isNotEmpty ? note : (_stageDefaultDesc[key] ?? ''),
          status: st,
        ),
      );
    }

    final (statusLabel, status) = switch (workStatus) {
      'hoan_thanh' => ('Hoàn thành', RepairStageStatus.done),
      'da_ban_giao' => ('Đã bàn giao', RepairStageStatus.done),
      _ => ('Đang sửa', RepairStageStatus.active),
    };

    return VehicleProgress(
      workOrderId: (row['id'] ?? 0) as int,
      vehicleName: (vehicle['model'] ?? 'Chưa rõ dòng xe') as String,
      plate: (vehicle['license_plate'] ?? '') as String,
      statusLabel: statusLabel,
      status: status,
      stages: stages,
    );
  }
}

// ===== Riverpod providers =====

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(Supabase.instance.client);
});

/// Tiến độ các xe đang sửa của khách đang đăng nhập (B2).
/// Watch [authUserIdProvider] để đổi tài khoản là nạp lại, không dùng lại
/// cache của khách trước.
final myProgressProvider = FutureProvider<List<VehicleProgress>>((ref) {
  ref.watch(authUserIdProvider);
  return ref.watch(progressRepositoryProvider).getMyActiveProgress();
});
