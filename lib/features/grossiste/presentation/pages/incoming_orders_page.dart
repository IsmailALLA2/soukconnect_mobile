import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/sizer.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../providers/incoming_orders_provider.dart';
import '../providers/store_management_provider.dart';
import '../widgets/incoming_order_empty_state.dart';
import '../widgets/incoming_order_list_item.dart';
import '../widgets/incoming_order_shimmer.dart';

class IncomingOrdersPage extends HookConsumerWidget {
  const IncomingOrdersPage({super.key});

  static const _tabs = ['Toutes', 'En attente', 'Confirmées', 'Livrées'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(myStoreNotifierProvider);
    final store = storeAsync.valueOrNull;

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Commandes'),
          bottom: store != null
              ? TabBar(
                  tabs: [
                    const Tab(text: 'Toutes'),
                    _pendingTab(ref, store.id),
                    const Tab(text: 'Confirmées'),
                    const Tab(text: 'Livrées'),
                  ],
                  isScrollable: false,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey600,
                  indicatorColor: AppColors.primary,
                )
              : null,
        ),
        body: store == null
            ? const Center(child: CircularProgressIndicator())
            : ref.watch(incomingOrdersNotifierProvider(store.id)).when(
                  loading: () => const IncomingOrderShimmer(),
                  error: (e, _) => Center(child: Text('$e')),
                  data: (orders) => _TabbedOrderList(orders: orders),
                ),
      ),
    );
  }

  Widget _pendingTab(WidgetRef ref, String storeId) {
    final ordersAsync = ref.watch(incomingOrdersNotifierProvider(storeId));
    final pendingCount = ordersAsync.valueOrNull
            ?.where((o) => o.statusEnum == OrderStatus.pending)
            .length ??
        0;

    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('En attente'),
          if (pendingCount > 0) ...[
            SizedBox(width: 6.w),
            Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TabbedOrderList extends StatelessWidget {
  const _TabbedOrderList({required this.orders});

  final List<dynamic> orders;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        _buildList(orders, _filterNone),
        _buildList(orders, _filterPending),
        _buildList(orders, _filterConfirmed),
        _buildList(orders, _filterDelivered),
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

  Widget _buildList(List<dynamic> source, List<dynamic> Function(List<dynamic>) filter) {
    final filtered = filter(source);

    if (filtered.isEmpty) {
      return IncomingOrderEmptyState(message: _emptyMessage);
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h),
      itemCount: filtered.length,
      itemBuilder: (_, i) => IncomingOrderListItem(
        order: filtered[i] as dynamic,
      ),
    );
  }

  String get _emptyMessage => 'Aucune commande.';
}
