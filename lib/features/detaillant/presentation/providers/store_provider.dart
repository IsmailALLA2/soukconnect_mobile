import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/store_repository_impl.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../../domain/usecases/get_nearby_stores_usecase.dart';
import '../../domain/usecases/get_store_by_id_usecase.dart';
import '../../domain/usecases/get_stores_by_category_usecase.dart';
import 'location_provider.dart';

part 'store_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository provider
// ─────────────────────────────────────────────────────────────────────────────

/// Provides the concrete [StoreRepository] implementation.
/// Swap [StoreRepositoryImpl] for a fake/mock here during testing.
@Riverpod(keepAlive: true)
StoreRepository storeRepository(StoreRepositoryRef ref) =>
    StoreRepositoryImpl();

// ─────────────────────────────────────────────────────────────────────────────
// NearbyStoresNotifier — fetches stores around the détaillant's position
// ─────────────────────────────────────────────────────────────────────────────

/// Default search radius in kilometres.
const double _defaultRadiusKm = 10.0;

@riverpod
class NearbyStoresNotifier extends _$NearbyStoresNotifier {
  @override
  Future<List<StoreEntity>> build() async {
    final repo     = ref.watch(storeRepositoryProvider);
    final useCase  = GetNearbyStoresUseCase(repo);
    final location = await ref.watch(locationNotifierProvider.future);

    // No location available (permission denied / services off) → empty list.
    // The UI reads locationNotifierProvider.error to show the reason.
    if (location == null) return [];

    return useCase(
      lat:      location.latitude,
      lng:      location.longitude,
      radiusKm: _defaultRadiusKm,
    );
  }

  // ── Public actions ────────────────────────────────────────────────────────

  /// Forces a fresh fetch — e.g. pull-to-refresh on NearbyStoresPage.
  Future<void> refresh() async {
    // Refresh location first, then stores.
    await ref.read(locationNotifierProvider.notifier).refresh();
    ref.invalidateSelf();
    await future; // await the rebuild
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// selectedCategoryProvider — currently active category filter
// null = show all categories
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  StoreCategory? build() => null; // no filter by default

  /// Sets the active category filter. Pass `null` to show all categories.
  void select(StoreCategory? category) => state = category;
}

// ─────────────────────────────────────────────────────────────────────────────
// filteredStoresProvider — derived; filters nearbyStores client-side
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
AsyncValue<List<StoreEntity>> filteredStores(FilteredStoresRef ref) {
  final nearbyAsync  = ref.watch(nearbyStoresNotifierProvider);
  final category     = ref.watch(selectedCategoryProvider);

  return nearbyAsync.whenData((stores) {
    if (category == null) return stores;
    return stores.where((s) => s.category == category).toList();
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// storesByCategoryProvider — separate server-side fetch for category browsing
// (used when the user browses by category without a location)
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<List<StoreEntity>> storesByCategory(
  StoresByCategoryRef ref,
  StoreCategory category,
) {
  final repo    = ref.watch(storeRepositoryProvider);
  final useCase = GetStoresByCategoryUseCase(repo);
  return useCase(category);
}

// ─────────────────────────────────────────────────────────────────────────────
// storeDetailProvider — fetches a single store by ID
// Auto-disposed when the StoreDetailPage leaves the widget tree.
// ─────────────────────────────────────────────────────────────────────────────

@riverpod
Future<StoreEntity> storeDetail(StoreDetailRef ref, String storeId) {
  final repo    = ref.watch(storeRepositoryProvider);
  final useCase = GetStoreByIdUseCase(repo);
  return useCase(storeId);
}
