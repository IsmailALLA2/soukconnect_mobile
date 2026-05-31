import '../../../detaillant/domain/entities/order_entity.dart';
import '../repositories/grossiste_repository.dart';

class UpdateOrderStatusUseCase {
  const UpdateOrderStatusUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<void> call(String orderId, OrderStatus status) =>
      _repository.updateOrderStatus(orderId, status);
}
