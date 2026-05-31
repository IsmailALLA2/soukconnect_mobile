import '../entities/my_store_entity.dart';
import '../repositories/grossiste_repository.dart';

class GetMyStoreUseCase {
  const GetMyStoreUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<MyStoreEntity?> call(String ownerId) =>
      _repository.getMyStore(ownerId);
}
