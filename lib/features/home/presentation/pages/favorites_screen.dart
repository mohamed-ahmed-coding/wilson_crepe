import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_state.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/empty_selection.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_card.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/section_header.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
        child: BlocBuilder<HomeCubit, HomeState>(
          buildWhen: (previous, current) =>
              previous.favoriteProductIds != current.favoriteProductIds ||
              previous.products != current.products,
          builder: (context, state) {
            final favorites = state.products
                .where(
                  (product) => state.favoriteProductIds.contains(product.id),
                ).toList();

            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                SectionHeader(
                  title: 'favorites.title'.tr(),
                  subtitle: 'favorites.subtitle'.tr(),
                  clearButton: true,
                  onPressed: () {
                    context.read<HomeCubit>().clearFavorites();
                  },
                ),
                if (favorites.isEmpty) ...[
                  SizedBox(height: 150.h),
                  EmptySelection(
                    title: 'favorites.empty_title'.tr(),
                    subTitle: 'favorites.empty_subtitle'.tr(),
                    icon: Icons.favorite_border,
                    buttonTitle: 'favorites.go_to_home'.tr(),
                    onButtonPressed: () {
                      GoRouter.of(context).pushNamed(AppRoutes.homeScreen);
                    },
                  ),
                ] else ...[
                  SizedBox(height: 12.h),
                  ...favorites.map(
                    (product) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: ProductCard(product: product),
                    ),
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
