import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class EmptySelection extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final String buttonTitle;
  final VoidCallback onButtonPressed;

  const EmptySelection({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.buttonTitle,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryBrown),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBrown, size: 42.w),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightBrown, fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            InkWell(
              onTap: onButtonPressed,
              child: Container(
                width: double.infinity,
                height: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryBrown,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 18.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
