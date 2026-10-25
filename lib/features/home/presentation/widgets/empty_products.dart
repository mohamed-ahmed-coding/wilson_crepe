import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class EmptyProducts extends StatelessWidget {
  const EmptyProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBrown),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off, color: AppColors.primaryBrown, size: 42.w),
            SizedBox(height: 10.h),
            Text(
              'home.no_products_in_this_category'.tr(),
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'home.try_another_category'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightBrown, fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}