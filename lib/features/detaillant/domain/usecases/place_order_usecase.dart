import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../entities/cart_item.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import '../../data/repositories/order_repository_impl.dart';

part 'place_order_usecase.g.dart';

class PlaceOrderParams {
  const PlaceOrderParams({
    required this.detaillantId,
    required this.storeId,
    required this.items,
    required this.total,
    this.notes,
  });

  final String detaillantId;
  final String storeId;
  final List<CartItem> items;
  final double total;
  final String? notes;
}

class PlaceOrderUseCase {
  const PlaceOrderUseCase(this._repository);
  final OrderRepository _repository;

  Future<OrderEntity> call(PlaceOrderParams params) {
    return _repository.placeOrder(
      detaillantId: params.detaillantId,
      storeId: params.storeId,
      items: params.items,
      total: params.total,
      notes: params.notes,
    );
  }
}

@riverpod
PlaceOrderUseCase placeOrderUseCase(PlaceOrderUseCaseRef ref) {
  return PlaceOrderUseCase(OrderRepositoryImpl());
}
