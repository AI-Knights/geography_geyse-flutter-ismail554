import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignupProvider extends ChangeNotifier {
  static final ValueNotifier<bool> isLoading = ValueNotifier(false);

  // ---------------- SIGNUP ----------------
  static Future<Map<String, dynamic>> signup(
    String email,
    String fullName,
    String password,
    BuildContext context,
  ) async {
    isLoading.value = true;
    debugPrint('🔵 Trying signup with: $email / $fullName / $password');
    debugPrint('🔵 API URL: ${ApiService.signupUrl}');

    try {
      final requestBody = {
        'email': email,
        'full_name': fullName,
        'password': password,
      };

      debugPrint('🔵 Request Body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(ApiService.signupUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Request timeout. Please check your internet connection.',
              );
            },
          );

      debugPrint('🔵 Response Status Code: ${response.statusCode}');
      debugPrint('🔵 Response Headers: ${response.headers}');
      debugPrint('🔵 Response Body: ${response.body}');

      // Check if response body is empty
      if (response.body.isEmpty) {
        throw {
          'success': false,
          'message': 'Empty response from server. Please try again.',
        };
      }

      // Parse JSON response
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ JSON Parse Error: $e');
        throw {
          'success': false,
          'message': 'Invalid response from server. Please try again.',
          'error': e.toString(),
        };
      }

      // Handle successful response
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Signup successful!');
        await _storeSignupData(responseData);
        return responseData;
      } else {
        // Handle error response
        final errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            'Signup failed. Please try again.';
        throw {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
          'data': responseData,
        };
      }
    } on SocketException catch (e) {
      debugPrint('❌ Network Error (SocketException): $e');
      throw {
        'success': false,
        'message':
            'No internet connection. Please check your network and try again.',
        'error': e.toString(),
      };
    } on HttpException catch (e) {
      debugPrint('❌ HTTP Error: $e');
      throw {
        'success': false,
        'message': 'HTTP error occurred. Please try again.',
        'error': e.toString(),
      };
    } on TimeoutException catch (e) {
      debugPrint('❌ Timeout Error: $e');
      throw {
        'success': false,
        'message':
            'Request timeout. Please check your internet connection and try again.',
        'error': e.toString(),
      };
    } on FormatException catch (e) {
      debugPrint('❌ Format Error: $e');
      throw {
        'success': false,
        'message': 'Invalid response format. Please try again.',
        'error': e.toString(),
      };
    } catch (e) {
      debugPrint('❌ Signup Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');

      // If it's already a Map (from our error handling), rethrow it
      if (e is Map<String, dynamic>) {
        rethrow;
      }

      // Otherwise, wrap it in a Map
      throw {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
        'error': e.toString(),
      };
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- STORE SIGNUP DATA ----------------
  static Future<void> _storeSignupData(Map<String, dynamic> data) async {
    // 🧠 Save verification token securely (for OTP verify)
    if (data.containsKey('verificationToken')) {
      await SecureStorageHelper.setVerificationToken(data['verificationToken']);
      debugPrint("✅ Verification Token Saved Securely!");
    }

    // 🧠 Optional: save email and user id for later use
    final prefs = await SharedPreferences.getInstance();
    if (data['user'] != null) {
      await prefs.setString('signup_user_id', data['user']['id'] ?? '');
      await prefs.setString('signup_email', data['user']['email'] ?? '');
    }
  }

  // ---------------- PRINT ALL DATA (DEBUG) ----------------
  static Future<void> printAllStorageData() async {
    final secure = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    debugPrint("========== 🧠 Signup Storage Data ==========");
    debugPrint("🔐 Secure Storage:");
    (await secure.readAll()).forEach((k, v) => debugPrint("  $k : $v"));

    debugPrint("📦 Shared Preferences:");
    prefs.getKeys().forEach((k) => debugPrint("  $k : ${prefs.get(k)}"));
    debugPrint("===========================================");
  }
}
