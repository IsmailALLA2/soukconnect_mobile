import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/supabase/supabase_config.dart';
import '../../../../core/utils/failure.dart';
import '../../../../core/utils/location_utils.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/store_entity.dart';
import '../../domain/repositories/store_repository.dart';
import '../models/product_model.dart';
import '../models/store_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreRepositoryImpl — Supabase implementation of [StoreRepository]
// ─────────────────────────────────────────────────────────────────────────────

class StoreRepositoryImpl implements StoreRepository {
  // ── Get nearby stores ─────────────────────────────────────────────────────

  /// Fetches all active stores from Supabase, calculates each store's
  /// distance from ([lat], [lng]) using the Haversine formula, filters
  /// to those within [radiusKm], and returns them sorted by distance.
  ///
  /// Stores without a GPS location are excluded from the results.
  @override
  Future<List<StoreEntity>> getNearbyStores({
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final rows = await supabase
          .from('stores')
          .select()
          .eq('is_active', true)
          // Exclude stores that have not set a location
          .not('lat', 'is', null)
          .not('lng', 'is', null);

      final stores = (rows as List<dynamic>)
          .map((row) => StoreModel.fromJson(row as Map<String, dynamic>))
          .toList();

      // Calculate distances and filter by radius
      final nearby = <StoreModel>[];
      for (final store in stores) {
        final distance = LocationUtils.calculateDistance(
          lat,
          lng,
          store.lat!,
          store.lng!,
        );
        if (distance <= radiusKm) {
          nearby.add(store.copyWith(distanceInKm: distance));
        }
      }

      // Sort: closest first
      nearby.sort(
        (a, b) => (a.distanceInKm ?? double.infinity)
            .compareTo(b.distanceInKm ?? double.infinity),
      );

      return nearby;
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Get stores by category ────────────────────────────────────────────────

  @override
  Future<List<StoreEntity>> getStoresByCategory(
    StoreCategory category,
  ) async {
    try {
      final rows = await supabase
          .from('stores')
          .select()
          .eq('is_active', true)
          .eq('category', category.value)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => StoreModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Get store products ────────────────────────────────────────────────────

  @override
  Future<List<ProductEntity>> getStoreProducts(String storeId) async {
    try {
      final rows = await supabase
          .from('products')
          .select()
          .eq('store_id', storeId)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (rows as List<dynamic>)
          .map((row) => ProductModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }

  // ── Get store by id ───────────────────────────────────────────────────────

  @override
  Future<StoreEntity> getStoreById(String storeId) async {
    try {
      final row = await supabase
          .from('stores')
          .select()
          .eq('id', storeId)
          .single();

      return StoreModel.fromJson(row);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const NotFoundFailure('Boutique introuvable.');
      }
      throw ServerFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e.toString());
    }
  }
}
