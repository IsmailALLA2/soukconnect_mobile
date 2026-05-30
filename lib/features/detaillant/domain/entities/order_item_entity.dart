import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  const OrderItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  @override
  List<Object?> get props => [productId, name, price, quantity];
}
