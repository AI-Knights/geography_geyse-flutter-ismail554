import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/forgot_password/new_pass_set_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/congratulations.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

class NewPass_screen extends StatefulWidget {
  const NewPass_screen({super.key});

  @override
  State<NewPass_screen> createState() => _NewPass_screenState();
}

class _NewPass_screenState extends State<NewPass_screen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;

      if (_newPasswordController.text.isEmpty) {
        _passwordError = 'Please enter a new password';
      } else if (_newPasswordController.text.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = 'Please confirm your password';
      } else if (_newPasswordController.text !=
          _confirmPasswordController.text) {
        _confirmPasswordError = 'Passwords do not match';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor.withOpacity(01),
        title: Text("Back", style: FontManager.appBarText()),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppSpacing.h24,
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppStrings.createPassword,
                    style: FontManager.boldHeading(color: Colors.blue),
                  ),
                ),
                AppSpacing.h24,
                BuildTextField(
                  label: AppStrings.newPassword,
                  hint: AppStrings.passHint,
                  controller: _newPasswordController,
                  isPassword: true,
                  obscureText: _obscureNewPassword,
                  textInputAction: TextInputAction.next,
                  errorText: _passwordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF42A5F5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  onChanged: (value) {
                    _validatePasswords();
                  },
                ),
                AppSpacing.h20,
                BuildTextField(
                  label: AppStrings.confirmNewPassword,
                  hint: AppStrings.confirmNewHint,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  errorText: _confirmPasswordError,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF42A5F5),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  onChanged: (value) {
                    _validatePasswords();
                  },
                ),
                AppSpacing.h24,
                Consumer<NewPassSetProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      children: [
                        if (provider.errorMessage != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.red.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      provider.errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 18),
                                    color: Colors.red,
                                    onPressed: () {
                                      provider.clearError();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        CustomLoginButton(
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  _validatePasswords();

                                  if (_passwordError != null ||
                                      _confirmPasswordError != null) {
                                    CustomSnackBar.show(
                                      context,
                                      message: 'Please fix the errors above',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  try {
                                    final response = await provider
                                        .setNewPassword(
                                          _newPasswordController.text.trim(),
                                        );

                                    if (context.mounted) {
                                      // Show success message from API or default
                                      final successMessage =
                                          response['msg'] ??
                                          'Password reset successfully!';

                                      CustomSnackBar.show(
                                        context,
                                        message: successMessage,
                                      );

                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CongratulationsScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } catch (e) {
                                    // Error handled in provider
                                    if (context.mounted) {
                                      String errorMsg =
                                          'Failed to reset password';

                                      if (provider.errorMessage != null) {
                                        errorMsg = provider.errorMessage!;
                                      } else if (e is Map) {
                                        errorMsg =
                                            e['msg'] ??
                                            e['error'] ??
                                            e['message'] ??
                                            errorMsg;
                                      }

                                      CustomSnackBar.show(
                                        context,
                                        message: errorMsg,
                                        isError: true,
                                      );
                                    }
                                  }
                                },
                          text: provider.isLoading
                              ? 'Saving...'
                              : AppStrings.saveButton,
                        ),
                      ],
                    );
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
