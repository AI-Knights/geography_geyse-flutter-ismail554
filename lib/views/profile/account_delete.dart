import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/settings_provider/account_delete_provider.dart';

import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class AccountDelete extends StatefulWidget {
  const AccountDelete({super.key});

  @override
  State<AccountDelete> createState() => _AccountDeleteState();
}

class _AccountDeleteState extends State<AccountDelete> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessing the specific AccountDeleteProvider
    final accountDeleteProvider = Provider.of<AccountDeleteProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text("Account Deletion", style: FontManager.titleText()),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  AppStrings.accountdeleteDescription,
                  style: FontManager.subtitleText(spacing: 0.2, height: 1.5),
                ),
                AppSpacing.h20,
                BuildTextField(
                  controller: _passwordController,
                  label: AppStrings.enterPass,
                  hint: "*******".toString(),
                  obscureText: true, // Added based on your request
                ),
                AppSpacing.h8,
                Text(AppStrings.deletePassWar, style: FontManager.alertText()),
                AppSpacing.h32,

                // Using the specific provider's loading state
                accountDeleteProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.red),
                      )
                    : CustomLoginButton(
                        text: "Delete Account",
                        backgroundColor: AppColors.red,
                        onPressed: () {
                          if (_passwordController.text.isNotEmpty) {
                            showAccountDelete(
                              context,
                              _passwordController.text,
                            );
                          } else {
                            CustomSnackBar.show(
                              context,
                              message: "Please enter your password",
                              isError: true,
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showAccountDelete(BuildContext context, String password) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          AppStrings.areYouSureTitle,
          style: FontManager.bigTitle(),
          textAlign: TextAlign.center,
        ),
        content: Text(
          AppStrings.accountDeleteHint,
          style: FontManager.bodyText(),
          textAlign: TextAlign.center,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.cancelButton,
                    style: FontManager.buttonText().copyWith(
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
              AppSpacing.w12,
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Close dialog

                    // Call the delete function on the AccountDeleteProvider
                    // using the context passed from the parent widget
                    await Provider.of<AccountDeleteProvider>(
                      context,
                      listen: false,
                    ).deleteAccount(password, context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: FontManager.buttonText(),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
