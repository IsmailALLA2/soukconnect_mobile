import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<OrderEntity> placeOrder({
    required String detaillantId,
    required String storeId,
    required List<CartItem> items,
    required double total,
    String? notes,
  }) async {
    try {
      final orderRow = await supabase.from('orders').insert({
        'detaillant_id': detaillantId,
        'store_id': storeId,
        'total': total,
        if (notes case final n?) 'notes': n,
        'status': 'pending',
      }).select().single();

      final order = OrderModel.fromJson(orderRow);

      await supabase.from('order_items').insert(
        items.map((item) => orderItemToJson(orderId: order.id, item: item)).toList(),
      );

      return order.copyWith(
        items: items
            .map((ci) => OrderItemEntity(
                  productId: ci.product.id,
                  name: ci.product.name,
                  price: ci.product.price,
                  quantity: ci.quantity,
                ))
            .toList(),
      );
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<OrderEntity>> getMyOrders(String detaillantId) async {
    try {
      final rows = await supabase
          .from('orders')
          .select('*, stores(name), order_items(*)')
          .eq('detaillant_id', detaillantId)
          .order('created_at', ascending: false);

      final parsed = rows as List<dynamic>;
      return parsed
          .map((row) => OrderModel.fromJoinedJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
