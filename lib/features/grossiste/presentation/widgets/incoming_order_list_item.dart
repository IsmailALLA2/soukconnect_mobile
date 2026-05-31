import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../detaillant/presentation/widgets/order_status_chip.dart';
import '../../domain/entities/incoming_order_entity.dart';
import 'incoming_order_detail_sheet.dart';

class IncomingOrderListItem extends StatelessWidget {
  const IncomingOrderListItem({super.key, required this.order});

  final IncomingOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.w,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    child: Icon(Icons.person_rounded,
                        size: 18.sp, color: AppColors.primary),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.detaillantName,
                          style: AppTextStyles.titleSmall(color: theme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        GestureDetector(
                          onTap: () => _call(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined,
                                  size: 12.sp, color: AppColors.primary),
                              SizedBox(width: 4.w),
                              Text(
                                order.detaillantPhone,
                                style: AppTextStyles.bodySmall(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OrderStatusChip(status: order.statusEnum),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 14.sp, color: AppColors.grey500),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDateTime(order.createdAt),
                    style: AppTextStyles.bodySmall(color: AppColors.grey600),
                  ),
                  const Spacer(),
                  Text(
                    '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall(color: AppColors.grey600),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                '${order.total.toStringAsFixed(0)} MAD',
                style: AppTextStyles.titleMedium(color: theme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => IncomingOrderDetailSheet(order: order),
    );
  }

  void _call(BuildContext context) {
    // Placeholder — will use url_launcher later
  }
}
