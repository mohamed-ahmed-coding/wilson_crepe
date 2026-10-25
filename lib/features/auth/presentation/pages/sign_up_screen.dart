import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:wilson_crepe/core/constants/app_colors.dart';
import 'package:wilson_crepe/core/routes/app_routes.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wilson_crepe/features/auth/presentation/cubit/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscurePassword = false;
  bool _isObscureConfirmPassword = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onGoogleLoginPressed() async {
    await context.read<AuthCubit>().googleLogin();
  }

  Future<void> _onSignUpPressed() async {
    if (_formKey.currentState!.validate()) {
      await context.read<AuthCubit>().register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        name: _fullNameController.text.trim(),
      );
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
              _showSuccessMessage('auth.account_created_success'.tr());
              GoRouter.of(context).goNamed(AppRoutes.loginScreen);
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
                          const SizedBox(height: 10),
                          ClipOval(
                            child: Image.asset(
                              'assets/images/Wilson_logo.png',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'auth.create_account'.tr(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'auth.signup_subtitle'.tr(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.lightBrown,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextFieldLabel('auth.full_name_label'.tr()),
                          const SizedBox(height: 6),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _fullNameController,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.full_name_label'.tr(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'error.error_name_required'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextFieldLabel('auth.phone_number_label'.tr()),
                          const SizedBox(height: 6),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.phone_number_label'.tr(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'error.error_phone_required'.tr();
                              }
                              if (value.length != 11) {
                                return 'error.error_phone_length'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextFieldLabel('auth.email_label'.tr()),
                          const SizedBox(height: 6),
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
                          const SizedBox(height: 14),
                          _buildTextFieldLabel('auth.password_label'.tr()),
                          const SizedBox(height: 6),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _passwordController,
                            obscureText: _isObscurePassword,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.password_label'.tr(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscurePassword = !_isObscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _isObscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
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
                          const SizedBox(height: 14),
                          _buildTextFieldLabel(
                            'auth.confirm_password_label'.tr(),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            cursorColor: AppColors.primaryBrown,
                            controller: _confirmPasswordController,
                            obscureText: _isObscureConfirmPassword,
                            style: const TextStyle(color: AppColors.black),
                            decoration: _inputDecoration(
                              'auth.confirm_password_label'.tr(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscureConfirmPassword =
                                        !_isObscureConfirmPassword;
                                  });
                                },
                                icon: Icon(
                                  _isObscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'error.error_confirm_password'.tr();
                              }
                              if (value != _passwordController.text) {
                                return 'error.error_passwords_match'.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: isLoading ? null : _onSignUpPressed,
                              child: Text(
                                'auth.signup_button'.tr(),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                  'auth.or_signup_with'.tr(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.lightBrown,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(color: AppColors.lightBrown),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
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
                                    'auth.signup_with_google'.tr(),
                                    style: const TextStyle(
                                      color: AppColors.primaryBrown,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "auth.have_account".tr(),
                                style: const TextStyle(
                                  color: AppColors.lightBrown,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  GoRouter.of(context).goNamed(AppRoutes.loginScreen);
                                },
                                child: Text(
                                  'auth.login_button'.tr(),
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
          fontSize: 11,
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
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
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
