import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/cubit/home/home_state.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.lightBrown.withValues(alpha: 0.1),
          shape: Border.symmetric(
            horizontal: BorderSide(
              color: AppColors.primaryBrown,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryBrown),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                GoRouter.of(context).goNamed(AppRoutes.homeScreen);
              }
            },
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            cursorColor: AppColors.primaryBrown,
            onChanged: (query) {
              setState(() {});
              context.read<HomeCubit>().searchProducts(query);
            },
            decoration: InputDecoration(
              hintText: 'home.search_for_crepes...'.tr(),
              hintStyle: TextStyle(color: AppColors.lightBrown, fontSize: 15.sp),
              border: InputBorder.none,
            ),
          ),
          actions: [
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, color: AppColors.primaryBrown),
                onPressed: () {
                  _searchController.clear();
                  context.read<HomeCubit>().searchProducts('');
                  setState(() {});
                },
              ),
          ],
        ),
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            final searchResults = state.searchResults;
            if (state.searchQuery.trim().isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Wilson_bg_white.png'),
                    fit: BoxFit.cover
                  )
                ),
                child: Center(
                  child: Text(
                    'home.try_something_to_search...'.tr(),
                    style: TextStyle(color: AppColors.lightBrown, fontSize: 17.sp),
                  ),
                ),
              );
            }
            if (searchResults.isEmpty) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Wilson_bg_white.png'),
                    fit: BoxFit.cover
                  )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 50.w, color: AppColors.primaryBrown),
                      SizedBox(height: 10.h),
                      Text(
                        'home.no_products_found'.tr(),
                        style: TextStyle(
                          color: AppColors.primaryBrown,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Wilson_bg_white.png'),
                  fit: BoxFit.cover
                )
            ),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: searchResults.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return ProductCard(product: searchResults[index]);
                },
              ),
            );
          },
        ),
      );
  }
}