import 'package:flutter/material.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';

class CartItemModel {
  final ProductEntity product;
  final String? crepeType;
  final num priceModifier;
  final List<ExtraEntity> extras;
  int quantity;

  CartItemModel({
    required this.product,
    this.crepeType,
    this.priceModifier = 0,
    this.extras = const [],
    this.quantity = 1,
  });

  dynamic get id => product.id;

  String productName(BuildContext context) => product.localizedName(context);

  num get originalPrice => product.price;

  int get discount => product.discountPercentage ?? 0;

  num get discountedPrice => product.price * (1 - discount / 100);

  num get extrasTotal => extras.fold<num>(0, (sum, e) => sum + e.price);

  num get unitPrice => discountedPrice + priceModifier + extrasTotal;

  num get lineTotal => unitPrice * quantity;

  String get cartItemKey {
    final ids = extras.map((e) => e.id).toList()..sort();
    return '${product.id}_${crepeType ?? 'none'}_${ids.join('-')}';
  }

  CartItemModel copyWith({
    int? quantity,
    String? crepeType,
    num? priceModifier,
    List<ExtraEntity>? extras,
  }) {
    return CartItemModel(
      product: product,
      crepeType: crepeType ?? this.crepeType,
      priceModifier: priceModifier ?? this.priceModifier,
      extras: extras ?? this.extras,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          other.cartItemKey == cartItemKey &&
          other.quantity == quantity;

  @override
  int get hashCode => Object.hash(cartItemKey, quantity);
}