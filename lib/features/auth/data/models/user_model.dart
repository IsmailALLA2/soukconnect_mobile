import '../../domain/entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserModel — data layer representation of a user
//
// Extends [UserEntity] so it can flow directly through the domain layer
// without extra mapping. Adds serialization for Supabase responses.
//
// Expected Supabase `profiles` table columns:
//   id          uuid (FK → auth.users.id)
//   role        text  ('grossiste' | 'detaillant' | 'admin')
//   full_name   text
//   phone       text
//   wilaya      text
//   lat         float8  (nullable)
//   lng         float8  (nullable)
//   created_at  timestamptz
// ─────────────────────────────────────────────────────────────────────────────

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.role,
    required super.fullName,
    required super.phone,
    required super.wilaya,
    super.lat,
    super.lng,
    required super.createdAt,
  });

  // ── Deserialization ───────────────────────────────────────────────────────

  /// Builds a [UserModel] from a Supabase `profiles` row map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id'] as String,
      role:      UserRole.fromString(json['role'] as String?),
      fullName:  json['full_name'] as String? ?? '',
      phone:     json['phone'] as String? ?? '',
      wilaya:    json['wilaya'] as String? ?? '',
      lat:       (json['lat'] as num?)?.toDouble(),
      lng:       (json['lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Converts this model to a map suitable for Supabase upsert/update.
  Map<String, dynamic> toJson() => {
        'id':         id,
        'role':       role.value,
        'full_name':  fullName,
        'phone':      phone,
        'wilaya':     wilaya,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  UserModel copyWith({
    String?   id,
    UserRole? role,
    String?   fullName,
    String?   phone,
    String?   wilaya,
    double?   lat,
    double?   lng,
    DateTime? createdAt,
    // Pass explicit null to clear lat/lng
    bool      clearLat = false,
    bool      clearLng = false,
  }) {
    return UserModel(
      id:        id        ?? this.id,
      role:      role      ?? this.role,
      fullName:  fullName  ?? this.fullName,
      phone:     phone     ?? this.phone,
      wilaya:    wilaya    ?? this.wilaya,
      lat:       clearLat  ? null : (lat ?? this.lat),
      lng:       clearLng  ? null : (lng ?? this.lng),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Convenience constructors ──────────────────────────────────────────────

  /// Creates an empty placeholder model (e.g. during loading).
  factory UserModel.empty() => UserModel(
        id:        '',
        role:      UserRole.detaillant,
        fullName:  '',
        phone:     '',
        wilaya:    '',
        createdAt: DateTime.now(),
      );

  /// Promotes a [UserEntity] to a [UserModel].
  factory UserModel.fromEntity(UserEntity entity) => UserModel(
        id:        entity.id,
        role:      entity.role,
        fullName:  entity.fullName,
        phone:     entity.phone,
        wilaya:    entity.wilaya,
        lat:       entity.lat,
        lng:       entity.lng,
        createdAt: entity.createdAt,
      );

  @override
  String toString() =>
      'UserModel(id: $id, role: ${role.value}, name: $fullName)';
}
