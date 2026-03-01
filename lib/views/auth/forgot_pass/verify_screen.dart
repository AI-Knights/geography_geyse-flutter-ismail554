import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geography_geyser/core/app_colors.dart';
import 'package:geography_geyser/core/app_spacing.dart';
import 'package:geography_geyser/core/app_strings.dart';
import 'package:geography_geyser/core/font_manager.dart';
import 'package:geography_geyser/provider/forgot_password/forgot_pass_provider.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/views/auth/forgot_pass/new_pass.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class VerifyScreen extends StatefulWidget {
  final String? email;

  const VerifyScreen({super.key, this.email});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  int _resendTimer = 60;
  Timer? _timer;
  String? _storedEmail;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadEmailFromStorage();
  }

  Future<void> _loadEmailFromStorage() async {
    final email = await SecureStorageHelper.getResetPasswordEmail();
    if (mounted) {
      setState(() {
        _storedEmail = email;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return email;

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 3) {
      // If too small, don't mask fully — keep it safe
      return email;
    }

    // First letter
    final first = localPart[0];

    // Last two letters
    final lastTwo = localPart.substring(localPart.length - 2);

    // Middle stars
    final starsCount = localPart.length - 3; // remove first + lastTwo
    final stars = '*' * starsCount;

    final maskedLocal = '$first$stars$lastTwo';

    return '$maskedLocal@$domain';
  }

  @override
  Widget build(BuildContext context) {
    // Pinput theme configuration
    final defaultPinTheme = PinTheme(
      width: 45.w,
      height: 52.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.buttonColor, width: 1.5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.buttonColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.buttonColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Color(0xFFF3F4F6),
        border: Border.all(color: AppColors.buttonColor, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.r, right: 16.r),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Consumer<ForgotPasswordProvider>(
                    builder: (context, provider, child) {
                      return InkWell(
                        onTap: () {
                          // Clear token when going back
                          provider.clearPassResetToken();
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back_outlined,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Text(
                AppStrings.verifyAccountTitle,
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
              ),
              Text(AppStrings.almostDone),
              AppSpacing.h12,
              Padding(
                padding: EdgeInsets.all(16.0.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/security_vec.png",
                        width: 200.w,
                        height: 200.h,
                        fit: BoxFit.contain,
                      ),
                    ),

                    AppSpacing.h4,
                    Text(
                      AppStrings.verificationCodePrompt,
                      style: FontManager.bigTitle(),
                    ),
                    AppSpacing.h16,
                    Text(
                      AppStrings.verificationCodeSent,
                      style: FontManager.subtitleText(),
                    ),
                    AppSpacing.h10,
                    Text(
                      (widget.email != null && widget.email!.isNotEmpty)
                          ? _maskEmail(widget.email!)
                          : (_storedEmail != null && _storedEmail!.isNotEmpty)
                          ? _maskEmail(_storedEmail!)
                          : AppStrings.otpInstructionEmailExample,
                      style: FontManager.subSubtitleText(),
                    ),
                    AppSpacing.h32,
                    Center(
                      child: Pinput(
                        controller: _pinController,
                        focusNode: _pinFocusNode,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        pinAnimationType: PinAnimationType.fade,
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('Completed: $pin');
                        },
                        onChanged: (value) {
                          debugPrint('Changed: $value');
                        },
                        cursor: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              width: 22.w,
                              height: 1.h,
                              color: AppColors.buttonColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    AppSpacing.h24,
                    Consumer<ForgotPasswordProvider>(
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
                            // RichText(
                            //   text: TextSpan(
                            //     text: AppStrings.didntReceiveCode,
                            //     style: FontManager.bodyText(),
                            //     children: [
                            //       TextSpan(
                            //         text: ' ${AppStrings.resendOTPCode}',
                            //         style: FontManager.bodyText(
                            //           color: _resendTimer > 0
                            //               ? Colors.grey
                            //               : AppColors.buttonColor,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            AppSpacing.h10,
                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              height: 46.h,
                              child: ElevatedButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : () async {
                                        if (_pinController.text.length == 6) {
                                          try {
                                            final response = await provider
                                                .verifyForgotPasswordOtp(
                                                  _pinController.text,
                                                );

                                            if (context.mounted) {
                                              // Show success message from API or default
                                              final successMessage =
                                                  response['msg'] ??
                                                  'OTP verified successfully!';

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(successMessage),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewPass_screen(),
                                                ),
                                                (route) =>
                                                    false, // Remove all previous routes
                                              );
                                            }
                                          } catch (e) {
                                            // Error handled in provider
                                            if (context.mounted) {
                                              String errorMsg =
                                                  'OTP verification failed';

                                              if (provider.errorMessage !=
                                                  null) {
                                                errorMsg =
                                                    provider.errorMessage!;
                                              } else if (e is Map) {
                                                errorMsg =
                                                    e['msg'] ??
                                                    e['error'] ??
                                                    e['message'] ??
                                                    errorMsg;
                                              }

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(errorMsg),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Please enter 6-digit OTP',
                                              ),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                  disabledBackgroundColor: Colors.grey,
                                ),
                                child: provider.isLoading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Verify Account',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            AppSpacing.h20,
                            // Resend Code Timer/Button
                            _resendTimer > 0
                                ? Text(
                                    'Resend code in ${_resendTimer}s',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  )
                                : InkWell(
                                    onTap: provider.isLoading
                                        ? null
                                        : () async {
                                            try {
                                              final emailToUse =
                                                  widget.email ?? _storedEmail;
                                              if (emailToUse == null ||
                                                  emailToUse.isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Email not found. Please try again from start.',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                                return;
                                              }

                                              await provider
                                                  .resendForgotPasswordOtp(
                                                    emailToUse,
                                                  );
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'OTP resent successfully!',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                                // Reset timer
                                                setState(() {
                                                  _resendTimer = 60;
                                                });
                                                _startTimer();
                                              }
                                            } catch (e) {
                                              // Error handled in provider
                                            }
                                          },
                                    child: Text(
                                      'Resend OTP',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.buttonColor,
                                      ),
                                    ),
                                  ),
                          ],
                        );
                      },
                    ),

                    // Help Text
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
