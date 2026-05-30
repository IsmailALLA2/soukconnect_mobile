import '../entities/product_entity.dart';
import '../entities/store_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreRepository — domain contract
//
// Implementations live in the data layer. This interface never imports
// Supabase, http, or any external package.
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class StoreRepository {
  /// Returns all active stores within [radiusKm] kilometres of the given
  /// coordinates, sorted by ascending distance.
  ///
  /// [lat] and [lng] are the détaillant's current GPS position.
  /// Each returned [StoreEntity] has [StoreEntity.distanceInKm] populated.
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<StoreEntity>> getNearbyStores({
    required double lat,
    required double lng,
    required double radiusKm,
  });

  /// Returns all active stores that match [category], unsorted.
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<StoreEntity>> getStoresByCategory(StoreCategory category);

  /// Returns all available products belonging to [storeId].
  ///
  /// Throws a [Failure] subclass on error.
  Future<List<ProductEntity>> getStoreProducts(String storeId);

  /// Returns a single store by its [storeId].
  ///
  /// Throws [NotFoundFailure] if the store does not exist.
  /// Throws a [Failure] subclass on other errors.
  Future<StoreEntity> getStoreById(String storeId);
}
