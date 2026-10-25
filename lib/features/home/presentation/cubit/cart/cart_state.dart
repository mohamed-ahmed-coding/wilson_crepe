import 'package:flutter/foundation.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';

@immutable
class CartState {
  final List<CartItemModel> items;

  const CartState({
    this.items = const [],
  });

  bool get isEmpty => items.isEmpty;

  int get totalItems =>
      items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );

  num get totalPrice =>
      items.fold<num>(
        0,
        (sum, item) => sum + item.lineTotal,
      );

  CartState copyWith({
    List<CartItemModel>? items,
  }) {
    return CartState(
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartState &&
          listEquals(other.items, items);

  @override
  int get hashCode => Object.hashAll(items);
}