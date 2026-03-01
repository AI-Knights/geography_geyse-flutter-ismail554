import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/font_manager.dart';

class CustomToggleButton extends StatefulWidget {
  final String option1;
  final String option2;
  final ValueChanged<String>? onChanged; // optional callback
  final String? initialSelection; // initial selected option

  const CustomToggleButton({
    super.key,
    required this.option1,
    required this.option2,
    this.onChanged,
    this.initialSelection,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  String? _selectedOption; // internal selected value

  @override
  void initState() {
    super.initState();
    // Set initial selection if provided
    if (widget.initialSelection != null) {
      _selectedOption = widget.initialSelection;
    }
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });

    // If user wants to send it to API later
    widget.onChanged?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            children: [
              _buildOption(widget.option1),
              _buildOption(widget.option2),
            ],
          ),
        ),
      ),
    );
  }

  Expanded _buildOption(String option) {
    final bool isSelected = _selectedOption == option;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectOption(option),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ?
                  // Color(0xFF4D9EFF)
                  AppColors.buttonColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          alignment: Alignment.center,
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: FontManager.regularText(),
            // TextStyle(
            //   color: isSelected ? Colors.white : Colors.black87,
            //   fontSize: 14,
            //   fontWeight: FontWeight.w600,
            //   letterSpacing: 0.5,
            // ),
          ),
        ),
      ),
    );
  }
}
