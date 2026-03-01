import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/font_manager.dart';


class ModuleSelectionRow extends StatelessWidget {
  final String leftOption;
  final String rightOption;
  final bool isLeftSelected;
  final bool isRightSelected;
  final Function(bool isLeft) onSelectionChanged;

  const ModuleSelectionRow({
    super.key,
    required this.leftOption,
    required this.rightOption,
    required this.isLeftSelected,
    required this.isRightSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Option
        Expanded(
          child: buildModuleOption(
            text: leftOption,
            isSelected: isLeftSelected,
            onTap: () => onSelectionChanged(true),
          ),
        ),

        // OR Separator
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Text('OR', style: FontManager.bodyText(color: Colors.black)),
        ),

        // Right Option
        Expanded(
          child: buildModuleOption(
            text: rightOption,
            isSelected: isRightSelected,
            onTap: () => onSelectionChanged(false),
          ),
        ),
      ],
    );
  }

  Widget buildModuleOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    bool shouldAnimate = text.length > 11; // 👈 condition

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
            // Circle Indicator
            Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.buttonColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.buttonColor : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 12.sp)
                  : null,
            ),
            AppSpacing.w4,

            // Text (Marquee if long)
            Expanded(
              child:
                  //  shouldAnimate
                  //     ? SizedBox(
                  //         height: 20.h,
                  //         child: Marquee(
                  //           text: text,
                  //           style: FontManager.bodyText(
                  //             color: Colors.black,
                  //           ).copyWith(fontSize: 14.sp),
                  //           scrollAxis: Axis.horizontal,
                  //           blankSpace: 40.w,
                  //           velocity: 40.0,
                  //           pauseAfterRound: const Duration(seconds: 1),
                  //           startPadding: 10.0,
                  //           accelerationDuration: const Duration(seconds: 1),
                  //           accelerationCurve: Curves.linear,
                  //           decelerationDuration: const Duration(milliseconds: 500),
                  //           decelerationCurve: Curves.easeOut,
                  //         ),
                  //       )
                  // :
                  Text(
                    text,
                    style: FontManager.bodyText(
                      color: AppColors.black,
                    ).copyWith(fontSize: 14.sp),
                    overflow: TextOverflow.visible,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
