import '../entities/product_entity.dart';
import '../repositories/store_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GetStoreProductsUseCase
// ─────────────────────────────────────────────────────────────────────────────

class GetStoreProductsUseCase {
  const GetStoreProductsUseCase(this._repository);

  final StoreRepository _repository;

  /// Returns all available products for [storeId].
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<ProductEntity>> call(String storeId) =>
      _repository.getStoreProducts(storeId);
}
