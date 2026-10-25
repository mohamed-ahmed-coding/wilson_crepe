import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final String id;
  final String categoryId;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final String imageUrl;
  final int? discountPercentage;
  final bool isAvailable;

  const ProductEntity({
    required this.id,
    required this.categoryId,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.imageUrl,
    this.discountPercentage,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [
    id,
    categoryId,
    nameEn,
    nameAr,
    descriptionEn,
    descriptionAr,
    price,
    imageUrl,
    isAvailable,
    discountPercentage,
  ];
}
