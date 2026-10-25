import '../../domain/entities/crepe_type_price_entity.dart';

class CrepeTypePriceModel extends CrepeTypePriceEntity {
  const CrepeTypePriceModel({
    required super.id,
    required super.categoryId,
    required super.type,
    required super.priceModifier,
    super.isAvailable
  });

  factory CrepeTypePriceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CrepeTypePriceModel(
      id: json['id'].toString(),
      categoryId: json['category_id'].toString(),
      type: json['type'] as String,
      priceModifier: (json['price_modifier'] as num).toDouble(),
      isAvailable: json['is_available'] as bool? ?? true
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'type': type,
      'price_modifier': priceModifier,
      'is_available': isAvailable
    };
  }
}