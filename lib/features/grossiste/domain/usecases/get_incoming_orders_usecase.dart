import '../entities/incoming_order_entity.dart';
import '../repositories/grossiste_repository.dart';

class GetIncomingOrdersUseCase {
  const GetIncomingOrdersUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<List<IncomingOrderEntity>> call(String storeId) =>
      _repository.getIncomingOrders(storeId);
}
