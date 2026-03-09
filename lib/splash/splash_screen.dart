import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_constants.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/home/homepage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Check authentication status after splash delay
    Timer(const Duration(seconds: AppConstants.splashDelay), () {
      _checkAuthAndNavigate();
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Check if refresh_token exists
    final refreshToken = await SecureStorageHelper.getRefreshToken();

    if (refreshToken != null && refreshToken.isNotEmpty) {
      // User is logged in, navigate to HomePage
      // Note: is_optional_module_selected is only checked during login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePageScreen()),
        );
      }
    } else {
      // User is not logged in, navigate to LoginScreen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBG,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.vertical,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeInDown(
                    duration: Duration(seconds: 2),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                  FadeInUp(
                    duration: Duration(seconds: 2),
                    child: Text(
                      'Geography\nGeyser',
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(
                        1.0,
                      ), // Added to prevent system scaling inconsistencies
                      style: FontManager.splashTitle().copyWith(
                        decoration: TextDecoration.none,
                      ), // Ensure no unwanted decorations
                    ),
                  ),
                  AppSpacing.h26,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
