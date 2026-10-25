import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class OrderStatusTimeline extends StatelessWidget {
  final int currentStep;

  const OrderStatusTimeline({super.key, required this.currentStep});

  static const _steps = [
    ('order_timeline.order_placed', Icons.receipt_long),
    ('order_timeline.preparing', Icons.restaurant),
    ('order_timeline.out_for_delivery', Icons.delivery_dining),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        children: List.generate(_steps.length, (i) {
          final done = i <= currentStep;
          final isLast = i == _steps.length - 1;
          final color = done ? AppColors.primaryBrown : Colors.grey.shade400;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 16.r,
                      backgroundColor: done
                          ? AppColors.primaryBrown
                          : Colors.white,
                      child: Icon(
                        _steps[i].$2,
                        size: 16.sp,
                        color: done ? Colors.white : color,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2.w,
                          color: i < currentStep
                              ? AppColors.primaryBrown
                              : Colors.grey.shade300,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(top: 6.h, bottom: 22.h),
                  child: Text(
                    _steps[i].$1.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: i == currentStep
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: done ? AppColors.primaryBrown : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.92),
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: AppColors.lightBrown.withValues(alpha: 0.4)),
  );
}
