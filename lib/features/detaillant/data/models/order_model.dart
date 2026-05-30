import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.detaillantId,
    required super.storeId,
    required super.total,
    super.notes,
    super.status,
    required super.createdAt,
    super.items,
    super.storeName,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      detaillantId: json['client_id'] as String,
      storeId: json['store_id'] as String,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  factory OrderModel.fromJoinedJson(Map<String, dynamic> json) {
    final items = (json['order_items'] as List<dynamic>?)
            ?.map((e) => OrderItemEntity(
                  productId: e['product_id'] as String,
                  name: e['name'] as String,
                  price: (e['price'] as num).toDouble(),
                  quantity: (e['quantity'] as num).toInt(),
                ))
            .toList() ??
        [];

    return OrderModel(
      id: json['id'] as String,
      detaillantId: json['client_id'] as String,
      storeId: json['store_id'] as String,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      items: items,
      storeName: json['stores'] != null
          ? (json['stores'] as Map<String, dynamic>)['name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'client_id': detaillantId,
        'store_id': storeId,
        'total': total,
        if (notes != null) 'notes': notes,
        'status': status,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  OrderModel copyWith({
    String? id,
    String? detaillantId,
    String? storeId,
    double? total,
    String? notes,
    String? status,
    DateTime? createdAt,
    List<OrderItemEntity>? items,
    String? storeName,
    bool clearNotes = false,
    bool clearStoreName = false,
  }) {
    return OrderModel(
      id: id ?? this.id,
      detaillantId: detaillantId ?? this.detaillantId,
      storeId: storeId ?? this.storeId,
      total: total ?? this.total,
      notes: clearNotes ? null : (notes ?? this.notes),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      storeName: clearStoreName ? null : (storeName ?? this.storeName),
    );
  }
}

Map<String, dynamic> orderItemToJson({
  required String orderId,
  required CartItem item,
}) => {
      'order_id': orderId,
      'product_id': item.product.id,
      'name': item.product.name,
      'price': item.product.price,
      'quantity': item.quantity,
    };
