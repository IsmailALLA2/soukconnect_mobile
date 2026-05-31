import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../../../detaillant/presentation/widgets/order_status_chip.dart';
import '../../domain/entities/incoming_order_entity.dart';
import '../providers/incoming_orders_provider.dart';
import 'incoming_order_detail_sheet.dart';

class IncomingOrderListItem extends ConsumerWidget {
  const IncomingOrderListItem({super.key, required this.order});

  final IncomingOrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.colorScheme;
    final statusColor = _statusColor(order.statusEnum);
    final isPending = order.statusEnum == OrderStatus.pending;

    return Dismissible(
      key: ValueKey(order.id),
      direction:
          isPending ? DismissDirection.horizontal : DismissDirection.none,
      background: _swipeBackground(AppColors.success, Icons.check_rounded, true),
      secondaryBackground:
          _swipeBackground(AppColors.error, Icons.close_rounded, false),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return _confirmAction(context, false);
        }
        return _confirmAction(context, true);
      },
      onDismissed: (direction) async {
        final notifier = ref.read(
          incomingOrdersNotifierProvider(order.storeId).notifier,
        );
        try {
          if (direction == DismissDirection.startToEnd) {
            await notifier.updateStatus(order.id, OrderStatus.confirmed);
          } else {
            await notifier.updateStatus(order.id, OrderStatus.cancelled);
          }
        } catch (_) {}
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDetail(context),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: statusColor,
                  width: 4.w,
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: _PulsingDot(
                          isActive: isPending,
                          child: Icon(
                            _statusIcon(order.statusEnum),
                            size: 20.sp,
                            color: statusColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.detaillantName,
                              style: AppTextStyles.titleSmall(
                                color: theme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              _formatTimeAgo(order.createdAt),
                              style: AppTextStyles.bodySmall(
                                color: AppColors.grey500,
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
                      Icon(Icons.inventory_2_rounded,
                          size: 14.sp, color: AppColors.grey500),
                      SizedBox(width: 4.w),
                      Text(
                        '${order.items.length} article${order.items.length > 1 ? 's' : ''}',
                        style: AppTextStyles.bodySmall(
                          color: AppColors.grey600,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(Icons.call_outlined,
                          size: 14.sp, color: AppColors.grey500),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          order.detaillantPhone,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14.sp, color: AppColors.grey500),
                          SizedBox(width: 4.w),
                          Text(
                            _formatDate(order.createdAt),
                            style: AppTextStyles.bodySmall(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${order.total.toStringAsFixed(0)} MAD',
                        style: AppTextStyles.titleMedium(color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  IconData _statusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_rounded;
      case OrderStatus.delivered:
        return Icons.local_shipping_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return _formatDate(dt);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
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

  Future<bool?> _confirmAction(BuildContext context, bool isConfirm) {
    return AppDialog.confirm(
      context,
      title: isConfirm ? 'Confirmer la commande' : 'Annuler la commande',
      message: isConfirm
          ? 'Cette action est irréversible.'
          : 'La commande sera définitivement annulée.',
      onConfirm: () {},
      type: isConfirm ? DialogType.info : DialogType.danger,
      confirmLabel: isConfirm ? 'Confirmer' : 'Annuler',
    );
  }

  Widget _swipeBackground(Color color, IconData icon, bool isLeft) {
    return Container(
      color: color,
      alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Icon(icon, color: Colors.white, size: 28.sp),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({
    required this.isActive,
    required this.child,
  });

  final bool isActive;
  final Widget child;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulsingDot old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.scale(
        scale: widget.isActive ? _animation.value : 1.0,
        child: child,
      ),
      child: widget.child,
    );
  }
}
