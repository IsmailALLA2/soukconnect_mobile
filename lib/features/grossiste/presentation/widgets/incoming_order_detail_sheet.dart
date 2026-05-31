import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../../../detaillant/presentation/widgets/order_status_chip.dart';
import '../../domain/entities/incoming_order_entity.dart';
import '../providers/incoming_orders_provider.dart';

class IncomingOrderDetailSheet extends ConsumerWidget {
  const IncomingOrderDetailSheet({super.key, required this.order});

  final IncomingOrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        final hasActions = order.statusEnum == OrderStatus.pending ||
            order.statusEnum == OrderStatus.confirmed;

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
                      'Détails de la commande',
                      style: AppTextStyles.titleLarge(color: theme.onSurface),
                    ),
                  ),
                  OrderStatusChip(status: order.statusEnum),
                ],
              ),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Client'),
              SizedBox(height: 8.h),
              _ClientInfo(
                name: order.detaillantName,
                phone: order.detaillantPhone,
              ),
              SizedBox(height: 16.h),
              Text(
                'Passée le ${_formatDateTime(order.createdAt)}',
                style: AppTextStyles.bodySmall(color: AppColors.grey500),
              ),
              SizedBox(height: 16.h),
              _SectionTitle(title: 'Produits'),
              SizedBox(height: 8.h),
              ...order.items.map((item) => _ProductRow(item: item)),
              const Divider(height: 24),
              _TotalRow(total: order.total),
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _SectionTitle(title: 'Notes'),
                SizedBox(height: 4.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    order.notes!,
                    style: AppTextStyles.bodyMedium(color: AppColors.grey700),
                  ),
                ),
              ],
              if (hasActions) ...[
                SizedBox(height: 24.h),
                _ActionButtons(order: order),
              ],
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} à ${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
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
                style: AppTextStyles.bodyMedium(color: AppColors.grey600),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.phone_in_talk_rounded,
              size: 20.sp, color: AppColors.primary),
          onPressed: () {
            // Placeholder — will use url_launcher later
          },
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
          SizedBox(width: 16.w),
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
      return const Center(child: CircularProgressIndicator());
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
      // handled by the notifier's error state
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
