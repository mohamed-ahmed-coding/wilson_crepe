import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    super.id,
    super.orderId,
    required super.productId,
    required super.productName,
    required super.productPrice,
    required super.quantity,
    required super.itemTotal,
    super.createdAt,
    super.discountPercentage,
    super.crepeType,
    super.priceModifier,
    super.extras,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawExtras = json['extras'] as List? ?? const [];

    return OrderItemModel(
      id: json['id'] as int?,
      orderId: json['order_id'] as int?,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String,
      productPrice: (json['product_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      itemTotal: (json['item_total'] as num).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      discountPercentage: (json['discount_percentage'] as num?)?.toInt(),
      crepeType: json['crepe_type'] as String?,
      priceModifier: (json['price_modifier'] as num?)?.toDouble() ?? 0,
      extras: rawExtras.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return ExtraEntity(
          id: (map['extra_id'] ?? map['id']).toString(),
          nameEn: map['name_en'] as String? ?? '',
          nameAr: map['name_ar'] as String? ?? '',
          price: (map['price'] as num).toDouble(),
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extras': extras
          .map(
            (e) => {
              'extra_id': int.tryParse(e.id),
              'name_en': e.nameEn,
              'name_ar': e.nameAr,
              'price': e.price,
            },
          )
          .toList(),
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'item_total': itemTotal,
      'created_at': createdAt?.toIso8601String(),
      'discount_percentage': discountPercentage,
      'crepe_type': crepeType,
      'price_modifier': priceModifier,
    };
  }
}