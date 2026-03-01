import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';

class TimeoutDialog extends StatelessWidget {
  final VoidCallback onOkPressed;

  const TimeoutDialog({super.key, required this.onOkPressed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clock Icon
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: Colors.red,
              size: 32.sp,
            ),
          ),

          AppSpacing.h20,

          // Title
          Text(
            AppStrings.timeUp,
            style: FontManager.bigTitle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          AppSpacing.h12,

          // Description
          Text(
            AppStrings.timeUpwarning,
            style: FontManager.subtitleText(),
            textAlign: TextAlign.center,
          ),

          AppSpacing.h24,

          // Ok Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onOkPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4A90E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                elevation: 0,
              ),
              child: Text('OK', style: FontManager.buttonText()),
            ),
          ),
        ],
      ),
    );
  }

  // Static method to show the dialog

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onOkPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TimeoutDialog(onOkPressed: onOkPressed);
      },
    );
  }
}
