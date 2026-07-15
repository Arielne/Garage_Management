import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/plate_text.dart';
import '../../widgets/status_chip.dart';
import '../../core/app_routes.dart';
import '../manager/customers/customer_provider.dart';

class VehicleListScreen extends ConsumerWidget {
  const VehicleListScreen({super.key});

  AppStatus _mapStringStatusToAppStatus(String status) {
    switch (status) {
      case 'active':
        return AppStatus.active;
      case 'done':
        return AppStatus.done;
      case 'wait':
        return AppStatus.wait;
      case 'error':
        return AppStatus.error;
      default:
        return AppStatus.idle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read list of customers from Riverpod
    final customers = ref.watch(customerProvider);
    
    // Find the current logged-in customer matching by user_id or email
    final currentUser = Supabase.instance.client.auth.currentUser;
    final customer = customers.firstWhere(
      (c) => c.userId == currentUser?.id || c.email == currentUser?.email,
      orElse: () => CustomerDetailModel(
        name: currentUser?.userMetadata?['full_name'] ?? 'Khách hàng',
        phone: '',
        email: currentUser?.email ?? '',
        address: 'Địa chỉ chưa cập nhật',
        vehicles: [],
        serviceHistory: [],
        lastVisit: 'Hôm nay',
        userId: currentUser?.id,
      ),
    );

    final vehicles = customer.vehicles;

    return vehicles.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.motorcycle_outlined, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa đăng ký xe nào',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thêm xe của bạn để đặt lịch và theo dõi bảo dưỡng.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )
        : ListScaffold(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Danh sách xe của bạn',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...vehicles.map((vehicle) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.vehicleDetail,
                        arguments: {'plate': vehicle.plate},
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vehicle.name,
                                    style: GoogleFonts.sora(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  PlateText(
                                    vehicle.plate,
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: vehicle.statusLabel,
                              status: _mapStringStatusToAppStatus(vehicle.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.history_outlined, size: 16, color: AppColors.textTertiary),
                                const SizedBox(width: 6),
                                Text(
                                  'Bảo dưỡng gần nhất:',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              vehicle.lastService,
                              style: GoogleFonts.robotoMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
  }
}
