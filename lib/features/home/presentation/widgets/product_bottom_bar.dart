import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';

class ProductBottomBar extends StatelessWidget {
  final CartItemModel? cartItem;
  final CartCubit cartCubit;
  final VoidCallback onAdd;

  const ProductBottomBar({
    super.key,
    required this.cartItem,
    required this.cartCubit,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final quantity = cartItem?.quantity ?? 0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 180.w,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onAdd,
              child: Text(
                'product.add_to_cart'.tr(),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.remove,
            onPressed: () {
              final item = cartItem;
              if (item == null || quantity <= 0) return;
              if (quantity > 1) {
                cartCubit.decrease(item);
                return;
              }
              cartCubit.remove(item);
              if (!context.mounted) return;
              _showMessage(
                context,
                productName: item.product.localizedName(context),
                translationKey: 'product.removed_from_cart_successfully',
              );
            },
          ),
          Text(
            '$quantity',
            style: TextStyle(
              color: AppColors.primaryBrown,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          _QuantityButton(icon: Icons.add, onPressed: onAdd),
        ],
      ),
    );
  }

  void _showMessage(
    BuildContext context, {
    required String productName,
    required String translationKey,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            translationKey.tr(namedArgs: {'product': productName}),
            style: TextStyle(color: AppColors.white, fontSize: 16.sp),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primaryBrown,
        ),
      );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBrown.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBrown),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: icon == Icons.add
            ? 'cart.increase_quantity'.tr()
            : 'cart.decrease_quantity'.tr(),
        icon: Icon(icon, color: AppColors.primaryBrown, size: 28.sp),
      ),
    );
  }
}
