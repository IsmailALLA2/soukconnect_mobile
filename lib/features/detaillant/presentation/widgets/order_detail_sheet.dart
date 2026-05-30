import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import 'order_status_chip.dart';

class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, bottom + 20.h),
          child: ListView(
            controller: scrollController,
            children: [
              _handle(),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.storeName ?? 'Commande',
                      style: AppTextStyles.titleLarge(
                        color: theme.onSurface,
                      ),
                    ),
                  ),
                  OrderStatusChip(status: order.statusEnum),
                ],
              ),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Produits'),
              SizedBox(height: 8.h),
              ...order.items.map((item) => _ProductRow(item: item)),
              Divider(height: 24.h),
              _TotalRow(total: order.total),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _SectionTitle(title: 'Notes'),
                SizedBox(height: 4.h),
                Text(
                  order.notes!,
                  style: AppTextStyles.bodyMedium(color: AppColors.grey600),
                ),
              ],
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Suivi'),
              SizedBox(height: 8.h),
              _StatusTimeline(status: order.statusEnum),
            ],
          ),
        );
      },
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.grey300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.titleSmall(
        color: context.colorScheme.onSurface,
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});
  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: AppTextStyles.bodyMedium(color: context.colorScheme.onSurface),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'x${item.quantity}',
            style: AppTextStyles.bodyMedium(color: AppColors.grey500),
          ),
          SizedBox(width: 16.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '${item.subtotal.toStringAsFixed(2)} MAD',
              style: AppTextStyles.titleSmall(
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.total});
  final double total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: AppTextStyles.titleSmall(
            color: context.colorScheme.onSurface,
          ),
        ),
        Text(
          '${total.toStringAsFixed(2)} MAD',
          style: AppTextStyles.titleMedium(
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = context.colorScheme;
    final steps = [
      _TimelineStep(
        label: 'Commande passée',
        isActive: true,
      ),
      _TimelineStep(
        label: 'Confirmée',
        isActive: status.index >= OrderStatus.confirmed.index,
      ),
      _TimelineStep(
        label: 'Livrée',
        isActive: status == OrderStatus.delivered,
      ),
    ];

    if (status == OrderStatus.cancelled) {
      steps[1] = _TimelineStep(
        label: 'Annulée',
        isActive: true,
        isCancelled: true,
      );
      steps.removeLast();
    }

    return Column(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          return Container(
            width: 2.w,
            height: 24.h,
            color: steps[stepIndex].isActive
                ? (steps[stepIndex].isCancelled
                    ? AppColors.error
                    : theme.primary)
                : AppColors.grey300,
          );
        }
        final step = steps[i ~/ 2];
        return Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: step.isActive
                    ? (step.isCancelled
                        ? AppColors.error
                        : theme.primary)
                    : AppColors.grey300,
              ),
              child: Icon(
                step.isCancelled
                    ? Icons.close_rounded
                    : Icons.check_rounded,
                size: 14.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              step.label,
              style: step.isActive
                  ? AppTextStyles.titleSmall(color: theme.onSurface)
                  : AppTextStyles.bodyMedium(color: AppColors.grey400),
            ),
          ],
        );
      }),
    );
  }
}

class _TimelineStep {
  const _TimelineStep({
    required this.label,
    required this.isActive,
    this.isCancelled = false,
  });

  final String label;
  final bool isActive;
  final bool isCancelled;
}
