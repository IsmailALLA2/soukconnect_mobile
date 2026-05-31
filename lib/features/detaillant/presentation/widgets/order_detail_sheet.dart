import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({super.key, required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            _GradientHeader(order: order),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, bottom + 20.h),
                children: [
                  SizedBox(height: 16.h),
                  _SectionCard(
                    icon: Icons.inventory_2_rounded,
                    title: 'Produits (${order.items.length})',
                    child: Column(
                      children: [
                        ...order.items.map((item) => _ProductRow(item: item)),
                        Divider(height: 20.h),
                        _TotalRow(total: order.total),
                      ],
                    ),
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _SectionCard(
                      icon: Icons.notes_rounded,
                      title: 'Notes',
                      child: Text(
                        order.notes!,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.grey700,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _SectionCard(
                    icon: Icons.timeline_rounded,
                    title: 'Suivi',
                    child: _StatusTimeline(status: order.statusEnum),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GradientHeader extends StatelessWidget {
  const _GradientHeader({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.statusEnum);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.storeName ?? 'Commande',
                  style: AppTextStyles.titleLarge(color: AppColors.white),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  order.statusEnum.label,
                  style: AppTextStyles.labelSmall(color: AppColors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${order.total.toStringAsFixed(0)} MAD',
                    style: AppTextStyles.headlineSmall(color: AppColors.white),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 12.sp,
                          color: Colors.white.withValues(alpha: 0.8)),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(order.createdAt),
                        style: AppTextStyles.bodySmall(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                    style: AppTextStyles.bodyMedium(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.success;
      case OrderStatus.delivered:
        return AppColors.info;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTextStyles.titleSmall(
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
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
              style: AppTextStyles.bodyMedium(
                color: context.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'x${item.quantity}',
            style: AppTextStyles.bodyMedium(color: AppColors.grey500),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '${item.subtotal.toStringAsFixed(0)} MAD',
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
          '${total.toStringAsFixed(0)} MAD',
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
