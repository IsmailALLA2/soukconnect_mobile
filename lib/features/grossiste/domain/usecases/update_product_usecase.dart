import '../../../detaillant/domain/entities/product_entity.dart';
import '../../data/models/product_params.dart';
import '../repositories/grossiste_repository.dart';

class UpdateProductUseCase {
  const UpdateProductUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<ProductEntity> call(ProductUpdateParams params) =>
      _repository.updateProduct(params);
}
