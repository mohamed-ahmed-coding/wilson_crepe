import 'package:equatable/equatable.dart';

class CrepeTypePriceEntity extends Equatable {
  final String id;
  final String categoryId;
  final String type;
  final double priceModifier;
  final bool isAvailable;

  const CrepeTypePriceEntity({
    required this.id,
    required this.categoryId,
    required this.type,
    required this.priceModifier,
    this.isAvailable = true,
  });

  @override
  List<Object?> get props => [
        id,
        categoryId,
        type,
        priceModifier,
        isAvailable,
      ];
}