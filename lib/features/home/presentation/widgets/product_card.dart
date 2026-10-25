import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_state.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;

  const ProductCard({super.key, required this.product});

  static const double _radius = 20;

  double get _discount {
    final d = product.discountPercentage;
    return (d == null || d <= 0) ? 0 : d.toDouble();
  }

  bool get _hasDiscount => _discount > 0;

  double get _finalPrice => _hasDiscount
      ? product.price - (product.price * _discount / 100)
      : product.price.toDouble();

  String get _discountLabel =>
      '${_discount.toStringAsFixed(_discount % 1 == 0 ? 0 : 1)}%';

  void _showSnack(BuildContext context, String message, IconData icon) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primaryBrown,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(icon, color: AppColors.white, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message.tr(
                    namedArgs: {'product': product.localizedName(context)},
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: AppColors.white, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) => previous.favoriteProductIds != current.favoriteProductIds,
      builder: (context, state) {
        final isFavorite = state.favoriteProductIds.contains(product.id);
        final isAvailable = product.isAvailable;

        return Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(_radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: () {
              if (isAvailable) {
                GoRouter.of(context).pushNamed(AppRoutes.productDetails, extra: product);
              }
            },
            child: Ink(
              height: 160.h,
              padding: EdgeInsets.all(8.w),
              decoration: isAvailable
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(_radius),
                      border: Border.all(color: AppColors.primaryBrown),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    )
                  : BoxDecoration(
                      borderRadius: BorderRadius.circular(_radius),
                      color: AppColors.primaryBrown.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.primaryBrown.withValues(alpha: 0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
              child: Row(
                children: [
                  _buildImage(context),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildDetails(context, isFavorite)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context) {
    return SizedBox(
      width: 116.w,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius - 6),
            child: _buildProductImage(context, product.imageUrl),
          ),
          if (_hasDiscount)
            Positioned(
              top: 8.h,
              left: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _discountLabel,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, bool isFavorite) {
    final productName = product.localizedName(context).toString().trim();
    final isAvailable = product.isAvailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.primaryBrown,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
            _FavoriteButton(
              isFavorite: isFavorite,
              onTap: () {
                if (isAvailable) {
                  HapticFeedback.selectionClick();
                  _showSnack(
                    context,
                    isFavorite ? 'favorites.removed' : 'favorites.added',
                    isFavorite ? Icons.heart_broken_outlined : Icons.favorite,
                  );
                  context.read<HomeCubit>().toggleFavorite(product.id);
                }
              },
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          product.localizedDescription(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.lightBrown,
            fontSize: 12.sp,
            height: 1.3,
          ),
        ),
        SizedBox(height: 10.h),
        if (_hasDiscount)
          Text(
            '${product.price.toStringAsFixed(0)} ${'currency.egp'.tr()}',
            style: TextStyle(
              color: AppColors.lightBrown.withValues(alpha: 0.8),
              fontSize: 12.sp,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          '${_finalPrice.toStringAsFixed(0)} ${'currency.egp'.tr()}',
          style: TextStyle(
            color: AppColors.primaryBrown,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isAvailable ? _AddButton(
              color: AppColors.primaryBrown,
              icon: Icons.add,
              title: 'product.add_to_cart'.tr(),
              onTap: () {
                  HapticFeedback.selectionClick();
                  context.read<CartCubit>().addProduct(product);
                  _showSnack(
                    context,
                    'product.added_to_cart_successfully',
                    Icons.check_circle_outline,
                  );
              },
            ) : _AddButton(
              onTap: () {},
              color: AppColors.error,
              icon: Icons.highlight_remove_outlined,
              title: 'product.not_available'.tr(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, String? imageUrl) {
    Widget placeholder(IconData icon) => Container(
      color: AppColors.lightBrown.withValues(alpha: 0.10),
      child: Center(
        child: Icon(icon, size: 36.sp, color: AppColors.lightBrown),
      ),
    );

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return placeholder(Icons.image_not_supported_outlined);
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: (screenWidth * dpr).round(),
        maxWidthDiskCache: (screenWidth * dpr).round(),
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (_, _) => Container(color: AppColors.lightBrown.withValues(alpha: 0.10)),
        errorWidget: (_, _, _) => placeholder(Icons.broken_image_outlined),
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: (screenWidth * dpr).round(),
      errorBuilder: (_, _, _) => placeholder(Icons.broken_image_outlined),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteButton({required this.isFavorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite
          ? 'favorites.remove_accessibility'.tr()
          : 'favorites.add_accessibility'.tr(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFavorite),
              size: 22.sp,
              color: isFavorite ? AppColors.error : AppColors.primaryBrown,
            ),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AddButton({required this.onTap, required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.white),
                SizedBox(width: 4.w),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
