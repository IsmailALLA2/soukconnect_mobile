import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// GetNearbyStoresUseCase
// ─────────────────────────────────────────────────────────────────────────────

class GetNearbyStoresUseCase {
  const GetNearbyStoresUseCase(this._repository);

  final StoreRepository _repository;

  /// Returns active stores within [radiusKm] of ([lat], [lng]),
  /// sorted by ascending distance.
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<StoreEntity>> call({
    required double lat,
    required double lng,
    required double radiusKm,
  }) =>
      _repository.getNearbyStores(lat: lat, lng: lng, radiusKm: radiusKm);
}
