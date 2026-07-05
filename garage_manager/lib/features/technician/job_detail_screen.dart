import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/stage_timeline.dart';
import '../../core/models.dart';
import '../../core/fake_data.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgApp,
      appBar: AppBar(title: const Text('Chi tiết công việc')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Info Header
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        invoice.vehiclePlate,
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const StatusChip(
                        label: 'Đang sửa',
                        status: AppStatus.active,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Khách hàng: ${invoice.customerName}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress Update Section
            Text(
              'Cập nhật tiến độ',
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: StageTimeline(
                stages: demoRepairStages
                    .map(
                      (stage) => TimelineStage(
                        title: stage.title,
                        description: stage.description,
                        status: _repairStageToAppStatus(stage.status),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Hoàn thành công việc'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppStatus _repairStageToAppStatus(RepairStageStatus status) {
    switch (status) {
      case RepairStageStatus.done:
        return AppStatus.done;
      case RepairStageStatus.active:
        return AppStatus.active;
      case RepairStageStatus.waiting:
        return AppStatus.idle;
    }
  }
}
