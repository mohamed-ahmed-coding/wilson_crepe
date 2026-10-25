import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String discount;
  final String image;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.title,
    required this.description,
    required this.discount,
    required this.image,
    required this.onTap,
  });

  String get _discountLabel {
    final value = double.tryParse(discount);
    if (value == null) return discount;
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190.h,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightBrown, width: 1.5.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'offer.title'.tr(),
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      const FaIcon(
                        FontAwesomeIcons.fire,
                        color: AppColors.green,
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primaryBrown,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.primaryBrown.withValues(alpha: 0.8),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrown,
                      foregroundColor: AppColors.white,
                      minimumSize: Size(0, 36.h),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    onPressed: onTap,
                    child: Text(
                      'offer.order_now'.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            SizedBox(
              width: 120.w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: _buildProductImage(context, image),
                  ),
                  PositionedDirectional(
                    top: 6.h,
                    end: 6.w,
                    child: CircleAvatar(
                      backgroundColor: AppColors.primaryBrown,
                      radius: 18.r,
                      child: Text(
                        '%$_discountLabel',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    final cacheW = (116.w * dpr).round();

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: cacheW,
        maxWidthDiskCache: cacheW,
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
      cacheWidth: cacheW,
      errorBuilder: (_, _, _) => placeholder(Icons.broken_image_outlined),
    );
  }