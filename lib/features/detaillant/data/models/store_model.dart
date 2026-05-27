import '../../domain/entities/store_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// StoreModel — data layer representation of a store
//
// Extends [StoreEntity] so it flows directly through the domain layer
// without extra mapping. Adds JSON serialization for Supabase responses.
//
// Expected Supabase `stores` table columns:
//   id           uuid (PK)
//   owner_id     uuid (FK → profiles.id)
//   name         text
//   description  text
//   category     text  ('alimentation' | 'cosmetique' | 'hygiene' |
//                        'electromenager' | 'autre')
//   phone        text
//   wilaya       text
//   address      text
//   lat          float8  (nullable)
//   lng          float8  (nullable)
//   is_active    bool
//   created_at   timestamptz
// ─────────────────────────────────────────────────────────────────────────────

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    required super.category,
    required super.phone,
    required super.wilaya,
    required super.address,
    super.lat,
    super.lng,
    required super.isActive,
    required super.createdAt,
    super.distanceInKm,
  });

  // ── Deserialization ───────────────────────────────────────────────────────

  /// Builds a [StoreModel] from a Supabase `stores` row map.
  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id:          json['id'] as String,
      ownerId:     json['owner_id'] as String,
      name:        json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category:    StoreCategory.fromString(json['category'] as String?),
      phone:       json['phone'] as String? ?? '',
      wilaya:      json['wilaya'] as String? ?? '',
      address:     json['address'] as String? ?? '',
      lat:         (json['lat'] as num?)?.toDouble(),
      lng:         (json['lng'] as num?)?.toDouble(),
      isActive:    json['is_active'] as bool? ?? true,
      createdAt:   json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Converts this model to a map suitable for Supabase upsert/update.
  /// [distanceInKm] is never serialized — it is a runtime-only value.
  Map<String, dynamic> toJson() => {
        'id':          id,
        'owner_id':    ownerId,
        'name':        name,
        'description': description,
        'category':    category.value,
        'phone':       phone,
        'wilaya':      wilaya,
        'address':     address,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'is_active':   isActive,
        'created_at':  createdAt.toUtc().toIso8601String(),
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  StoreModel copyWith({
    String?        id,
    String?        ownerId,
    String?        name,
    String?        description,
    StoreCategory? category,
    String?        phone,
    String?        wilaya,
    String?        address,
    double?        lat,
    double?        lng,
    bool?          isActive,
    DateTime?      createdAt,
    double?        distanceInKm,
    // Pass explicit null to clear nullable fields
    bool           clearLat          = false,
    bool           clearLng          = false,
    bool           clearDistanceInKm = false,
  }) {
    return StoreModel(
      id:            id            ?? this.id,
      ownerId:       ownerId       ?? this.ownerId,
      name:          name          ?? this.name,
      description:   description   ?? this.description,
      category:      category      ?? this.category,
      phone:         phone         ?? this.phone,
      wilaya:        wilaya        ?? this.wilaya,
      address:       address       ?? this.address,
      lat:           clearLat      ? null : (lat ?? this.lat),
      lng:           clearLng      ? null : (lng ?? this.lng),
      isActive:      isActive      ?? this.isActive,
      createdAt:     createdAt     ?? this.createdAt,
      distanceInKm:  clearDistanceInKm
          ? null
          : (distanceInKm ?? this.distanceInKm),
    );
  }

  // ── Convenience constructors ──────────────────────────────────────────────

  /// Creates an empty placeholder model (e.g. during loading).
  factory StoreModel.empty() => StoreModel(
        id:          '',
        ownerId:     '',
        name:        '',
        description: '',
        category:    StoreCategory.autre,
        phone:       '',
        wilaya:      '',
        address:     '',
        isActive:    false,
        createdAt:   DateTime.now(),
      );

  /// Promotes a [StoreEntity] to a [StoreModel].
  factory StoreModel.fromEntity(StoreEntity entity) => StoreModel(
        id:           entity.id,
        ownerId:      entity.ownerId,
        name:         entity.name,
        description:  entity.description,
        category:     entity.category,
        phone:        entity.phone,
        wilaya:       entity.wilaya,
        address:      entity.address,
        lat:          entity.lat,
        lng:          entity.lng,
        isActive:     entity.isActive,
        createdAt:    entity.createdAt,
        distanceInKm: entity.distanceInKm,
      );

  @override
  String toString() =>
      'StoreModel(id: $id, name: $name, category: ${category.value})';
}
