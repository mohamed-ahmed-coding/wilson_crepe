import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_entity.dart';
import 'package:wilson_crepe/features/order/domain/entities/order_item_entity.dart';
import 'package:wilson_crepe/features/order/presentation/widgets/place_order_button.dart';

class OrderConfirmedScreen extends StatelessWidget {
  final OrderEntity order;
  final List<OrderItemEntity> items;

  const OrderConfirmedScreen({
    super.key,
    required this.order,
    required this.items,
  });

  // Same formatting as OrderSummaryCard: whole numbers without decimals.
  String _formatPrice(num value) {
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);

    return 'order_summary.currency_amount'.tr(namedArgs: {'amount': text});
  }

  String _formatCrepeType(String? type) {
    if (type == null || type.isEmpty) return '';

    switch (type.toLowerCase()) {
      case 'roll':
        return 'crepe_type.roll'.tr();
      case 'cono':
        return 'crepe_type.cono'.tr();
      case 'normal':
        return 'crepe_type.normal'.tr();
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double subtotal = items.fold<double>(0, (sum, item) {
      final discountPercentage = item.discountPercentage ?? 0;

      final double originalPrice = discountPercentage > 0
          ? item.productPrice / (1 - discountPercentage / 100)
          : item.productPrice;

      final double extrasTotal = item.extras.fold<double>(
        0,
        (extrasSum, e) => extrasSum + e.price,
      );

      final double originalUnitPrice =
          originalPrice + item.priceModifier + extrasTotal;

      return sum + (originalUnitPrice * item.quantity);
    });

    final double discount = items.fold<double>(0, (sum, item) {
      final discountPercentage = item.discountPercentage ?? 0;

      if (discountPercentage <= 0) {
        return sum;
      }

      final double originalPrice = item.productPrice / (1 - discountPercentage / 100);

      final double discountAmount = (originalPrice - item.productPrice) * item.quantity;

      return sum + discountAmount;
    });

    final int totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Wilson_bg_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'order_confirmation.title'.tr(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBrown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'order_confirmation.subtitle'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.lightBrown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 320.w,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.primaryBrown),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'order_confirmation.order_id'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          Text(
                            order.id != null
                                ? '#${order.id}'
                                : 'order_confirmation.pending_id'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightBrown,
                            ),
                          ),
                          Divider(
                            color: AppColors.primaryBrown,
                            thickness: 1.w,
                          ),
                          Text(
                            'order_confirmation.items'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          for (int i = 0; i < items.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 16.h,
                                color: AppColors.primaryBrown
                                    .withValues(alpha: 0.15),
                              ),
                            _ConfirmedItemRow(
                              item: items[i],
                              formatPrice: _formatPrice,
                              localizedCrepeType: _formatCrepeType,
                            ),
                          ],
                          Divider(
                            color: AppColors.primaryBrown
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'order_confirmation.subtotal'.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                              Text(
                                _formatPrice(subtotal),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.lightBrown,
                                ),
                              ),
                            ],
                          ),
                          if (discount > 0) ...[
                            SizedBox(height: 6.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'order_confirmation.discount'.tr(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '-${_formatPrice(discount)}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 6.h),
                          Divider(
                            color: AppColors.primaryBrown
                                .withValues(alpha: 0.3),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'order_summary.total'.tr(
                                    namedArgs: {
                                      'count': totalItems.toString(),
                                    },
                                  ),
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBrown,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                _formatPrice(order.totalPrice),
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBrown,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: AppColors.primaryBrown
                                .withValues(alpha: 0.3),
                          ),
                          Text(
                            'order_confirmation.delivered_to'.tr(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            order.address ?? '-',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: PlaceOrderButton(
                      title: 'order_confirmation.go_to_orders'.tr(),
                      isLoading: false,
                      onPressed: () {
                        GoRouter.of(context).goNamed(AppRoutes.ordersHistoryScreen);
                      },
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: PlaceOrderButton(
                      title: 'order_confirmation.go_home'.tr(),
                      isLoading: false,
                      onPressed: () {
                        GoRouter.of(context).goNamed(AppRoutes.homeScreen);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmedItemRow extends StatelessWidget {
  final OrderItemEntity item;
  final String Function(num) formatPrice;
  final String Function(String?) localizedCrepeType;

  const _ConfirmedItemRow({
    required this.item,
    required this.formatPrice,
    required this.localizedCrepeType,
  });

  @override
  Widget build(BuildContext context) {
    final int discountPercentage = item.discountPercentage ?? 0;
    final bool hasDiscount = discountPercentage > 0;

    final double discountedPrice = item.productPrice.toDouble();
    final double originalPrice = hasDiscount
        ? discountedPrice / (1 - discountPercentage / 100)
        : discountedPrice;

    final lang = context.locale.languageCode;
    final double extrasTotal = item.extras.fold<double>(
      0,
      (sum, e) => sum + e.price,
    );

    final double unitPrice =
        discountedPrice + item.priceModifier + extrasTotal;
    final double savedAmount = (originalPrice - discountedPrice) * item.quantity;

    final bool hasCrepeType = item.crepeType != null &&
        item.crepeType!.isNotEmpty &&
        item.priceModifier > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.productName} x${item.quantity}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Text(
                  hasDiscount
                      ? 'cart.price_after_discount_each'.tr(
                          namedArgs: {'price': formatPrice(discountedPrice)},
                        )
                      : 'cart.original_price_each'.tr(
                          namedArgs: {'price': formatPrice(originalPrice)},
                        ),
                  style: TextStyle(
                    color: AppColors.lightBrown,
                    fontSize: 11.sp,
                  ),
                ),
              ),
              if (hasCrepeType)
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
                      '${'cart.discount_off'.tr(namedArgs: {'discount': '$discountPercentage'})}'
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
                namedArgs: {'price': formatPrice(unitPrice)},
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
                  formatPrice(item.itemTotal),
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