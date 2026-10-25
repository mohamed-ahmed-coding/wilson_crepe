import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/home/domain/entities/crepe_type_price_entity.dart';

class CrepeTypeSelector extends StatelessWidget {
  final List<CrepeTypePriceEntity> prices;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const CrepeTypeSelector({
    super.key,
    required this.prices,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'crepe_type.title'.tr(),
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: prices.map((price) {
            final type = price.type;
            final isAvailable = price.isAvailable;
            final title = 'crepe_type.$type'.tr();

            return isAvailable ? _buildChip(
              type: type,
              title: title,
              priceModifier: price.priceModifier,
            ) : Container(
              height: 35.h,
              margin: EdgeInsets.only(top: 3.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.lightBrown),
              ),
              child: Text(
                'crepe_type.not_available'.tr(
                  namedArgs: {'name': title},
                ),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String type,
    required String title,
    required double priceModifier,
  }) {
    final isSelected = selectedType == type;

    final label = 'crepe_type.price_modifier'.tr(
      namedArgs: {'name': title, 'price': priceModifier.toStringAsFixed(0)},
    );

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTypeChanged(type),
      selectedColor: AppColors.primaryBrown,
      backgroundColor: AppColors.lightBrown.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.white : AppColors.primaryBrown,
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? AppColors.primaryBrown : AppColors.lightBrown,
        ),
      ),
    );
  }
}
