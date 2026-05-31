import '../../../detaillant/domain/entities/store_entity.dart';

class MyStoreEntity extends StoreEntity {
  const MyStoreEntity({
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
    required this.totalProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalRevenue,
  });

  final int totalProducts;
  final int totalOrders;
  final int pendingOrders;
  final double totalRevenue;

  @override
  List<Object?> get props => [
        ...super.props,
        totalProducts,
        totalOrders,
        pendingOrders,
        totalRevenue,
      ];
}
