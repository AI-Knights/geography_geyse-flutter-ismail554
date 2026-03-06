import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/delete_account.dart';
import 'package:geography_geyser/provider/auth_provider/login_provider.dart';
import 'package:geography_geyser/provider/home_provider.dart';
import 'package:geography_geyser/provider/userstats_provider.dart';
import 'package:geography_geyser/provider/user_performance_provider.dart';
import 'package:geography_geyser/provider/settings_provider/optional_module_provider.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/views/auth/login/login.dart';
import 'package:geography_geyser/views/profile/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:geography_geyser/views/custom_widgets/custom_snackbar.dart';

class AccountDeleteProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> deleteAccount(String password, BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final url = Uri.parse(ApiService.deleteAccount);

    // Create the request model
    final requestBody = DeleteAccountRequest(password: password);

    try {
      // token from SharedPreferences or SecureStorage
      final token = await SecureStorageHelper.getToken();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (!context.mounted) return false;

        // Success - Clear all provider data before logout
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final statsProvider = Provider.of<UserStatsProvider>(
          context,
          listen: false,
        );
        final performanceProvider = Provider.of<ProfileProvider>(
          context,
          listen: false,
        );
        final optionalModuleProvider = Provider.of<OptionalModuleProvider>(
          context,
          listen: false,
        );

        // Clear all provider data
        await Future.wait([
          userProvider.clearUserData(),
          statsProvider.clearUserStats(),
          performanceProvider.clearProfileData(),
        ]);

        // Clear optional module provider (synchronous)
        optionalModuleProvider.clearModulePairs();

        // Reset initialization flag so new user data loads properly
        ProfileScreen.resetInitialization();

        // Clear secure storage and other auth data
        await LoginProvider.logout();

        if (context.mounted) {
          CustomSnackBar.show(context, message: "Account deleted successfully");
          // Navigate to Login or Splash screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
        return true;
      } else {
        // Handle API errors (e.g., wrong password)
        final errorData = jsonDecode(response.body);
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: errorData['message'] ?? "Check your password",
            isError: true,
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(context, message: "Error: $e", isError: true);
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
