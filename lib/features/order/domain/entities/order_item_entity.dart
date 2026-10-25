import 'package:equatable/equatable.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final int? orderId;
  final int productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double itemTotal;
  final DateTime? createdAt;
  final int? discountPercentage;
  final String? crepeType;
  final double priceModifier;
  final List<ExtraEntity> extras;

  const OrderItemEntity({
    this.id,
    this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.itemTotal,
    this.createdAt,
    this.discountPercentage,
    this.crepeType,
    this.priceModifier = 0,
    this.extras = const [],
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productPrice,
        quantity,
        itemTotal,
        createdAt,
        discountPercentage,
        crepeType,
        priceModifier,
        extras,
      ];
}