import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';

class ExtrasSection extends StatelessWidget {
  final List<ExtraEntity> extras;
  final Set<String> selectedIds;
  final ValueChanged<ExtraEntity> onToggle;

  const ExtrasSection({
    super.key,
    required this.extras,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (extras.isEmpty) return const SizedBox.shrink();
    final lang = context.locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'product.extras'.tr(),
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: extras.map((e) {
            final selected = selectedIds.contains(e.id);
            return FilterChip(
              selected: selected,
              showCheckmark: false,
              selectedColor: AppColors.primaryBrown,
              backgroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.primaryBrown),
              labelStyle: TextStyle(
                color: selected ? AppColors.white : AppColors.primaryBrown,
                fontSize: 13.sp,
              ),
              label: Text('${e.title(lang)}  +${e.price.toStringAsFixed(0)}'),
              onSelected: (_) => onToggle(e),
            );
          }).toList(),
        ),
      ],
    );
  }
}
