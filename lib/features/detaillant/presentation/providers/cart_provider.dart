import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/cart_item.dart';

part 'cart_provider.g.dart';

sealed class CartAddResult {
  const CartAddResult();
}

class CartAdded extends CartAddResult {
  const CartAdded();
}

class CartStoreConflict extends CartAddResult {
  const CartStoreConflict(this.currentStoreId);
  final String currentStoreId;
}

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() => [];

  CartAddResult addItem(CartItem item) {
    if (state.isEmpty) {
      state = [item];
      return const CartAdded();
    }

    final currentStoreId = state.first.storeId;
    if (item.storeId != currentStoreId) {
      return CartStoreConflict(currentStoreId);
    }

    final index = state.indexWhere((i) => i.product.id == item.product.id);
    if (index >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index)
            state[i].copyWith(quantity: state[i].quantity + item.quantity)
          else
            state[i],
      ];
    } else {
      state = [...state, item];
    }
    return const CartAdded();
  }

  void forceClearAndAdd(CartItem item) {
    state = [item];
  }

  void removeItem(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void incrementItem(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  void decrementItem(String productId) {
    final updated = <CartItem>[];
    for (final item in state) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          updated.add(item.copyWith(quantity: item.quantity - 1));
        }
      } else {
        updated.add(item);
      }
    }
    state = updated;
  }

  void clearCart() => state = [];

  double get totalPrice =>
      state.fold<double>(0, (sum, item) => sum + item.subtotal);

  int get totalItems =>
      state.fold<int>(0, (sum, item) => sum + item.quantity);
}
