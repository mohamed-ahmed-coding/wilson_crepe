import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/domain/entities/category_entity.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/category_chip.dart';

class CategoriesList extends StatelessWidget {
  final List<CategoryEntity> categories;
  final String? selectedCategoryId;
  final VoidCallback onAllSelected;
  final ValueChanged<String> onCategorySelected;

  const CategoriesList({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onAllSelected,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        clipBehavior: Clip.none,
        itemCount: categories.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return CategoryChip(
              label: 'home.all'.tr(),
              isSelected: selectedCategoryId == null,
              onSelected: onAllSelected,
            );
          }

          final category = categories[index - 1];

          return CategoryChip(
            label: category.localizedName(context),
            isSelected: category.id == selectedCategoryId,
            onSelected: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}