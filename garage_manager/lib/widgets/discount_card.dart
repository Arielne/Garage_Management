import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_card.dart';

class DiscountCard extends StatelessWidget {
  final String title;
  final String code;
  final String description;
  final String expiration;
  final bool isActive;
  final VoidCallback? onDelete;
  final VoidCallback? onReactivate;

  const DiscountCard({
    super.key,
    required this.title,
    required this.code,
    required this.description,
    required this.expiration,
    this.isActive = true,
    this.onDelete,
    this.onReactivate,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? AppColors.accentSoft : AppColors.surfaceSunken,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.local_offer_outlined,
              color: isActive ? AppColors.accent : AppColors.textTertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                            ),
                      ),
                    ),
                    if (isActive && onDelete != null)
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.delete_outline, color: AppColors.statusError, size: 20),
                        ),
                      ),
                    if (!isActive && onReactivate != null)
                      InkWell(
                        onTap: onReactivate,
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.restore, color: AppColors.statusDone, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSunken,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'Roboto Mono',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'HSD: $expiration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isActive ? AppColors.textSecondary : AppColors.textTertiary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
