import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/list_scaffold.dart';
import '../../widgets/plate_text.dart';
import '../../widgets/status_chip.dart';
import '../../core/app_routes.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final List<Map<String, dynamic>> _vehicles = [
    {
      'name': 'Yamaha Exciter 150 RC',
      'plate': '59-X1 234.56',
      'statusLabel': 'Đang sửa chữa',
      'status': AppStatus.active,
      'lastService': '01/07/2026',
    },
    {
      'name': 'Honda Vario 150',
      'plate': '60-B2 889.12',
      'statusLabel': 'Hoạt động tốt',
      'status': AppStatus.done,
      'lastService': '20/05/2026',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return _vehicles.isEmpty
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
              ..._vehicles.map((vehicle) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.vehicleDetail,
                        arguments: {'plate': vehicle['plate']},
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
                                    vehicle['name'],
                                    style: GoogleFonts.sora(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  PlateText(
                                    vehicle['plate'],
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                            StatusChip(
                              label: vehicle['statusLabel'],
                              status: vehicle['status'],
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
                              vehicle['lastService'],
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
