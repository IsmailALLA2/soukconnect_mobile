import '../../domain/entities/product_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ProductModel — data layer representation of a product
//
// Extends [ProductEntity] so it flows directly through the domain layer
// without extra mapping. Adds JSON serialization for Supabase responses.
//
// Expected Supabase `products` table columns:
//   id           uuid (PK)
//   store_id     uuid (FK → stores.id)
//   name         text
//   description  text
//   price        float8
//   unit         text  (e.g. 'carton', 'kg', 'pièce', 'litre')
//   stock        int4
//   image_url    text  (nullable)
//   is_available bool
//   created_at   timestamptz
// ─────────────────────────────────────────────────────────────────────────────

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    required super.name,
    required super.description,
    required super.price,
    required super.unit,
    required super.stock,
    super.imageUrl,
    required super.isAvailable,
    required super.createdAt,
  });

  // ── Deserialization ───────────────────────────────────────────────────────

  /// Builds a [ProductModel] from a Supabase `products` row map.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id:          json['id'] as String,
      storeId:     json['store_id'] as String,
      name:        json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price:       (json['price'] as num?)?.toDouble() ?? 0.0,
      unit:        json['unit'] as String? ?? '',
      stock:       json['stock'] as int? ?? 0,
      imageUrl:    json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt:   json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  /// Converts this model to a map suitable for Supabase upsert/update.
  Map<String, dynamic> toJson() => {
        'id':           id,
        'store_id':     storeId,
        'name':         name,
        'description':  description,
        'price':        price,
        'unit':         unit,
        'stock':        stock,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_available': isAvailable,
        'created_at':   createdAt.toUtc().toIso8601String(),
      };

  // ── copyWith ──────────────────────────────────────────────────────────────

  ProductModel copyWith({
    String?   id,
    String?   storeId,
    String?   name,
    String?   description,
    double?   price,
    String?   unit,
    int?      stock,
    String?   imageUrl,
    bool?     isAvailable,
    DateTime? createdAt,
    // Pass explicit null to clear imageUrl
    bool      clearImageUrl = false,
  }) {
    return ProductModel(
      id:          id          ?? this.id,
      storeId:     storeId     ?? this.storeId,
      name:        name        ?? this.name,
      description: description ?? this.description,
      price:       price       ?? this.price,
      unit:        unit        ?? this.unit,
      stock:       stock       ?? this.stock,
      imageUrl:    clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt:   createdAt   ?? this.createdAt,
    );
  }

  // ── Convenience constructors ──────────────────────────────────────────────

  /// Creates an empty placeholder model (e.g. during loading).
  factory ProductModel.empty() => ProductModel(
        id:          '',
        storeId:     '',
        name:        '',
        description: '',
        price:       0.0,
        unit:        '',
        stock:       0,
        isAvailable: false,
        createdAt:   DateTime.now(),
      );

  /// Promotes a [ProductEntity] to a [ProductModel].
  factory ProductModel.fromEntity(ProductEntity entity) => ProductModel(
        id:          entity.id,
        storeId:     entity.storeId,
        name:        entity.name,
        description: entity.description,
        price:       entity.price,
        unit:        entity.unit,
        stock:       entity.stock,
        imageUrl:    entity.imageUrl,
        isAvailable: entity.isAvailable,
        createdAt:   entity.createdAt,
      );

  @override
  String toString() =>
      'ProductModel(id: $id, name: $name, price: ${price.toStringAsFixed(2)} MAD)';
}
