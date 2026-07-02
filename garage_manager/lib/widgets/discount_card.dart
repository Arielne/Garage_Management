import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/app_card.dart';

class DiscountCard extends StatelessWidget {
  final String title;
  final String code;
  final String description;
  final String expiration;
  final bool isActive;

  const DiscountCard({
    super.key,
    required this.title,
    required this.code,
    required this.description,
    required this.expiration,
    this.isActive = true,
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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                      ),
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
