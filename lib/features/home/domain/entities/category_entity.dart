import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final bool supportsCrepeType;
  final bool allowExtras;

  const CategoryEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.supportsCrepeType,
    required this.allowExtras,
  });

  @override
  List<Object?> get props => [id, nameEn, nameAr, supportsCrepeType, allowExtras];
}
