import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/font_manager.dart';

class CustomModule extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? shadowColor;
  final double? fontSize;
  final TextStyle? textStyle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool isSelected;

  const CustomModule({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.borderColor,
    this.shadowColor,
    this.fontSize,
    this.textStyle,
    this.leading,
    this.trailing,
    this.padding,
    this.borderRadius,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Pre-compute values to avoid recalculating in build
    final effectiveBorderRadius = borderRadius ?? 8.r;
    final effectivePadding = padding ?? EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w);
    final effectiveBackgroundColor = isSelected
        ? const Color(0xFFE8F4FF)
        : (backgroundColor ?? AppColors.white);
    final effectiveBorderColor = isSelected
        ? Colors.blueAccent
        : (borderColor ?? Colors.grey.shade300);
    final effectiveBorderWidth = isSelected ? 1.5 : 1.0;
    final effectiveShadowColor = (shadowColor ?? Colors.black).withValues(alpha: 0.1);
    final effectiveTextStyle = textStyle ??
        FontManager.headerSubtitleText(
          fontSize: fontSize ?? 20,
          color: Colors.black,
        );
    final upperText = text.toUpperCase();

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      child: Container(
        width: double.infinity,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          border: Border.all(
            color: effectiveBorderColor,
            width: effectiveBorderWidth,
          ),
          borderRadius: BorderRadius.circular(effectiveBorderRadius),
          boxShadow: [
            BoxShadow(
              color: effectiveShadowColor,
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, SizedBox(width: 8.w)],
            Flexible(
              child: Text(
                upperText,
                textAlign: TextAlign.center,
                style: effectiveTextStyle,
              ),
            ),
            if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
          ],
        ),
      ),
    );
  }
}
