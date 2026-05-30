import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

class GetStoreByIdUseCase {
  const GetStoreByIdUseCase(this._repository);

  final StoreRepository _repository;

  Future<StoreEntity> call(String storeId) =>
      _repository.getStoreById(storeId);
}
