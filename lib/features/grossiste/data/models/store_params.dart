import '../../../detaillant/domain/entities/store_entity.dart';

class StoreCreateParams {
  const StoreCreateParams({
    required this.name,
    required this.description,
    required this.category,
    required this.phone,
    required this.wilaya,
    required this.address,
    this.lat,
    this.lng,
  });

  final String name;
  final String description;
  final StoreCategory category;
  final String phone;
  final String wilaya;
  final String address;
  final double? lat;
  final double? lng;
}

class StoreUpdateParams {
  const StoreUpdateParams({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.phone,
    required this.wilaya,
    required this.address,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String description;
  final StoreCategory category;
  final String phone;
  final String wilaya;
  final String address;
  final double? lat;
  final double? lng;
}
