import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/order_navigator.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/cart/cart_state.dart';
import 'package:wilson_crepe/features/home/presentation/pages/favorites_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/home_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/cart_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/orders_history_screen.dart';
import 'package:wilson_crepe/features/home/presentation/pages/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  static const _homeTab = 0;
  static const _cartTab = 2;

  int _selectedIndex = _homeTab;

  final Set<int> _visited = {_homeTab};

  void _selectTab(int index) {
    if (index == _selectedIndex) return;

    HapticFeedback.selectionClick();
    setState(() {
      _selectedIndex = index;
      _visited.add(index);
    });
  }

  late final List<Widget> _pages = [
    HomeScreen(onCartPressed: () => _selectTab(_cartTab)),
    const FavoritesScreen(),
    CartScreen(onBrowseMenu: () => _selectTab(_homeTab)),
    const OrdersHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OrderNavigator.consumePendingOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (int i = 0; i < _pages.length; i++)
            _visited.contains(i) ? _pages[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        buildWhen: (prev, curr) => prev.totalItems != curr.totalItems,
        builder: (context, cart) {
          return _GlassNavBar(
            selectedIndex: _selectedIndex,
            onSelected: _selectTab,
            items: [
              _NavItem(label: 'navigation.home'.tr(), icon: Icons.home_rounded),
              _NavItem(
                label: 'navigation.favorites'.tr(),
                icon: Icons.favorite_border,
              ),
              _NavItem(
                label: 'navigation.cart'.tr(),
                icon: Icons.shopping_cart_outlined,
                badgeCount: cart.totalItems,
              ),
              _NavItem(
                label: 'navigation.orders'.tr(),
                icon: Icons.shopping_bag_outlined,
              ),
              _NavItem(
                label: 'navigation.profile'.tr(),
                icon: Icons.person_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final int badgeCount;

  const _NavItem({
    required this.label,
    required this.icon,
    this.badgeCount = 0,
  });
}

class _GlassNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _GlassNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30.r);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 8.h),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                height: 62.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppColors.lightBrown.withValues(alpha: 0.001),
                  borderRadius: radius,
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.95),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavBarButton(
                          item: items[i],
                          selected: i == selectedIndex,
                          onTap: () => onSelected(i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryBrown : AppColors.ink;

    Widget icon = Icon(item.icon, size: 24.sp, color: color);

    if (item.badgeCount > 0) {
      icon = Badge(
        backgroundColor: AppColors.orange,
        textColor: AppColors.white,
        label: Text(item.badgeCount > 99 ? '99+' : '${item.badgeCount}'),
        child: icon,
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: item.badgeCount > 0
          ? 'navigation.accessibility_cart'.tr(
              namedArgs: {'label': item.label, 'count': '${item.badgeCount}'},
            )
          : item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.white.withValues(alpha: 0.75)
                : AppColors.white.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(26.r),
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
                width: 18.w,
                height: 3.h,
                margin: EdgeInsets.only(top: 3.h),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
              const Spacer(),
              icon,
              SizedBox(height: 2.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      height: 1.1,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
