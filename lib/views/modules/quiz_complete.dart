import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/views/modules/quiz_screen.dart';

///
///
/// This screen is not under in use.
/// Currently using quiz_result.dart as a quiz_complete
///
///

class QuizCompleteScreen extends StatefulWidget {
  const QuizCompleteScreen({super.key});

  @override
  State<QuizCompleteScreen> createState() => _QuizCompleteScreenState();
}

class _QuizCompleteScreenState extends State<QuizCompleteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              AppSpacing.h36,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppSpacing.h20,
                      Text(
                        AppStrings.quizCompleteTitle,
                        style: FontManager.boldHeading(fontSize: 32.sp),
                      ),
                      AppSpacing.h32,

                      // ✅ Stats Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  CustomRWblock(
                                    value: 2,
                                    valueColor: AppColors.green,
                                    label: 'Correct',
                                  ),
                                  CustomRWblock(
                                    value: 2,
                                    valueColor: AppColors.red,
                                    label: 'Wrong',
                                  ),
                                ],
                              ),
                              AppSpacing.h16,
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(26.r),
                                  color: AppColors.green,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.one_x_mobiledata_sharp,
                                      color: Colors.yellowAccent,
                                      size: 30.r,
                                    ),
                                    Text(
                                      'XP Gained',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '+200',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      AppSpacing.h20,
                      CustomMarkCard(
                        iconData: Icons.grade,
                        iconColor: Colors.white,
                        iconBg: Colors.orange,
                        label: "Final Grade",
                        value: "A+",
                        valueColor: Colors.green,
                        valueInt: 95,
                      ),
                      AppSpacing.h12,
                      CustomMarkCard(
                        iconData: Icons.score,
                        iconColor: Colors.white,
                        iconBg: Colors.lightGreen,
                        label: "Final Score",
                        value: "80",
                        valueColor: Colors.green,
                        valueInt: 95,
                      ),
                      AppSpacing.h40,
                    ],
                  ),
                ),
              ),

              /// ✅ Fixed bottom buttons
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.red,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          "Retry Quiz",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    AppSpacing.w16,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Text(
                          "Next Module",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class CustomMarkCard extends StatelessWidget {
  final IconData iconData;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final int valueInt;
  final Color iconBg;

  const CustomMarkCard({
    super.key,
    required this.iconData,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueInt,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        child: Row(
          children: [
            // ✅ Icon Section
            CircleAvatar(
              radius: 26.r,
              backgroundColor: iconBg,
              child: Icon(iconData, color: iconColor, size: 28.r),
            ),

            AppSpacing.w12,

            // ✅ Label Section
            Expanded(
              child: Text(
                label,
                style: FontManager.bigTitle().copyWith(
                  fontSize: 16.sp,
                  color: Colors.black87,
                ),
              ),
            ),

            // ✅ Value Section
            Text(
              value,
              style: FontManager.boldHeading(
                fontSize: 22.sp,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRWblock extends StatelessWidget {
  final int value;
  final Color valueColor;
  final String label;

  const CustomRWblock({
    super.key,
    required this.value,
    required this.valueColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22, //
          backgroundColor: valueColor, //
          child: Text(
            '$value',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        AppSpacing.h4,
        Text(
          label,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
