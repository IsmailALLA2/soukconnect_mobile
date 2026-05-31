import '../../../detaillant/domain/entities/store_entity.dart';
import '../../domain/entities/my_store_entity.dart';

class MyStoreModel extends MyStoreEntity {
  const MyStoreModel({
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
    required super.totalProducts,
    required super.totalOrders,
    required super.pendingOrders,
    required super.totalRevenue,
  });

  factory MyStoreModel.fromJson(Map<String, dynamic> json) {
    return MyStoreModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: StoreCategory.fromString(json['category'] as String?),
      phone: json['phone'] as String,
      wilaya: json['wilaya'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      totalProducts: (json['total_products'] as num?)?.toInt() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      pendingOrders: (json['pending_orders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'name': name,
        'description': description,
        'category': category.value,
        'phone': phone,
        'wilaya': wilaya,
        'address': address,
        'lat': lat,
        'lng': lng,
        'is_active': isActive,
        'created_at': createdAt.toUtc().toIso8601String(),
        'total_products': totalProducts,
        'total_orders': totalOrders,
        'pending_orders': pendingOrders,
        'total_revenue': totalRevenue,
      };

  MyStoreModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    StoreCategory? category,
    String? phone,
    String? wilaya,
    String? address,
    double? lat,
    double? lng,
    bool? isActive,
    DateTime? createdAt,
    double? distanceInKm,
    int? totalProducts,
    int? totalOrders,
    int? pendingOrders,
    double? totalRevenue,
    Object? latSentinel = _sentinel,
    Object? lngSentinel = _sentinel,
    Object? distanceSentinel = _sentinel,
  }) {
    return MyStoreModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      wilaya: wilaya ?? this.wilaya,
      address: address ?? this.address,
      lat: latSentinel == _sentinel ? this.lat : lat,
      lng: lngSentinel == _sentinel ? this.lng : lng,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      distanceInKm: distanceSentinel == _sentinel
          ? this.distanceInKm
          : distanceInKm,
      totalProducts: totalProducts ?? this.totalProducts,
      totalOrders: totalOrders ?? this.totalOrders,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
    );
  }
}

const _sentinel = Object();
