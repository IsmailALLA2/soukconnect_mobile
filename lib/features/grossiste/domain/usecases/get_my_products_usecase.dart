import '../../../detaillant/domain/entities/product_entity.dart';
import '../repositories/grossiste_repository.dart';

class GetMyProductsUseCase {
  const GetMyProductsUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<List<ProductEntity>> call(String storeId) =>
      _repository.getMyProducts(storeId);
}
