import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/action_tile.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/profile_header_card.dart';
import 'package:wilson_crepe/features/home/presentation/widgets/section_header.dart';
import 'package:wilson_crepe/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String _facebookUrl = 'https://www.facebook.com/wilsoncrepe1';

  static const String _instagramUrl = 'https://www.instagram.com/wilsoncrepe1';

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final rawName = (user?.userMetadata?['name'] as String?)?.trim();

    final displayName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : 'profile.default_name'.tr();

    final email = user?.email ?? 'profile.guest_email'.tr();
    final avatarUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Wilson_bg_white.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              SectionHeader(
                title: 'profile.title'.tr(),
                subtitle: 'profile.subtitle'.tr(),
                clearButton: false,
              ),
              SizedBox(height: 16.h),
              ProfileHeaderCard(
                name: displayName,
                email: email,
                avatarUrl: avatarUrl is String ? avatarUrl : null,
              ),
              SizedBox(height: 28.h),
              Text(
                'profile.activity'.tr(),
                style: TextStyle(
                  color: AppColors.primaryBrown,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              ActionTile(
                icon: FaIcon(FontAwesomeIcons.bagShopping),
                title: 'profile.orders_title'.tr(),
                subtitle: 'profile.orders_subtitle'.tr(),
                onTap: () {
                  context.pushNamed(AppRoutes.ordersHistoryScreen);
                },
              ),
              SizedBox(height: 12.h),
              ActionTile(
                icon: FaIcon(FontAwesomeIcons.phone),
                title: 'profile.hotline_title'.tr(),
                subtitle: 'profile.hotline_subtitle'.tr(),
                onTap: () {
                  _openLink(
                    context,
                    Uri(scheme: 'tel', path: '19484'),
                    'profile.call_error'.tr(),
                  );
                },
              ),
              SizedBox(height: 12.h),
              ActionTile(
                icon: FaIcon(FontAwesomeIcons.facebook),
                iconColor: AppColors.blue,
                containerColor: AppColors.blue.withValues(alpha: 0.2),
                title: 'profile.facebook_title'.tr(),
                subtitle: 'profile.facebook_subtitle'.tr(),
                onTap: () {
                  _openLink(
                    context,
                    Uri.parse(_facebookUrl),
                    'profile.facebook_error'.tr(),
                  );
                },
              ),
              SizedBox(height: 12.h),
              ActionTile(
                icon: FaIcon(FontAwesomeIcons.instagram),
                iconColor: const Color.fromARGB(255, 216, 77, 255),
                containerColor: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                title: 'profile.instagram_title'.tr(),
                subtitle: 'profile.instagram_subtitle'.tr(),
                onTap: () {
                  _openLink(
                    context,
                    Uri.parse(_instagramUrl),
                    'profile.instagram_error'.tr(),
                  );
                },
              ),
              SizedBox(height: 28.h),
              SizedBox(
                height: 50.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () => _showLogOutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: Text(
                    'profile.logout'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 50.h,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    foregroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () => _showDeleteAccountDialog(context),
                  icon: const Icon(Icons.delete_forever_outlined),
                  label: Text(
                    'profile.delete_account'.tr(),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (_) {
      if (context.mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.error),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'profile.logout_dialog_title'.tr(),
                style: const TextStyle(color: AppColors.primaryBrown),
              ),
            ),
          ],
        ),
        content: Text(
          'profile.logout_confirmation'.tr(),
          style: const TextStyle(color: AppColors.lightBrown),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('profile.cancel'.tr()),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.error,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await notificationsService.removeCurrentToken();
              if (!context.mounted) return;
              await context.read<AuthCubit>().signOut();
              if (!context.mounted) return;
              context.goNamed(AppRoutes.splashScreen);
            },
            child: Text('profile.logout'.tr()),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever, color: AppColors.error),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'profile.delete_account'.tr(),
                style: const TextStyle(color: AppColors.primaryBrown),
              ),
            ),
          ],
        ),
        content: Text(
          'profile.delete_account_confirmation'.tr(),
          style: const TextStyle(color: AppColors.lightBrown),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('profile.cancel'.tr()),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.white,
              backgroundColor: AppColors.error,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (!context.mounted) return;
              await _deleteAccount(context);
            },
            child: Text('profile.delete_account_confirm'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await context.read<AuthCubit>().deleteAccount();

      if (!context.mounted) return;
      router.goNamed(AppRoutes.splashScreen);
    } catch (_) {
      if (!context.mounted) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('profile.delete_account_error'.tr())),
        );
    }
  }
}
