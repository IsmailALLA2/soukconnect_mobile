import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/utils/failure.dart';
import '../../../detaillant/data/models/product_model.dart';
import '../../../detaillant/domain/entities/order_entity.dart';
import '../../../detaillant/domain/entities/product_entity.dart';
import '../../domain/entities/incoming_order_entity.dart';
import '../../domain/entities/my_store_entity.dart';
import '../../domain/repositories/grossiste_repository.dart';
import '../models/incoming_order_model.dart';
import '../models/my_store_model.dart';
import '../models/product_params.dart';
import '../models/store_params.dart';

class GrossisteRepositoryImpl implements GrossisteRepository {
  @override
  Future<MyStoreEntity?> getMyStore(String ownerId) async {
    try {
      final rows = await supabase
          .from('stores')
          .select()
          .eq('owner_id', ownerId)
          .limit(1);

      final list = rows as List<dynamic>;
      if (list.isEmpty) return null;

      final store = list.first as Map<String, dynamic>;
      final storeId = store['id'] as String;

      final productRows = await supabase
          .from('products')
          .select('id')
          .eq('store_id', storeId);
      final totalProducts = (productRows as List<dynamic>).length;

      final orderRows = await supabase
          .from('orders')
          .select('id, status, total')
          .eq('store_id', storeId);
      final orders = orderRows as List<dynamic>;
      final totalOrders = orders.length;
      final pendingOrders = orders
          .where((o) => (o as Map<String, dynamic>)['status'] == 'pending')
          .length;
      final totalRevenue = orders
          .where((o) => (o as Map<String, dynamic>)['status'] != 'cancelled')
          .fold<double>(
            0,
            (sum, o) =>
                sum + ((o as Map<String, dynamic>)['total'] as num).toDouble(),
          );

      return MyStoreModel.fromJson({
        ...store,
        'total_products': totalProducts,
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'total_revenue': totalRevenue,
      });
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<MyStoreEntity> createStore(StoreCreateParams params) async {
    try {
      final row = await supabase.from('stores').insert({
        'owner_id': supabase.auth.currentUser!.id,
        'name': params.name,
        'description': params.description,
        'category': params.category.value,
        'phone': params.phone,
        'wilaya': params.wilaya,
        'address': params.address,
        if (params.lat != null) 'lat': params.lat,
        if (params.lng != null) 'lng': params.lng,
        'is_active': true,
      }).select().single();

      return MyStoreModel.fromJson({
        ...row,
        'total_products': 0,
        'total_orders': 0,
        'pending_orders': 0,
        'total_revenue': 0,
      });
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<MyStoreEntity> updateStore(StoreUpdateParams params) async {
    try {
      final row = await supabase.from('stores').update({
        'name': params.name,
        'description': params.description,
        'category': params.category.value,
        'phone': params.phone,
        'wilaya': params.wilaya,
        'address': params.address,
        if (params.lat != null) 'lat': params.lat else 'lat': null,
        if (params.lng != null) 'lng': params.lng else 'lng': null,
      }).eq('id', params.id).select().single();

      return MyStoreModel.fromJson({
        ...row,
        'total_products': 0,
        'total_orders': 0,
        'pending_orders': 0,
        'total_revenue': 0,
      });
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<ProductEntity>> getMyProducts(String storeId) async {
    try {
      final rows = await supabase
          .from('products')
          .select()
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductEntity> createProduct(ProductCreateParams params) async {
    try {
      final row = await supabase.from('products').insert({
        'store_id': params.storeId,
        'name': params.name,
        'description': params.description,
        'price': params.price,
        'unit': params.unit,
        'stock': params.stock,
        if (params.imageUrl != null) 'image_url': params.imageUrl,
        'is_available': true,
      }).select().single();

      return ProductModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<ProductEntity> updateProduct(ProductUpdateParams params) async {
    try {
      final row = await supabase.from('products').update({
        'name': params.name,
        'description': params.description,
        'price': params.price,
        'unit': params.unit,
        'stock': params.stock,
        if (params.imageUrl != null) 'image_url': params.imageUrl,
        if (params.isAvailable != null) 'is_available': params.isAvailable,
      }).eq('id', params.id).select().single();

      return ProductModel.fromJson(row);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await supabase.from('products').delete().eq('id', productId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<List<IncomingOrderEntity>> getIncomingOrders(String storeId) async {
    try {
      final rows = await supabase
          .from('orders')
          .select('*, profiles!orders_detaillant_id_fkey(full_name, phone), order_items(*)')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) =>
              IncomingOrderModel.fromJoinedJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await supabase
          .from('orders')
          .update({'status': status.name})
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
