import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserRole enum
// ─────────────────────────────────────────────────────────────────────────────

enum UserRole {
  grossiste,
  detaillant,
  admin;

  /// Converts a raw string from Supabase to [UserRole].
  /// Falls back to [UserRole.detaillant] for unknown values.
  static UserRole fromString(String? value) => switch (value?.toLowerCase()) {
        'grossiste'  => UserRole.grossiste,
        'admin'      => UserRole.admin,
        _            => UserRole.detaillant,
      };

  /// Returns the snake_case string stored in Supabase.
  String get value => name; // 'grossiste' | 'detaillant' | 'admin'

  /// Human-readable French label.
  String get label => switch (this) {
        UserRole.grossiste  => 'Grossiste',
        UserRole.detaillant => 'Détaillant',
        UserRole.admin      => 'Administrateur',
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// UserEntity — pure domain object, no framework dependencies
// ─────────────────────────────────────────────────────────────────────────────

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.role,
    required this.fullName,
    required this.phone,
    required this.wilaya,
    this.lat,
    this.lng,
    required this.createdAt,
  });

  /// Supabase auth UID (UUID).
  final String id;

  /// Business role of this user.
  final UserRole role;

  /// Full display name.
  final String fullName;

  /// Moroccan phone number (06/07 + 8 digits).
  final String phone;

  /// Province / Wilaya (e.g. "Casablanca-Settat").
  final String wilaya;

  /// GPS latitude of store / user location (nullable until set).
  final double? lat;

  /// GPS longitude of store / user location (nullable until set).
  final double? lng;

  /// Account creation timestamp (UTC).
  final DateTime createdAt;

  // ── Computed helpers ─────────────────────────────────────────────────────

  bool get isGrossiste  => role == UserRole.grossiste;
  bool get isDetaillant => role == UserRole.detaillant;
  bool get isAdmin      => role == UserRole.admin;

  /// Returns `true` when the user has set their location.
  bool get hasLocation  => lat != null && lng != null;

  // ── Equatable ────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id, role, fullName, phone, wilaya, lat, lng, createdAt,
      ];

  @override
  String toString() =>
      'UserEntity(id: $id, role: ${role.value}, name: $fullName)';
}
