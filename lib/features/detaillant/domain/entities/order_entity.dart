import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  cancelled,
  delivered;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.cancelled:
        return 'Annulée';
      case OrderStatus.delivered:
        return 'Livrée';
    }
  }
}

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.detaillantId,
    required this.storeId,
    required this.total,
    this.notes,
    this.status = 'pending',
    required this.createdAt,
    this.items = const [],
    this.storeName,
  });

  final String id;
  final String detaillantId;
  final String storeId;
  final double total;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final List<OrderItemEntity> items;
  final String? storeName;

  OrderStatus get statusEnum => OrderStatus.fromString(status);

  @override
  List<Object?> get props => [
        id,
        detaillantId,
        storeId,
        total,
        notes,
        status,
        createdAt,
        items,
        storeName,
      ];
}
