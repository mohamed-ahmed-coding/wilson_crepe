import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/data/models/cart_item_model.dart';
import 'package:wilson_crepe/features/home/domain/entities/extra_entity.dart';
import 'package:wilson_crepe/features/home/domain/entities/product_entity.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/crepe_type_selector.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/extra_section.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_bottom_bar.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_image.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_info.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedCrepeType = 'normal';
  final Set<String> _selectedExtraIds = {};

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadExtras();
  }

  List<ExtraEntity> _selectedExtras(List<ExtraEntity> all) =>
      all.where((e) => _selectedExtraIds.contains(e.id)).toList();

  void _toggleExtra(ExtraEntity extra) {
    setState(() {
      if (!_selectedExtraIds.remove(extra.id)) {
        _selectedExtraIds.add(extra.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeCubit>().state;
    final cartCubit = context.read<CartCubit>();
    final cartState = context.watch<CartCubit>().state;
    final allExtras = homeState.extras;

    final category = homeState.getCategoryById(widget.product.categoryId);

    final supportsCrepeType = category?.supportsCrepeType ?? false;
    final allowExtras = category?.allowExtras ?? false;

    final prices = homeState.crepeTypePrices
        .where((price) => price.categoryId == widget.product.categoryId)
        .toList();

    final priceModifier = _getPriceModifier(
      prices,
      supportsCrepeType ? selectedCrepeType : 'normal',
    );

    final availableExtras = allowExtras ? allExtras : const <ExtraEntity>[];
    final selectedExtras = _selectedExtras(availableExtras);
    final extrasTotal = selectedExtras.fold<double>(0, (s, e) => s + e.price);

    final finalPrice = _getDiscountedPrice() + priceModifier + extrasTotal;

    final cartItem = _getCartItem(cartState, supportsCrepeType, selectedExtras);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Wilson_bg_white.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(),
              SizedBox(height: 10.h),
              Divider(color: AppColors.lightBrown.withValues(alpha: 0.5)),
              SizedBox(height: 10.h),
              ProductInfo(product: widget.product, finalPrice: finalPrice),
              SizedBox(height: 10.h),
              if (supportsCrepeType) ...[
              Divider(color: AppColors.lightBrown.withValues(alpha: 0.5)),
                SizedBox(height: 10.h),
                CrepeTypeSelector(
                  prices: prices,
                  selectedType: selectedCrepeType,
                  onTypeChanged: (type) {
                    setState(() {
                      selectedCrepeType = type;
                    });
                  },
                ),
              ],
              if (availableExtras.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Divider(color: AppColors.lightBrown.withValues(alpha: 0.5)),
                SizedBox(height: 10.h),
                ExtrasSection(
                  extras: availableExtras,
                  selectedIds: _selectedExtraIds,
                  onToggle: _toggleExtra,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: ProductBottomBar(
        cartItem: cartItem,
        cartCubit: cartCubit,
        onAdd: () {
          _addToCart(
            cartCubit: cartCubit,
            supportsCrepeType: supportsCrepeType,
            priceModifier: priceModifier,
            extras: selectedExtras,
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.lightBrown.withValues(alpha: 0.1),
      shape: Border.symmetric(
        horizontal: BorderSide(color: AppColors.primaryBrown),
      ),
      title: Text(
        widget.product.localizedName(context),
        style: TextStyle(
          color: AppColors.primaryBrown,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryBrown),
        onPressed: () {
          if (context.canPop()) {
            GoRouter.of(context).pop();
          } else {
            GoRouter.of(context).push(AppRoutes.homeScreen);
          }
        },
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.lightBrown.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ProductImage(imageUrl: widget.product.imageUrl),
        ),
      ),
    );
  }

  double _getDiscountedPrice() {
    final discount = widget.product.discountPercentage ?? 0;

    return widget.product.price * (1 - discount / 100);
  }

  double _getPriceModifier(List prices, String type) {
    for (final price in prices) {
      if (price.type == type) {
        return price.priceModifier;
      }
    }

    return 0;
  }

  CartItemModel? _getCartItem(
    CartState cartState,
    bool supportsCrepeType,
    List<ExtraEntity> extras,
  ) {
    final ids = extras.map((e) => e.id).toList()..sort();
    final key =
        '${widget.product.id}_'
        '${supportsCrepeType ? selectedCrepeType : 'none'}_'
        '${ids.join('-')}';

    for (final item in cartState.items) {
      if (item.cartItemKey == key) {
        return item;
      }
    }

    return null;
  }

  void _addToCart({
    required CartCubit cartCubit,
    required bool supportsCrepeType,
    required double priceModifier,
    required List<ExtraEntity> extras,
  }) {
    cartCubit.addProduct(
      widget.product,
      crepeType: supportsCrepeType ? selectedCrepeType : null,
      priceModifier: supportsCrepeType ? priceModifier : 0,
      extras: extras,
    );

    _showCartMessage(
      translationKey: 'product.added_to_cart_successfully',
      icon: Icons.check_circle_outline,
    );
  }

  void _showCartMessage({
    required String translationKey,
    required IconData icon,
  }) {
    final productName = widget.product.localizedName(context);

    ScaffoldMessenger.of(context)
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
                  translationKey.tr(namedArgs: {'product': productName}),
                  style: TextStyle(color: AppColors.white, fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      );
  }
}