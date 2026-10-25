import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;

  const ProductImage({super.key, required this.imageUrl});

  Widget _errorIcon() => Icon(Icons.broken_image_outlined, size: 120.sp);

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return Icon(Icons.image_not_supported_outlined, size: 120.sp);
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final screenWidth = MediaQuery.sizeOf(context).width;

      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200.h,
        memCacheWidth: (screenWidth * dpr).round(),
        placeholder: (_, _) => SizedBox(height: 200.h),
        errorWidget: (_, _, _) => _errorIcon(),
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _errorIcon(),
    );
  }
}
