import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';

class ProductInfo extends StatelessWidget {
  final ProductEntity product;
  final double finalPrice;

  const ProductInfo({
    super.key,
    required this.product,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discountPercentage != null && product.discountPercentage! > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.localizedName(context),
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        if (hasDiscount)
          Text(
            '${product.price.toStringAsFixed(0)} ${'currency.egp'.tr()}',
            style: TextStyle(
              color: AppColors.lightBrown,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              '${finalPrice.toStringAsFixed(0)} ${'currency.egp'.tr()}',
              style: TextStyle(
                color: AppColors.orange,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (hasDiscount)
              Text(
                'product.discount_off'.tr(
                  namedArgs: {'percentage': '${product.discountPercentage}'},
                ),
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 20.h),
        Text(
          'product.description'.tr(),
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          product.localizedDescription(context),
          style: TextStyle(
            color: AppColors.lightBrown,
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
