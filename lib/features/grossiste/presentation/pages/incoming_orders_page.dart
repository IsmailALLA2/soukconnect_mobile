import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/app_refresh_indicator.dart';
import '../../../../core/widgets/green_spinner.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../providers/incoming_orders_provider.dart';
import '../providers/store_management_provider.dart';
import '../widgets/incoming_order_empty_state.dart';
import '../widgets/incoming_order_list_item.dart';
import '../widgets/incoming_order_shimmer.dart';

class IncomingOrdersPage extends HookConsumerWidget {
  const IncomingOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);
    final store = storeAsync.valueOrNull;
    final theme = context.colorScheme;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Commandes'),
          bottom: store != null
              ? TabBar(
                  tabs: [
                    _buildTab('Toutes', null),
                    _buildTab('En attente', OrderStatus.pending),
                    _buildTab('Confirmées', OrderStatus.confirmed),
                    _buildTab('Livrées', OrderStatus.delivered),
                  ],
                  isScrollable: false,
                  labelColor: theme.primary,
                  unselectedLabelColor: AppColors.grey500,
                  indicatorColor: theme.primary,
                  indicatorWeight: 3,
                )
              : null,
        ),
        body: store == null
            ? const Center(child: GreenSpinner())
            : ref.watch(incomingOrdersNotifierProvider(store.id)).when(
                  loading: () => const IncomingOrderShimmer(),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (orders) => _IncomingOrdersBody(
                    storeId: store.id,
                    orders: orders,
                  ),
                ),
      ),
    );
  }

  Widget _buildTab(String label, OrderStatus? filter) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          SizedBox(width: 4.w),
          if (filter != null)
            _TabCountBadge(status: filter),
        ],
      ),
    );
  }
}

class _TabCountBadge extends ConsumerWidget {
  const _TabCountBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);
    final storeId = storeAsync.valueOrNull?.id;
    if (storeId == null) return const SizedBox.shrink();

    final ordersAsync = ref.watch(incomingOrdersNotifierProvider(storeId));
    final count = ordersAsync.valueOrNull
            ?.where((o) => o.statusEnum == status)
            .length ??
        0;

    if (count == 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: count),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, _) {
        return Container(
          margin: EdgeInsets.only(left: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: _statusColor(status),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '$value',
            style: AppTextStyles.labelSmall(color: AppColors.white),
          ),
        );
      },
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
}

class _IncomingOrdersBody extends ConsumerWidget {
  const _IncomingOrdersBody({
    required this.storeId,
    required this.orders,
  });

  final String storeId;
  final List<dynamic> orders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = orders.where((o) => o.statusEnum == OrderStatus.pending).length;
    final confirmed = orders.where((o) => o.statusEnum == OrderStatus.confirmed).length;
    final delivered = orders.where((o) => o.statusEnum == OrderStatus.delivered).length;

    return Column(
      children: [
        _SummaryStrip(
          total: orders.length,
          pending: pending,
          confirmed: confirmed,
          delivered: delivered,
        ),
        Expanded(
          child: TabBarView(
            children: [
              _OrderList(orders: orders, filter: _filterNone),
              _OrderList(orders: orders, filter: _filterPending),
              _OrderList(orders: orders, filter: _filterConfirmed),
              _OrderList(orders: orders, filter: _filterDelivered),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _filterNone(List<dynamic> items) => items;
  List<dynamic> _filterPending(List<dynamic> items) =>
      items.where((o) => o.statusEnum == OrderStatus.pending).toList();
  List<dynamic> _filterConfirmed(List<dynamic> items) =>
      items.where((o) => o.statusEnum == OrderStatus.confirmed).toList();
  List<dynamic> _filterDelivered(List<dynamic> items) =>
      items.where((o) => o.statusEnum == OrderStatus.delivered).toList();
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.delivered,
  });

  final int total;
  final int pending;
  final int confirmed;
  final int delivered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          _StatPill(
            icon: Icons.receipt_long_rounded,
            label: 'Total',
            value: total,
            color: AppColors.primary,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.hourglass_empty_rounded,
            label: 'En attente',
            value: pending,
            color: AppColors.warning,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.check_circle_outline_rounded,
            label: 'Confirmées',
            value: confirmed,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          _StatPill(
            icon: Icons.local_shipping_rounded,
            label: 'Livrées',
            value: delivered,
            color: AppColors.info,
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16.sp, color: color),
            SizedBox(height: 4.h),
            AnimatedCounter(
              targetValue: value.toDouble(),
              style: AppTextStyles.titleSmall(color: color),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTextStyles.labelSmall(color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.filter,
  });

  final List<dynamic> orders;
  final List<dynamic> Function(List<dynamic>) filter;

  @override
  Widget build(BuildContext context) {
    final filtered = filter(orders);

    if (filtered.isEmpty) {
      return const IncomingOrderEmptyState();
    }

    return AppRefreshIndicator(
      onRefresh: () async {
        // refresh handled by the provider's realtime subscription
      },
      child: ListView.builder(
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        itemCount: filtered.length,
        itemBuilder: (_, i) => TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 60),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: IncomingOrderListItem(
            order: filtered[i] as dynamic,
          ),
        ),
      ),
    );
  }
}
