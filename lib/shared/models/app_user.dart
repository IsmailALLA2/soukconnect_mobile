import 'package:equatable/equatable.dart';

import '../../features/auth/domain/entities/user_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppUser — global, cross-feature user representation
//
// Unlike [UserEntity] (which is owned by the auth feature), [AppUser] is
// available to every feature that needs to know who is logged in.
//
// Preferred import in non-auth features:
//   import 'package:soukconnect_mobile/shared/models/app_user.dart';
// ─────────────────────────────────────────────────────────────────────────────

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  final String   id;
  final UserRole role;
  final String   fullName;
  final String   phone;
  final String   wilaya;
  final double?  lat;
  final double?  lng;
  final DateTime createdAt;

  // ── Role helpers ─────────────────────────────────────────────────────────

  bool get isGrossiste  => role == UserRole.grossiste;
  bool get isDetaillant => role == UserRole.detaillant;
  bool get isAdmin      => role == UserRole.admin;

  /// `true` when GPS coordinates are available.
  bool get hasLocation  => lat != null && lng != null;

  /// Human-readable role label (French).
  String get roleLabel  => role.label;

  // ── Factory constructors ──────────────────────────────────────────────────

  /// Converts a domain [UserEntity] (or [UserModel]) to [AppUser].
  factory AppUser.fromEntity(UserEntity entity) => AppUser(
        id:        entity.id,
        role:      entity.role,
        fullName:  entity.fullName,
        phone:     entity.phone,
        wilaya:    entity.wilaya,
        lat:       entity.lat,
        lng:       entity.lng,
        createdAt: entity.createdAt,
      );

  /// Builds an [AppUser] directly from a Supabase `profiles` row.
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id:        json['id'] as String,
        role:      UserRole.fromString(json['role'] as String?),
        fullName:  json['full_name'] as String? ?? '',
        phone:     json['phone']     as String? ?? '',
        wilaya:    json['wilaya']    as String? ?? '',
        lat:       (json['lat']  as num?)?.toDouble(),
        lng:       (json['lng']  as num?)?.toDouble(),
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String).toLocal()
            : DateTime.now(),
      );

  // ── copyWith ──────────────────────────────────────────────────────────────

  AppUser copyWith({
    String?   id,
    UserRole? role,
    String?   fullName,
    String?   phone,
    String?   wilaya,
    double?   lat,
    double?   lng,
    DateTime? createdAt,
    bool      clearLat = false,
    bool      clearLng = false,
  }) =>
      AppUser(
        id:        id        ?? this.id,
        role:      role      ?? this.role,
        fullName:  fullName  ?? this.fullName,
        phone:     phone     ?? this.phone,
        wilaya:    wilaya    ?? this.wilaya,
        lat:       clearLat  ? null : (lat ?? this.lat),
        lng:       clearLng  ? null : (lng ?? this.lng),
        createdAt: createdAt ?? this.createdAt,
      );

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id, role, fullName, phone, wilaya, lat, lng, createdAt,
      ];

  @override
  String toString() =>
      'AppUser(id: $id, role: ${role.value}, name: $fullName)';
}
