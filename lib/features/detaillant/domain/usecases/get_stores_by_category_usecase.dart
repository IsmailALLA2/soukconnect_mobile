import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GetStoresByCategoryUseCase
// ─────────────────────────────────────────────────────────────────────────────

class GetStoresByCategoryUseCase {
  const GetStoresByCategoryUseCase(this._repository);

  final StoreRepository _repository;

  /// Returns all active stores that match [category].
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<StoreEntity>> call(StoreCategory category) =>
      _repository.getStoresByCategory(category);
}
