import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../../domain/entities/incoming_order_entity.dart';
import 'store_management_provider.dart';

part 'incoming_orders_provider.g.dart';

@Riverpod(keepAlive: true)
class IncomingOrdersNotifier extends _$IncomingOrdersNotifier {
  RealtimeChannel? _channel;

  @override
  Future<List<IncomingOrderEntity>> build(String storeId) async {
    final repo = ref.watch(grossisteRepositoryProvider);

    _setupRealtime(storeId);
    ref.onDispose(() => _channel?.unsubscribe());

    return repo.getIncomingOrders(storeId);
  }

  void _setupRealtime(String storeId) {
    _channel?.unsubscribe();
    _channel = supabase
        .channel('incoming-orders:$storeId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            column: 'store_id',
            type: PostgresChangeFilterType.eq,
            value: storeId,
          ),
          callback: (_) => ref.invalidateSelf(),
        )
        .subscribe();
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final repo = ref.read(grossisteRepositoryProvider);
    await repo.updateOrderStatus(orderId, status);
    ref.invalidateSelf();
  }

  int get pendingOrdersCount {
    final orders = state.valueOrNull;
    if (orders == null) return 0;
    return orders.where((o) => o.statusEnum == OrderStatus.pending).length;
  }
}
