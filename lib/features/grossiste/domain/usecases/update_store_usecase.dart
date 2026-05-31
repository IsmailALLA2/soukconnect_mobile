import '../../data/models/store_params.dart';
import '../entities/my_store_entity.dart';
import '../repositories/grossiste_repository.dart';

class UpdateStoreUseCase {
  const UpdateStoreUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<MyStoreEntity> call(StoreUpdateParams params) =>
      _repository.updateStore(params);
}
