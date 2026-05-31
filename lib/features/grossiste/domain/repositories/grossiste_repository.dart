import '../../../detaillant/domain/entities/order_entity.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../../data/models/product_params.dart';
import '../../data/models/store_params.dart';
import '../entities/incoming_order_entity.dart';
import '../entities/my_store_entity.dart';

abstract interface class GrossisteRepository {
  Future<MyStoreEntity?> getMyStore(String ownerId);

  Future<MyStoreEntity> createStore(StoreCreateParams params);

  Future<MyStoreEntity> updateStore(StoreUpdateParams params);

  Future<List<ProductEntity>> getMyProducts(String storeId);

  Future<ProductEntity> createProduct(ProductCreateParams params);

  Future<ProductEntity> updateProduct(ProductUpdateParams params);

  Future<void> deleteProduct(String productId);

  Future<List<IncomingOrderEntity>> getIncomingOrders(String storeId);

  Future<void> updateOrderStatus(String orderId, OrderStatus status);
}
