import 'package:equatable/equatable.dart';

import '../../../detaillant/domain/entities/order_entity.dart';
import '../../../detaillant/domain/entities/order_item_entity.dart';

class IncomingOrderEntity extends Equatable {
  const IncomingOrderEntity({
    required this.id,
    required this.detaillantId,
    required this.detaillantName,
    required this.detaillantPhone,
    required this.storeId,
    this.status = 'pending',
    required this.total,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  final String id;
  final String detaillantId;
  final String detaillantName;
  final String detaillantPhone;
  final String storeId;
  final String status;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemEntity> items;

  OrderStatus get statusEnum => OrderStatus.fromString(status);

  @override
  List<Object?> get props => [
        id,
        detaillantId,
        detaillantName,
        detaillantPhone,
        storeId,
        status,
        total,
        notes,
        createdAt,
        items,
      ];
}
