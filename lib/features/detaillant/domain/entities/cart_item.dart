import 'package:equatable/equatable.dart';

import 'product_entity.dart';

class CartItem extends Equatable {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.storeId,
  });

  final ProductEntity product;
  final int quantity;
  final String storeId;

  double get subtotal => product.price * quantity;

  CartItem copyWith({ProductEntity? product, int? quantity, String? storeId}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      storeId: storeId ?? this.storeId,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, storeId];
}
