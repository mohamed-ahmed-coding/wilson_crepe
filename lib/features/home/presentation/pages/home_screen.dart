import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/extension/localized_product_extension.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_state.dart';
import 'package:wilson_crepe/features/home/presentation/pages/product_details_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/search_screen.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/categories_list.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/empty_products.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/error_view.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/offer_card.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/offers_carousel.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_card.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/section_header.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/store_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onCartPressed;

  const HomeScreen({super.key, this.onCartPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? _user = Supabase.instance.client.auth.currentUser;

  static const double _radius = 18;

  String get _displayName {
    final name = _user?.userMetadata?['name']?.toString().trim();
    return (name == null || name.isEmpty) ? 'home.my_friend'.tr() : name;
  }

  String? get _avatarUrl {
    final value = _user?.userMetadata?['avatar_url'];
    return (value is String && value.isNotEmpty) ? value : null;
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'home.good_morning'.tr();
    }
    if (hour >= 12 && hour < 17) {
      return 'home.good_afternoon'.tr();
    }
    if (hour >= 17 && hour < 22) {
      return 'home.good_evening'.tr();
    }
    return 'home.late_night_cravings'.tr();
  }

  List<BoxShadow> get _softShadow => [
    BoxShadow(
      color: AppColors.white.withValues(alpha: 0.10),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];

  void _openSearch() {
    final homeCubit = context.read<HomeCubit>();
    homeCubit.clearSearch();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: homeCubit, child: const SearchScreen()),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryBrown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: 'home.retry'.tr(),
          textColor: AppColors.white,
          onPressed: () {
            context.read<HomeCubit>().clearCategory();
            context.read<HomeCubit>().getHomeData();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Wilson_bg_white.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: BlocConsumer<HomeCubit, HomeState>(
            listenWhen: (previous, current) =>
                current.errorMessage != null &&
                current.errorMessage != previous.errorMessage,
            listener: (context, state) {
              if (!state.hasNoData) {
                _showError(context, state.errorMessage!);
                context.read<HomeCubit>().clearError();
              }
            },
            builder: (context, state) {
              if (state.isLoading && state.hasNoData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBrown,
                    strokeWidth: 3,
                  ),
                );
              }
              if (state.hasError && state.hasNoData) {
                return ErrorView(
                  message: (state.errorMessage ?? 'error.general_error').tr(),
                  onRetry: () => context.read<HomeCubit>().getHomeData(),
                );
              }

              final products = state.products;
              final showCategoryLoader = state.isLoading && state.isFilteringByCategory;
              final discountedProducts = products
                  .where((p) => p.discountPercentage != null && p.discountPercentage! > 0)
                  .toList();
              final hasDiscount = discountedProducts.isNotEmpty;

              return RefreshIndicator(
                color: AppColors.primaryBrown,
                backgroundColor: AppColors.white,
                onRefresh: () {
                  context.read<HomeCubit>().clearCategory();
                  context.read<HomeCubit>().getHomeData();
                  return Future.value();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(),
                          SizedBox(height: 16.h),
                          StoreCard(
                            title: 'home.wilson_crepes'.tr(),
                            description: 'home.store_hours'.tr(),
                          ),
                          SizedBox(height: 16.h),
                          _buildSearchField(),
                          SizedBox(height: 16.h),
                          if (hasDiscount)
                            OffersCarousel(
                              itemCount: discountedProducts.length,
                              itemBuilder: (context, index) {
                                final product = discountedProducts[index];
                                return OfferCard(
                                  key: ValueKey(product.id),
                                  title: product.localizedName(context),
                                  description: product.localizedDescription(context),
                                  image: product.imageUrl,
                                  discount: product.discountPercentage!.toString(),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductDetailsScreen(
                                        product: product,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          SizedBox(height: 22.h),
                          SectionHeader(
                            title: 'home.menu'.tr(),
                            subtitle: 'home.fresh_crepes_and_drinks'.tr(),
                          ),
                          SizedBox(height: 12.h),
                          CategoriesList(
                            categories: state.categories,
                            selectedCategoryId: state.selectedCategoryId,
                            onAllSelected: () => context.read<HomeCubit>().clearCategory(),
                            onCategorySelected: (categoryId) => context.read<HomeCubit>().selectCategory(categoryId),
                          ),
                          SizedBox(height: 16.h),
                        ]),
                      ),
                    ),
                    if (showCategoryLoader)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32.h),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBrown,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      )
                    else if (products.isEmpty)
                      const SliverToBoxAdapter(child: EmptyProducts())
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                        sliver: SliverList.separated(
                          itemCount: products.length,
                          separatorBuilder: (_, _) => SizedBox(height: 14.h),
                          itemBuilder: (context, index) => _FadeSlideIn(
                            key: ValueKey(products[index].id),
                            index: index,
                            child: ProductCard(product: products[index]),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildAvatar(),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightBrown,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.primaryBrown,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        _buildCartButton(),
      ],
    );
  }

  Widget _buildAvatar() {
    final url = _avatarUrl;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.orange, AppColors.primaryBrown],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: _softShadow,
      ),
      child: CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColors.white,
        backgroundImage: url != null ? NetworkImage(url) : null,
        child: url == null
            ? Text(
                _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBrown,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCartButton() {
    return BlocBuilder<CartCubit, CartState>(
      buildWhen: (prev, curr) => prev.totalItems != curr.totalItems,
      builder: (context, cart) {
        return Semantics(
          button: true,
          label: 'home.cart_items'.tr(args: ['${cart.totalItems}']),
          child: Material(
            color: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onCartPressed?.call();
              },
              child: Ink(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _softShadow,
                  border: Border.all(color: AppColors.primaryBrown),
                ),
                child: Center(
                  child: Badge(
                    isLabelVisible: cart.totalItems > 0,
                    backgroundColor: AppColors.orange,
                    label: Text('${cart.totalItems}'),
                    child: FaIcon(
                      FontAwesomeIcons.cartShopping,
                      size: 19.sp,
                      color: AppColors.primaryBrown,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Semantics(
      button: true,
      label: 'home.search_for_crepes...'.tr(),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: _openSearch,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              boxShadow: _softShadow,
              border: Border.all(color: AppColors.lightBrown),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 22.sp,
                  color: AppColors.primaryBrown,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'home.search_for_crepes...'.tr(),
                    style: TextStyle(
                      color: AppColors.lightBrown,
                      fontSize: 15.sp,
                    ),
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

class _FadeSlideIn extends StatefulWidget {
  final int index;
  final Widget child;

  const _FadeSlideIn({super.key, required this.index, required this.child});

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn>
    with SingleTickerProviderStateMixin {
  static const int _maxAnimatedItems = 6;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.index >= _maxAnimatedItems) {
      _controller.value = 1;
      return;
    }
    _timer = Timer(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
