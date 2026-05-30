import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/order_entity.dart';
import 'order_detail_sheet.dart';
import 'order_status_chip.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 0,
      color: theme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showDetailSheet(context),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.store_rounded, size: 18.sp, color: theme.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      order.storeName ?? 'Boutique',
                      style: AppTextStyles.titleSmall(
                        color: theme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  OrderStatusChip(status: order.statusEnum),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: _formatDate(order.createdAt),
                  ),
                  SizedBox(width: 16.w),
                  _InfoChip(
                    icon: Icons.inventory_2_rounded,
                    label: '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${order.total.toStringAsFixed(2)} MAD',
                style: AppTextStyles.titleMedium(
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => OrderDetailSheet(order: order),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppColors.grey500),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTextStyles.bodySmall(color: AppColors.grey600),
        ),
      ],
    );
  }
}
