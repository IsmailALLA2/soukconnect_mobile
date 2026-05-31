import '../../../detaillant/domain/entities/product_entity.dart';
import '../../data/models/product_params.dart';
import '../repositories/grossiste_repository.dart';

class CreateProductUseCase {
  const CreateProductUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<ProductEntity> call(ProductCreateParams params) =>
      _repository.createProduct(params);
}
