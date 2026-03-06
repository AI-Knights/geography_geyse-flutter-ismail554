import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:geography_geyser/views/home/op_mod_settings.dart';

class GoogleLoginBtn extends StatefulWidget {
  const GoogleLoginBtn({super.key});

  @override
  State<GoogleLoginBtn> createState() => _GoogleLoginBtnState();
}

class _GoogleLoginBtnState extends State<GoogleLoginBtn> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final response = await LoginProvider.signInWithGoogle();

                  if (!context.mounted) return;

                  // Check is_optional_module_selected from login response
                  final isOptionalModuleSelected =
                      response['is_optional_module_selected'] == true ||
                      response['is_optional_module_selected'] == 'true';

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => isOptionalModuleSelected
                          ? HomePageScreen()
                          : OptionalModuleSettings(isFirstLogin: true),
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  String message = 'Google sign-in failed';
                  if (e is Map && e['message'] != null) {
                    message = e['message'].toString();
                  }
                  CustomSnackBar.show(context, message: message, isError: true);
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[400]!, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google_logo.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                  AppSpacing.w8,
                  Text(
                    // 'Google',
                    AppStrings.googleLogin,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
