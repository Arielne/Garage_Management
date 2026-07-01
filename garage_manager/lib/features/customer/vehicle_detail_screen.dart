import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/plate_text.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({super.key, required this.vehiclePlate});

  final String vehiclePlate;

  @override
  Widget build(BuildContext context) {
    // Dynamic naming based on plate arguments
    final String vehicleName = vehiclePlate == '60-B2 889.12' 
        ? 'Honda Vario 150' 
        : 'Yamaha Exciter 150 RC';

    final List<Map<String, dynamic>> serviceHistory = vehiclePlate == '60-B2 889.12'
        ? [
            {
              'date': '20/05/2026',
              'workOrder': 'WO-2026-004',
              'cost': '850.000đ',
              'notes': 'Thay nhớt Motul, lọc gió K&N, vệ sinh nồi xe ga.',
              'type': 'Bảo dưỡng định kỳ',
            }
          ]
        : [
            {
              'date': '01/07/2026',
              'workOrder': 'WO-2026-012',
              'cost': '2.450.000đ',
              'notes': 'Lắp pô độ Akrapovic, căn chỉnh xăng gió (Dynojet).',
              'type': 'Độ & Nâng cấp',
            },
            {
              'date': '15/04/2026',
              'workOrder': 'WO-2026-001',
              'cost': '1.200.000đ',
              'notes': 'Thay lốp trước/sau Michelin City Grip 2.',
              'type': 'Bảo dưỡng định kỳ',
            }
          ];

    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(
        title: const Text('Chi tiết xe'),
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Header Card
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.motorcycle,
                          size: 32,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleName,
                              style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: PlateText(
                                vehiclePlate,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 16),
                  
                  // Specs rows
                  _buildSpecRow('Hãng xe', vehicleName.contains('Honda') ? 'Honda' : 'Yamaha'),
                  const SizedBox(height: 10),
                  _buildSpecRow('Loại xe', vehicleName.contains('Vario') ? 'Xe ga (Scooter)' : 'Xe số/Côn tay (Underbone)'),
                  const SizedBox(height: 10),
                  _buildSpecRow('Năm sản xuất', '2020'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Service History Section
            Text(
              'Lịch sử bảo dưỡng & nâng cấp',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (serviceHistory.isEmpty)
              AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Chưa có lịch sử bảo dưỡng',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ...serviceHistory.map((history) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              history['date'],
                              style: GoogleFonts.robotoMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: history['type'] == 'Độ & Nâng cấp' 
                                    ? AppColors.accentSoft 
                                    : AppColors.surfaceSunken,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                history['type'],
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: history['type'] == 'Độ & Nâng cấp' 
                                      ? AppColors.accent 
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Mã phiếu:',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 6),
                            PlateText(history['workOrder'], fontSize: 13, color: AppColors.textPrimary),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          history['notes'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chi phí:',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Text(
                              history['cost'],
                              style: GoogleFonts.robotoMono(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
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
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
