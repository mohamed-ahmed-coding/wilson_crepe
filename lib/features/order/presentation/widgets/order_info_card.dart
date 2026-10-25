import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';

class OrderInfoCard extends StatelessWidget {
  final OrderEntity order;

  const OrderInfoCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBrown.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          if (_has(order.customerName))
            _row(Icons.person, 'order_info.customer'.tr(), order.customerName!),

          if (_has(order.phone))
            _row(Icons.phone, 'order_info.phone'.tr(), order.phone!),

          if (_has(order.address))
            _row(Icons.location_on, 'order_info.address'.tr(), order.address!),

          if (_has(order.notes))
            _row(Icons.note_alt, 'order_info.notes'.tr(), order.notes!),

          Divider(color: AppColors.lightBrown.withValues(alpha: 0.5)),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'order_info.total'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  'order_info.currency_amount'.tr(
                    namedArgs: {'amount': order.totalPrice.toStringAsFixed(2)},
                  ),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _has(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: AppColors.lightBrown),
          SizedBox(width: 10.w),
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }
}
