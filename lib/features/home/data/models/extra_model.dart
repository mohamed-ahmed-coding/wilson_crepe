import '../../domain/entities/extra_entity.dart';

class ExtraModel extends ExtraEntity {
  const ExtraModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.price,
  });

  factory ExtraModel.fromJson(Map<String, dynamic> json) {
    return ExtraModel(
      id: json['id'].toString(),
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
    );
  }
}