import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/empty_selection.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/section_header.dart';
import 'package:wilson_crepe/features/order/presentation/pages/order_screen.dart';

String _formatPrice(num value) {
  final text = value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  return 'cart.currency_egp'.tr(namedArgs: {'amount': text});
}

String _localizedCrepeType(String? type) {
  switch (type) {
    case 'normal':
      return 'crepe_type.normal'.tr();
    case 'roll':
      return 'crepe_type.roll'.tr();
    case 'cono':
      return 'crepe_type.cono'.tr();
    default:
      return type ?? '';
  }
}

class CartScreen extends StatelessWidget {
  final VoidCallback? onBrowseMenu;

  const CartScreen({super.key, this.onBrowseMenu});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Wilson_bg_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, cart) {
            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                SectionHeader(
                  title: 'cart.title'.tr(),
                  subtitle: 'cart.subtitle'.tr(),
                  clearButton: true,
                  onPressed: () {
                    context.read<CartCubit>().clear();
                  },
                ),
                if (cart.isEmpty) ...[
                  SizedBox(height: 150.h),
                  EmptySelection(
                    title: 'cart.empty_title'.tr(),
                    subTitle: 'cart.empty_subtitle'.tr(),
                    icon: Icons.remove_shopping_cart,
                    buttonTitle: 'cart.go_to_menu'.tr(),
                    onButtonPressed: () {
                      onBrowseMenu?.call();
                    },
                  ),
                ] else ...[
                  SizedBox(height: 12.h),
                  Text(
                    'cart.your_cart'.tr(
                      namedArgs: {'count': '${cart.totalItems}'},
                    ),
                    style: TextStyle(
                      color: AppColors.primaryBrown,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  for (final item in cart.items) _CartItemTile(item: item),
                  _CartSummary(
                    totalItems: cart.totalItems,
                    totalPrice: cart.totalPrice,
                  ),
                  SizedBox(height: 16.h),
                  _CheckoutButton(
                    onPressed: () async {
                      final cartCubit = context.read<CartCubit>();

                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cartCubit,
                            child: const OrderScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final lang = context.locale.languageCode;
    final hasDiscount = item.discount > 0;
    final crepeType = _localizedCrepeType(item.crepeType);
    final extrasTotal = item.extrasTotal;
    final finalUnitPrice = item.discountedPrice + item.priceModifier + extrasTotal;
    final unitPrice = hasDiscount ? item.discountedPrice : item.originalPrice;
    final originalPrice = item.originalPrice;
    final finalLineTotal = finalUnitPrice * item.quantity;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBrown),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (item.crepeType != null && item.crepeType!.isNotEmpty && item.priceModifier > 0) ...[
                  SizedBox(height: 4.h),
                  Text(
                    '${'cart.crepe_type'.tr(namedArgs: {'type': crepeType})} ${item.priceModifier > 0 ? '+ (${_formatPrice(item.priceModifier)})' : ''}',
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 12.sp,
                    ),
                  ),
                ],

                if (item.extras.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  for (final extra in item.extras)
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        '+ ${extra.title(lang)} (${_formatPrice(extra.price)})',
                        style: TextStyle(
                          color: AppColors.lightBrown,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],

                SizedBox(height: 12.h),
                Text(
                  'cart.price_each'.tr(
                    namedArgs: {'price': _formatPrice(finalUnitPrice)},
                  ),
                  style: TextStyle(
                    color: AppColors.orange,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasDiscount) ...[
                  SizedBox(height: 5.h),
                  Text(
                    'cart.price_before_discount_each'.tr(
                      namedArgs: {'price': _formatPrice(originalPrice)},
                    ),
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 12.sp,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'cart.discount_off'.tr(
                      namedArgs: {'discount': '${item.discount}'},
                    ),
                    style: TextStyle(color: Colors.green, fontSize: 12.sp),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (hasDiscount) Text(
                'cart.price_after_discount_each'.tr(
                  namedArgs: {'price': _formatPrice(unitPrice)},),
                style: TextStyle(color: AppColors.lightBrown, fontSize: 12.sp),
              ),
              if (!hasDiscount) Text(
                'cart.original_price_each'.tr(
                  namedArgs: {'price': _formatPrice(unitPrice)}),
                style: TextStyle(color: AppColors.lightBrown, fontSize: 12.sp),
              ),
              SizedBox(height: 6.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RoundIconButton(
                    icon: item.quantity <= 1
                        ? Icons.delete_outline
                        : Icons.remove,
                    tooltip: item.quantity <= 1
                        ? 'cart.remove_item'.tr()
                        : 'cart.decrease_quantity'.tr(),
                    onTap: () => cubit.decrease(item),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Text(
                      '${item.quantity}',
                      style: TextStyle(
                        color: AppColors.primaryBrown,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.add,
                    tooltip: 'cart.increase_quantity'.tr(),
                    onTap: () => cubit.increase(item),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                _formatPrice(finalLineTotal),
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: AppColors.primaryBrown.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Icon(icon, size: 18.w, color: AppColors.primaryBrown),
          ),
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final int totalItems;
  final num totalPrice;

  const _CartSummary({required this.totalItems, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBrown.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBrown),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'cart.total'.tr(namedArgs: {'count': '$totalItems'}),
              style: TextStyle(
                color: AppColors.primaryBrown,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            _formatPrice(totalPrice),
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CheckoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        color: AppColors.primaryBrown,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'cart.checkout'.tr(),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.arrow_forward, color: AppColors.white, size: 18.w),
            ],
          ),
        ),
      ),
    );
  }
}
