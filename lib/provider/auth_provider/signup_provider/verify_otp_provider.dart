import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class VerifyProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- VERIFY OTP ----------------
  static Future<Map<String, dynamic>> verifyOtp(
    String otp,
    BuildContext context,
  ) async {
    isLoading.value = true;
    debugPrint(' Verifying OTP: $otp');

    try {
      // Get verification token from SecureStorage
      final verificationToken =
          await SecureStorageHelper.getVerificationToken();

      if (verificationToken == null || verificationToken.isEmpty) {
        throw {'message': 'Verification token not found. Please signup again.'};
      }

      debugPrint(verificationToken);
      // Prepare body
      final body = {'otp': otp, 'verificationToken': verificationToken};

      // API call
      final response = await http.post(
        Uri.parse(ApiService.verifyOtpUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // Handle success
      if (response.statusCode == 200) {
        debugPrint("✅ OTP Verification Successful!");
        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP verified successfully',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP failed',
        };
      }
    } catch (e) {
      debugPrint(" Verify OTP Error: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
