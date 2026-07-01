import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class PriceRow extends StatelessWidget {
  final String serviceName;
  final String category;
  final String price;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PriceRow({
    Key? key,
    required this.serviceName,
    required this.category,
    required this.price,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              price,
              style: const TextStyle(
                fontFamily: 'Roboto Mono',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) {
                onEdit!();
              } else if (value == 'delete' && onDelete != null) {
                onDelete!();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Sửa'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Xóa', style: TextStyle(color: AppColors.statusError)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
