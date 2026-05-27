import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProductEntity — pure domain object, no framework dependencies
// ─────────────────────────────────────────────────────────────────────────────

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.imageUrl,
    required this.isAvailable,
    required this.createdAt,
  });

  /// Supabase row UUID.
  final String id;

  /// UUID of the store this product belongs to.
  final String storeId;

  /// Product display name.
  final String name;

  /// Product description / details.
  final String description;

  /// Wholesale price in MAD.
  final double price;

  /// Measurement unit (e.g. "carton", "kg", "pièce", "litre").
  final String unit;

  /// Current stock quantity (in [unit] units).
  final int stock;

  /// Public URL of the product image (nullable if not uploaded).
  final String? imageUrl;

  /// Whether this product is currently purchasable by détaillants.
  final bool isAvailable;

  /// Record creation timestamp (UTC).
  final DateTime createdAt;

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Returns `true` when the product has an image.
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Returns `true` when there is stock remaining.
  bool get inStock => stock > 0;

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        storeId,
        name,
        description,
        price,
        unit,
        stock,
        imageUrl,
        isAvailable,
        createdAt,
      ];

  @override
  String toString() =>
      'ProductEntity(id: $id, name: $name, price: ${price.toStringAsFixed(2)} MAD)';
}
