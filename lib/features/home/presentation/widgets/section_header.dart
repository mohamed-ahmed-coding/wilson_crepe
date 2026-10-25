import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool? clearButton;
  final VoidCallback? onPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onPressed,
    this.clearButton,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              if (hasSubtitle) ...[
                SizedBox(height: 3.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: AppColors.lightBrown,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (clearButton ?? false) ClearButton(onPressed: onPressed),
      ],
    );
  }
}

class ClearButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ClearButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryBrown.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primaryBrown,
              ),
              const SizedBox(width: 4),
              Text(
                'home.clear'.tr(),
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
