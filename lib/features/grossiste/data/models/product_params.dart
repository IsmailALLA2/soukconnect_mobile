class ProductCreateParams {
  const ProductCreateParams({
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.imageUrl,
  });

  final String storeId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stock;
  final String? imageUrl;
}

class ProductUpdateParams {
  const ProductUpdateParams({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.stock,
    this.imageUrl,
    this.isAvailable,
  });

  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String unit;
  final int stock;
  final String? imageUrl;
  final bool? isAvailable;
}
