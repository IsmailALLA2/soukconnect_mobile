import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreCategory enum
// ─────────────────────────────────────────────────────────────────────────────

enum StoreCategory {
  alimentation,
  cosmetique,
  hygiene,
  electromenager,
  autre;

  /// Converts a raw string from Supabase to [StoreCategory].
  /// Falls back to [StoreCategory.autre] for unknown values.
  static StoreCategory fromString(String? value) =>
      switch (value?.toLowerCase()) {
        'alimentation'  => StoreCategory.alimentation,
        'cosmetique'    => StoreCategory.cosmetique,
        'hygiene'       => StoreCategory.hygiene,
        'electromenager' => StoreCategory.electromenager,
        _               => StoreCategory.autre,
      };

  /// Returns the snake_case string stored in Supabase.
  String get value => name;

  /// Human-readable French label.
  String get label => switch (this) {
        StoreCategory.alimentation  => 'Alimentation',
        StoreCategory.cosmetique    => 'Cosmétique',
        StoreCategory.hygiene       => 'Hygiène',
        StoreCategory.electromenager => 'Électroménager',
        StoreCategory.autre         => 'Autre',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// StoreEntity — pure domain object, no framework dependencies
// ─────────────────────────────────────────────────────────────────────────────

class StoreEntity extends Equatable {
  const StoreEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.category,
    required this.phone,
    required this.wilaya,
    required this.address,
    this.lat,
    this.lng,
    required this.isActive,
    required this.createdAt,
    this.distanceInKm,
  });

  /// Supabase row UUID.
  final String id;

  /// UUID of the grossiste who owns this store.
  final String ownerId;

  /// Public display name of the store.
  final String name;

  /// Short description / about text.
  final String description;

  /// Business category of the store.
  final StoreCategory category;

  /// Contact phone number.
  final String phone;

  /// Province / Wilaya (e.g. "Casablanca-Settat").
  final String wilaya;

  /// Street / locality address.
  final String address;

  /// GPS latitude (nullable until the owner sets a location).
  final double? lat;

  /// GPS longitude (nullable until the owner sets a location).
  final double? lng;

  /// Whether this store is currently visible to détaillants.
  final bool isActive;

  /// Record creation timestamp (UTC).
  final DateTime createdAt;

  /// Distance from the current détaillant — calculated at runtime,
  /// never stored in Supabase.
  final double? distanceInKm;

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Returns `true` when the owner has set a GPS location.
  bool get hasLocation => lat != null && lng != null;

  // ── Equatable ─────────────────────────────────────────────────────────────

  /// [distanceInKm] is intentionally excluded — it is a runtime value
  /// and must not affect equality or hash comparisons.
  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        category,
        phone,
        wilaya,
        address,
        lat,
        lng,
        isActive,
        createdAt,
      ];

  @override
  String toString() =>
      'StoreEntity(id: $id, name: $name, category: ${category.value})';
}
