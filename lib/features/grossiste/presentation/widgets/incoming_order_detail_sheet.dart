import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../../domain/entities/incoming_order_entity.dart';
import '../providers/incoming_orders_provider.dart';

class IncomingOrderDetailSheet extends ConsumerWidget {
  const IncomingOrderDetailSheet({super.key, required this.order});

  final IncomingOrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        final hasActions = order.statusEnum == OrderStatus.pending ||
            order.statusEnum == OrderStatus.confirmed;

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
                    icon: Icons.person_rounded,
                    title: 'Client',
                    child: _ClientInfo(
                      name: order.detaillantName,
                      phone: order.detaillantPhone,
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                        style: AppTextStyles.bodyMedium(color: AppColors.grey700),
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  _SectionCard(
                    icon: Icons.timeline_rounded,
                    title: 'Suivi',
                    child: _StatusTimeline(status: order.statusEnum),
                  ),
                  if (hasActions) ...[
                    SizedBox(height: 16.h),
                    _ActionButtons(order: order),
                  ],
                  SizedBox(height: 16.h),
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

  final IncomingOrderEntity order;

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
                  'Détails de la commande',
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
                          size: 12.sp, color: Colors.white.withValues(alpha: 0.8)),
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

class _ClientInfo extends StatelessWidget {
  const _ClientInfo({required this.name, required this.phone});

  final String name;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.w,
          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          child: Icon(Icons.person_rounded,
              size: 20.sp, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.titleSmall(
                  color: context.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                phone,
                style: AppTextStyles.bodyMedium(
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.phone_in_talk_rounded,
              size: 20.sp, color: AppColors.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final name = item.name as String;
    final quantity = item.quantity as int;
    final price = item.price as double;
    final subtotal = item.subtotal as double;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium(
                color: context.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$quantity × ${price.toStringAsFixed(0)}',
            style: AppTextStyles.bodySmall(color: AppColors.grey500),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 70.w,
            child: Text(
              '${subtotal.toStringAsFixed(0)} MAD',
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

class _ActionButtons extends ConsumerStatefulWidget {
  const _ActionButtons({required this.order});

  final IncomingOrderEntity order;

  @override
  ConsumerState<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends ConsumerState<_ActionButtons> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: GreenSpinner());
    }

    final status = widget.order.statusEnum;

    if (status == OrderStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _updateStatus(OrderStatus.confirmed),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Confirmer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _updateStatus(OrderStatus.cancelled),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Annuler'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      );
    }

    if (status == OrderStatus.confirmed) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _updateStatus(OrderStatus.delivered),
          icon: const Icon(Icons.local_shipping_rounded),
          label: const Text('Marquer comme livré'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.info,
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _updateStatus(OrderStatus newStatus) async {
    final notifier = ref.read(
      incomingOrdersNotifierProvider(widget.order.storeId).notifier,
    );
    setState(() => _loading = true);
    try {
      await notifier.updateStatus(widget.order.id, newStatus);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
