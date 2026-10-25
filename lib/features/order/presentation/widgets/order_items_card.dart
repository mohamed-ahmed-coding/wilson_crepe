import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';

class OrderItemsCard extends StatelessWidget {
  final List<OrderItemEntity> items;

  const OrderItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalQty = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightBrown.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'order_items.title'.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBrown,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'order_items.quantity'.tr(
                  namedArgs: {'count': totalQty.toString()},
                ),
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: AppColors.lightBrown.withValues(alpha: 0.3),
              ),
            _ItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemEntity item;

  const _ItemRow({required this.item});

  String _formatPrice(num value) {
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    return 'order_items.currency_amount'.tr(namedArgs: {'amount': text});
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
    final lang = context.locale.languageCode;
    final discount = item.discountPercentage ?? 0;
    final hasDiscount = discount > 0;
    final crepeType = _localizedCrepeType(item.crepeType);

    final extrasTotal = item.extras.fold<double>(
      0,
      (sum, e) => sum + e.price,
    );

    final discountedPrice = item.productPrice;
    final originalPrice = hasDiscount
        ? ((discountedPrice / (1 - discount / 100)) * 100).round() / 100
        : discountedPrice;

    final savedAmount = (originalPrice - discountedPrice) * item.quantity;

    final finalUnitPrice = discountedPrice + item.priceModifier + extrasTotal;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primaryBrown.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '${item.quantity}x',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBrown,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    hasDiscount
                        ? 'cart.price_after_discount_each'.tr(
                            namedArgs: {'price': _formatPrice(discountedPrice)},
                          )
                        : 'cart.original_price_each'.tr(
                            namedArgs: {'price': _formatPrice(originalPrice)},
                          ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                if (crepeType.isNotEmpty && item.priceModifier > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '${'order_items.crepe_type'.tr(namedArgs: {'type': crepeType})}'
                      '${item.priceModifier > 0 ? ' (+ ${_formatPrice(item.priceModifier)})' : ''}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                for (final extra in item.extras)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      '+ ${extra.title(lang)} (${_formatPrice(extra.price)})',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.orange,
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
                        '${'cart.discount_off'.tr(namedArgs: {'discount': '$discount'})}'
                        '  (-${_formatPrice(savedAmount)})',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.green.shade700,
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
                    namedArgs: {'price': _formatPrice(originalPrice)},
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.lightBrown,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Text(
                'cart.price_each'.tr(
                  namedArgs: {'price': _formatPrice(finalUnitPrice)},
                ),
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                ),
              ),
              if (item.quantity > 1)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    _formatPrice(item.itemTotal),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}