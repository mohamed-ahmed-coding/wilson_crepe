import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addProduct(
    ProductEntity product, {
    String? crepeType,
    num priceModifier = 0,
    List<ExtraEntity> extras = const [],
  }) {
    final items = [...state.items];

    final newItem = CartItemModel(
      product: product,
      crepeType: crepeType,
      priceModifier: priceModifier,
      extras: extras,
    );

    final index = items.indexWhere(
      (item) => item.cartItemKey == newItem.cartItemKey,
    );

    if (index == -1) {
      items.add(newItem);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    }

    emit(state.copyWith(items: items));
  }

  void increase(CartItemModel item) {
    if (isClosed) return;

    emit(
      state.copyWith(
        items: [
          for (final i in state.items)
            if (i.cartItemKey == item.cartItemKey)
              i.copyWith(quantity: i.quantity + 1)
            else
              i,
        ],
      ),
    );
  }

  void decrease(CartItemModel item) {
    if (item.quantity <= 1) {
      remove(item);
      return;
    }

    if (isClosed) return;

    emit(
      state.copyWith(
        items: [
          for (final i in state.items)
            if (i.cartItemKey == item.cartItemKey)
              i.copyWith(quantity: i.quantity - 1)
            else
              i,
        ],
      ),
    );
  }

  void remove(CartItemModel item) {
    if (isClosed) return;

    emit(
      state.copyWith(
        items: state.items
            .where((i) => i.cartItemKey != item.cartItemKey)
            .toList(),
      ),
    );
  }

  void clear() {
    emit(const CartState());
  }
}
