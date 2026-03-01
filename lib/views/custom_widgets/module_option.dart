import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/font_manager.dart';

class ModuleOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const ModuleOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.buttonColor.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? AppColors.buttonColor : AppColors.borderColor,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.buttonColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.buttonColor : AppColors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: AppColors.white, size: 12.sp)
                  : null,
            ),
            AppSpacing.w12,
            Text(
              text,
              style: FontManager.bodyText(
                color: AppColors.black,
               
              ),
            ),
          ],
        ),
      ),
    );
  }
}
