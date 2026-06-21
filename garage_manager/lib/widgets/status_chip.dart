import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppStatus { done, active, wait, error, idle }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.status});

  final String label;
  final AppStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChipColors {
  const _ChipColors(this.background, this.foreground);

  final Color background;
  final Color foreground;
}

_ChipColors _statusColors(AppStatus status) {
  switch (status) {
    case AppStatus.done:
      return const _ChipColors(AppColors.statusDoneSoft, AppColors.statusDone);
    case AppStatus.active:
      return const _ChipColors(AppColors.accentSoft, AppColors.accent);
    case AppStatus.wait:
      return const _ChipColors(AppColors.statusWaitSoft, AppColors.statusWait);
    case AppStatus.error:
      return const _ChipColors(
        AppColors.statusErrorSoft,
        AppColors.statusError,
      );
    case AppStatus.idle:
      return const _ChipColors(
        AppColors.surfaceSunken,
        AppColors.textSecondary,
      );
  }
}
