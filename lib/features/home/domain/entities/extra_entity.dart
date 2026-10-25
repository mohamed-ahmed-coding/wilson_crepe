import 'package:equatable/equatable.dart';

class ExtraEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final double price;

  const ExtraEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.price,
  });

  String title(String langCode) =>
      langCode == 'ar' && nameAr.isNotEmpty ? nameAr : nameEn;

  @override
  List<Object?> get props => [id, nameEn, nameAr, price];
}