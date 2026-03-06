import 'package:flutter/material.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/forgot_password/forgot_pass_provider.dart';
import 'package:geography_geyser/views/auth/forgot_pass/verify_screen.dart';
import 'package:geography_geyser/views/custom_widgets/buildTextField.dart';
import 'package:geography_geyser/views/custom_widgets/custom_login_button.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';
import 'package:provider/provider.dart';

///
/// this screen also refer as Reset Password screen.
///
///
class PassResetScreen extends StatefulWidget {
  const PassResetScreen({super.key});

  @override
  State<PassResetScreen> createState() => _PassResetScreenState();
}

class _PassResetScreenState extends State<PassResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: Text(
          AppStrings.resetPasswordTitle,
          style: FontManager.titleText(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AppSpacing.h56,
                  Text(
                    AppStrings.forgotYourPasswordTitle,
                    // 'Forgot your Password ?',
                    style: FontManager.boldHeading(color: AppColors.black),
                  ),
                  AppSpacing.h16,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      AppStrings.forgotPasswordInstruction,
                      style: FontManager.subtitleText(color: AppColors.black),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  AppSpacing.h18,
                  // Text(AppStrings.emailLabel, style: FontManager.bodyText()),
                  // AppSpacing.h4,
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        BuildTextField(
                          label: "Email",
                          hint: "Enter your email",
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                        AppSpacing.h14,
                        Consumer<ForgotPasswordProvider>(
                          builder: (context, forgotPasswordProvider, child) {
                            return Column(
                              children: [
                                if (forgotPasswordProvider.errorMessage != null)
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 12.0),
                                    child: Container(
                                      padding: EdgeInsets.all(12.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        border: Border.all(
                                          color: Colors.red.shade300,
                                        ),
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
                                              forgotPasswordProvider
                                                  .errorMessage!,
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
                                              forgotPasswordProvider
                                                  .clearError();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                CustomLoginButton(
                                  text: forgotPasswordProvider.isLoading
                                      ? "Sending..."
                                      : "Send",
                                  onPressed: forgotPasswordProvider.isLoading
                                      ? null
                                      : () async {
                                          final email = _emailController.text
                                              .trim();
                                          if (email.isEmpty) {
                                            CustomSnackBar.show(
                                              context,
                                              message:
                                                  'Please enter your email',
                                              isError: true,
                                            );
                                            return;
                                          }

                                          try {
                                            await forgotPasswordProvider
                                                .sendForgotPasswordRequest(
                                                  email,
                                                );

                                            if (context.mounted) {
                                              // Show success message
                                              CustomSnackBar.show(
                                                context,
                                                message:
                                                    'OTP sent successfully!',
                                              );

                                              // Navigate to verify screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VerifyScreen(
                                                        email: email,
                                                      ),
                                                ),
                                              );
                                            }
                                          } catch (e) {
                                            // Error is already handled in provider
                                            // Just show snackbar if needed
                                            if (context.mounted &&
                                                forgotPasswordProvider
                                                        .errorMessage !=
                                                    null) {
                                              CustomSnackBar.show(
                                                context,
                                                message: forgotPasswordProvider
                                                    .errorMessage!,
                                                isError: true,
                                              );
                                            }
                                          }
                                        },
                                ),
                              ],
                            );
                          },
                        ),
                        AppSpacing.h10,
                        Consumer<ForgotPasswordProvider>(
                          builder: (context, provider, child) {
                            return InkWell(
                              onTap: () {
                                // Clear token when going back
                                provider.clearPassResetToken();
                                Navigator.pop(context);
                              },
                              child: Text(
                                AppStrings.backToLogin,
                                style: FontManager.bodyText(
                                  color: AppColors.blue,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
