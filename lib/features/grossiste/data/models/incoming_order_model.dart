import '../../../detaillant/domain/entities/order_item_entity.dart';
import '../../domain/entities/incoming_order_entity.dart';

class IncomingOrderModel extends IncomingOrderEntity {
  const IncomingOrderModel({
    required super.id,
    required super.detaillantId,
    required super.detaillantName,
    required super.detaillantPhone,
    required super.storeId,
    super.status,
    required super.total,
    super.notes,
    required super.createdAt,
    super.items,
  });

  factory IncomingOrderModel.fromJson(Map<String, dynamic> json) {
    return IncomingOrderModel(
      id: json['id'] as String,
      detaillantId: json['detaillant_id'] as String,
      detaillantName: json['detaillant_name'] as String? ?? '',
      detaillantPhone: json['detaillant_phone'] as String? ?? '',
      storeId: json['store_id'] as String,
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
    );
  }

  factory IncomingOrderModel.fromJoinedJson(Map<String, dynamic> json) {
    final items = (json['order_items'] as List<dynamic>?)
            ?.map((e) => OrderItemEntity(
                  productId: e['product_id'] as String,
                  name: e['name'] as String,
                  price: (e['price'] as num).toDouble(),
                  quantity: (e['quantity'] as num).toInt(),
                ))
            .toList() ??
        [];

    final profiles = json['profiles'] as Map<String, dynamic>?;

    return IncomingOrderModel(
      id: json['id'] as String,
      detaillantId: json['detaillant_id'] as String,
      detaillantName: profiles?['full_name'] as String? ?? '',
      detaillantPhone: profiles?['phone'] as String? ?? '',
      storeId: json['store_id'] as String,
      status: json['status'] as String? ?? 'pending',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String).toLocal()
          : DateTime.now(),
      items: items,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'detaillant_id': detaillantId,
        'detaillant_name': detaillantName,
        'detaillant_phone': detaillantPhone,
        'store_id': storeId,
        'status': status,
        'total': total,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  IncomingOrderModel copyWith({
    String? id,
    String? detaillantId,
    String? detaillantName,
    String? detaillantPhone,
    String? storeId,
    String? status,
    double? total,
    String? notes,
    DateTime? createdAt,
    List<OrderItemEntity>? items,
    bool clearNotes = false,
  }) {
    return IncomingOrderModel(
      id: id ?? this.id,
      detaillantId: detaillantId ?? this.detaillantId,
      detaillantName: detaillantName ?? this.detaillantName,
      detaillantPhone: detaillantPhone ?? this.detaillantPhone,
      storeId: storeId ?? this.storeId,
      status: status ?? this.status,
      total: total ?? this.total,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }
}
