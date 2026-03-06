import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_spacing.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 24.sp,
            ),
            AppSpacing.w12,
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'SegoeUI',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFD32F2F) // Modern Red
            : const Color(0xFF2E7D32), // Modern Green
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.only(
          left: 20.w,
          right: 20.w,
          bottom: 30.h, // Clean floating padding above nav elements
        ),
        elevation: 8,
        duration: const Duration(
          milliseconds: 2500,
        ), // Adjusted for readability
        dismissDirection: DismissDirection.horizontal, // Easily swipe away
      ),
    );
  }
}
