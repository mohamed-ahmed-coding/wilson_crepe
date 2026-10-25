import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.supportsCrepeType,
    required super.allowExtras,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      nameEn: json['name_en'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? '',
      supportsCrepeType: json['supports_crepe_type'] as bool? ?? false,
      allowExtras: json['allow_extras'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'supports_crepe_type': supportsCrepeType,
      'allow_extras': allowExtras
    };
  }
}
