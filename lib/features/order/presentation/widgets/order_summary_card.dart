import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';

class OrderSummaryCard extends StatelessWidget {
  final CartState cart;

  const OrderSummaryCard({super.key, required this.cart});

  String _formatPrice(num value) {
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    return 'order_summary.currency_amount'.tr(namedArgs: {'amount': text});
  }

  String _localizedCrepeType(String? type) {
    if (type == null || type.isEmpty) return '';

    switch (type.toLowerCase()) {
      case 'normal':
        return 'crepe_type.normal'.tr();
      case 'roll':
        return 'crepe_type.roll'.tr();
      case 'cono':
        return 'crepe_type.cono'.tr();
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryBrown),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'order_summary.title'.tr(),
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.h),
          if (cart.isEmpty)
            Text(
              'order_summary.empty_cart'.tr(),
              style: TextStyle(color: AppColors.lightBrown, fontSize: 13.sp),
            )
          else ...[
            for (int i = 0; i < cart.items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 16.h,
                  color: AppColors.primaryBrown.withValues(alpha: 0.15),
                ),
              _SummaryItemRow(
                item: cart.items[i],
                formatPrice: _formatPrice,
                localizedCrepeType: _localizedCrepeType,
              ),
            ],
            Divider(color: AppColors.primaryBrown.withValues(alpha: 0.3)),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'order_summary.total'.tr(
                      namedArgs: {'count': cart.totalItems.toString()},
                    ),
                    style: TextStyle(
                      color: AppColors.primaryBrown,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _formatPrice(cart.totalPrice),
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryItemRow extends StatelessWidget {
  final CartItemModel item;
  final String Function(num) formatPrice;
  final String Function(String?) localizedCrepeType;

  const _SummaryItemRow({
    required this.item,
    required this.formatPrice,
    required this.localizedCrepeType,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final hasDiscount = item.discount > 0;
    final originalPrice = item.originalPrice;
    final discountedPrice = item.discountedPrice;
    final savedAmount = (item.originalPrice - item.discountedPrice) * item.quantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.product.localizedName(context)} x${item.quantity}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasDiscount)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    'cart.price_after_discount_each'.tr(
                      namedArgs: {'price': formatPrice(discountedPrice)},
                    ),
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              if (!hasDiscount)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    'cart.original_price_each'.tr(
                      namedArgs: {'price': formatPrice(originalPrice)},
                    ),
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 11.sp,
                    )
                  ),
                ),
              if (item.crepeType != null && item.priceModifier > 0)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    '${'order_summary.crepe_type'.tr(
                      namedArgs: {'type': localizedCrepeType(item.crepeType)},
                    )} (+ ${formatPrice(item.priceModifier)})',
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              for (final extra in item.extras)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    '+ ${extra.title(lang)} (${formatPrice(extra.price)})',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              if (hasDiscount)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      '${'cart.discount_off'.tr(namedArgs: {'discount': '${item.discount}'})}'
                      '  (-${formatPrice(savedAmount)})',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (hasDiscount)
              Text(
                'cart.price_before_discount_each'.tr(
                  namedArgs: {'price': formatPrice(originalPrice)},
                ),
                style: TextStyle(
                  color: AppColors.lightBrown,
                  fontSize: 11.sp,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              'cart.price_each'.tr(
                namedArgs: {'price': formatPrice(item.unitPrice)},
              ),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.quantity > 1)
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  formatPrice(item.lineTotal),
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}