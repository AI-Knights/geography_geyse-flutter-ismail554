import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_logger.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/forget_pass_screen.dart';
import 'package:geography_geyser/views/auth/sign_up/geo_sign_up.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/google_login_btn.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBG,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppSpacing.h80,

                  // Logo & Title
                  Column(
                    children: [
                      Container(
                        // margin: EdgeInsets.only(bottom: 18.h),
                        width: 100.w,
                        height: 100.h,

                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                          // border: Border.all(
                          //   color: const Color(0xFF4CAF50),
                          //   width: 4,
                          // ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        AppStrings.appName,

                        style: FontManager.splashTitle(fontSize: 24.sp),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.h24,
                    ],
                  ),
                  AppSpacing.h10,

                  // Login Form Section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.80,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(130.r),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 30.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.logInButton,
                          // 'Login',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        AppSpacing.h20,

                        // Email Field
                        BuildTextField(
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailPlaceholder,
                          textInputAction: TextInputAction.next,
                          controller: emailController,
                        ),
                        AppSpacing.h16,

                        // Password Field
                        BuildTextField(
                          label: AppStrings.passwordLabel,
                          hint: AppStrings.passwordPlaceholder,
                          controller: passwordController,
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xFF42A5F5),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        AppSpacing.h4,

                        // Forgot Password
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PassResetScreen(),
                                ),
                              );
                            },
                            child: Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF42A5F5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.h20,

                        // Login Button
                        CustomLoginButton(
                          text: AppStrings.logInTitle,
                          isLoading: _isLoading,
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text;

                                  if (email.isEmpty || password.isEmpty) {
                                    CustomSnackBar.show(
                                      context,
                                      message:
                                          'Please enter email and password',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final response = await LoginProvider.login(
                                      email,
                                      password,
                                    );

                                    if (!context.mounted) return;

                                    CustomSnackBar.show(
                                      context,
                                      message: 'Welcome to the app',
                                      isError: false,
                                    );

                                    // Check is_optional_module_selected from login response
                                    final isOptionalModuleSelected =
                                        response['is_optional_module_selected'] ==
                                            true ||
                                        response['is_optional_module_selected'] ==
                                            'true';

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => isOptionalModuleSelected
                                            ? HomePageScreen()
                                            : OptionalModuleSettings(
                                                isFirstLogin: true,
                                              ),
                                      ),
                                    );
                                  } catch (e) {
                                    String message =
                                        'Invalid email or password.';
                                    if (e is Map && e['message'] != null) {
                                      message = e['message'].toString();
                                    }
                                    if (context.mounted) {
                                      CustomSnackBar.show(
                                        context,
                                        message: AppLogger.getSafeErrorMessage(
                                          message,
                                        ),
                                        isError: true,
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                        ),
                        AppSpacing.h20,

                        // OR Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                AppStrings.orLoginWith,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey[300],
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h20,

                        // Google login
                        GoogleLoginBtn(),
                        AppSpacing.h16,

                        // Create Account
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: AppStrings.noAccountPrefix,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.subtitleText,
                                //  Colors.grey[600],
                              ),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const GeoSignUpScreen(),
                                        ),
                                      );
                                    },
                                  text: ' ${AppStrings.createAccountTitle}',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        AppSpacing.h24,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
