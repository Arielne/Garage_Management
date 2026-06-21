import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'status_chip.dart';

class StageTimeline extends StatelessWidget {
  const StageTimeline({super.key, required this.stages});

  final List<TimelineStage> stages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < stages.length; index++)
          _TimelineRow(
            stage: stages[index],
            isLast: index == stages.length - 1,
          ),
      ],
    );
  }
}

class TimelineStage {
  const TimelineStage({
    required this.title,
    required this.description,
    required this.status,
  });

  final String title;
  final String description;
  final AppStatus status;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.stage, required this.isLast});

  final TimelineStage stage;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(stage.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: stage.status == AppStatus.done
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: AppColors.divider),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color _stageColor(AppStatus status) {
  switch (status) {
    case AppStatus.done:
      return AppColors.statusDone;
    case AppStatus.active:
      return AppColors.accent;
    case AppStatus.wait:
      return AppColors.statusWait;
    case AppStatus.error:
      return AppColors.statusError;
    case AppStatus.idle:
      return AppColors.statusIdle;
  }
}
