import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_state.dart';
import 'package:wilson_crepe/features/auth/presentation/widgets/custom_button.dart';
import 'package:wilson_crepe/features/auth/presentation/widgets/language_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isObscure = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  Future<void> _onGoogleLoginPressed() async {
    await context.read<AuthCubit>().googleLogin();
  }

  Future<void> _changeLanguage(BuildContext context) async {
    final newLocale = context.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');

    await context.setLocale(newLocale);

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      await supabase
          .from('users')
          .update({'language': newLocale.languageCode})
          .eq('id', userId);
    } catch (e) {
      debugPrint('Failed to save user language: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Wilson_bg_white.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              _showMessage(state.message);
            } else if (state is AuthAuthenticated) {
              GoRouter.of(context).goNamed(AppRoutes.homeScreen);
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              LanguageButton(
                                onPressed: () => _changeLanguage(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/Wilson_logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'auth.welcome_back'.tr(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'auth.login_subtitle'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.lightBrown,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildTextFieldLabel('auth.email_label'.tr()),
                          const SizedBox(height: 8),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.email_label'.tr(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'error.error_email_required'.tr();
                              }
                              final emailRegex = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return 'error.error_email_invalid'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextFieldLabel('auth.password_label'.tr()),
                          const SizedBox(height: 8),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _passwordController,
                            obscureText: !_isObscure,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.password_label'.tr(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'error.error_password_required'.tr();
                              }
                              if (value.length < 6) {
                                return 'error.error_password_length'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: "auth.login_button".tr(),
                            onPressed: isLoading ? () {} : _onLoginPressed,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(color: AppColors.lightBrown),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  'auth.or_continue_with'.tr(),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.lightBrown,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.lightBrown),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                side: const BorderSide(
                                  color: AppColors.lightBrown,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: isLoading
                                  ? null
                                  : _onGoogleLoginPressed,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const FaIcon(
                                    FontAwesomeIcons.google,
                                    color: AppColors.primaryBrown,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'auth.continue_with_google'.tr(),
                                    style: const TextStyle(
                                      color: AppColors.primaryBrown,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "auth.no_account".tr(),
                                style: const TextStyle(
                                  color: AppColors.lightBrown,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  GoRouter.of(context)
                                      .goNamed(AppRoutes.signUpScreen);
                                },
                                child: Text(
                                  'auth.sign_up'.tr(),
                                  style: const TextStyle(
                                    color: AppColors.primaryBrown,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: AppColors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBrown,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFieldLabel(String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBrown,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.lightBrown, fontSize: 14),
      filled: true,
      fillColor: AppColors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBrown),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightBrown),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryBrown),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
