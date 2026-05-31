import '../repositories/grossiste_repository.dart';

class DeleteProductUseCase {
  const DeleteProductUseCase(this._repository);
  final GrossisteRepository _repository;

  Future<void> call(String productId) => _repository.deleteProduct(productId);
}
