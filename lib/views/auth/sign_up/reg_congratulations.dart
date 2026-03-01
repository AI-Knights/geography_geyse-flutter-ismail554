import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/custom_widgets/elevated_button.dart';
import 'package:geography_geyser/views/auth/login/login.dart';

class RegCongratulations_Screen extends StatefulWidget {
  const RegCongratulations_Screen({super.key});

  @override
  State<RegCongratulations_Screen> createState() =>
      _RegCongratulations_ScreenState();
}

class _RegCongratulations_ScreenState extends State<RegCongratulations_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: SafeArea(
          child: Column(
            children: [
              AppSpacing.h80,
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/icons/success.png",
                      height: 152,
                      width: 152,
                    ),
                    AppSpacing.h16,
                    Text(
                      AppStrings.congratulations,
                      style: FontManager.boldHeading(),
                    ),
                    AppSpacing.h12,
                    Text(
                      AppStrings.newPassSubtitle,
                      textAlign: TextAlign.center,
                      style: FontManager.subtitleText(fontSize: 18),
                    ),
                    AppSpacing.h18,
                    ElevatedButtonCustom(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                      text: "Go to Login",
                      backgroundColor: AppColors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
