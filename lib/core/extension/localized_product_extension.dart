import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import '../../features/home/domain/entities/category_entity.dart';
import '../../features/home/domain/entities/product_entity.dart';

extension LocalizedCategory on CategoryEntity {
  String localizedName(BuildContext context) {
    return _localizedValue(context, nameAr, nameEn);
  }
}

extension LocalizedProduct on ProductEntity {
  String localizedName(BuildContext context) {
    return _localizedValue(context, nameAr, nameEn);
  }

  String localizedDescription(BuildContext context) {
    return _localizedValue(context, descriptionAr, descriptionEn);
  }
}

String _localizedValue(BuildContext context, String arabic, String english) {
  final isArabic = context.locale.languageCode == 'ar';

  if (isArabic) {
    return arabic.trim().isNotEmpty ? arabic : english;
  }

  return english.trim().isNotEmpty ? english : arabic;
}
