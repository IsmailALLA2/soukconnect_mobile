import '../../data/models/store_params.dart';
import '../entities/my_store_entity.dart';
import '../repositories/grossiste_repository.dart';

class CreateStoreUseCase {
  const CreateStoreUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<MyStoreEntity> call(StoreCreateParams params) =>
      _repository.createStore(params);
}
