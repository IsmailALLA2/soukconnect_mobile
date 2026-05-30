import '../entities/cart_item.dart';
import '../entities/order_entity.dart';

abstract interface class OrderRepository {
  Future<OrderEntity> placeOrder({
    required String detaillantId,
    required String storeId,
    required List<CartItem> items,
    required double total,
    String? notes,
  });

  Future<List<OrderEntity>> getMyOrders(String detaillantId);
}
