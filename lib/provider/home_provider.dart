import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geography_geyser/models/home_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/services/https_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  HomeModel? _userModel;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();
  static const _storageKey = 'user_profile_data';

  HomeModel? get userModel => _userModel;
  bool get isLoading => _isLoading;

  Future<void> fetchUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();

      final headers = <String, String>{'ngrok-skip-browser-warning': 'true'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final getProfile = ApiService.getProfile;
      final response = await HttpManager.apiRequest(
        url: getProfile,
        method: Method.get,
        headers: headers,
        name: 'GetProfile',
        statusCode: 200,
      );

      response.fold(
        (error) {
          debugPrint('Failed to load user: $error');
        },
        (data) async {
          final decodedData = jsonDecode(data);

          if (decodedData is Map<String, dynamic>) {
            Map<String, dynamic> profileData;

            if (decodedData.containsKey('data') &&
                decodedData['data'] is Map<String, dynamic>) {
              profileData = decodedData['data'] as Map<String, dynamic>;
            } else {
              profileData = decodedData;
            }

            _userModel = HomeModel.fromJson(profileData);

            await _storage.write(
              key: _storageKey,
              value: jsonEncode(profileData),
            );
            debugPrint('User profile saved to secure storage');
          }
        },
      );
    } catch (e) {
      debugPrint('Error fetching user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserDataFromStorage() async {
    try {
      final storedData = await _storage.read(key: _storageKey);

      if (storedData != null) {
        final data = json.decode(storedData);
        _userModel = HomeModel.fromJson(data);
        debugPrint('Loaded user profile from secure storage');
        notifyListeners();
      } else {
        debugPrint('No stored user profile found');
      }
    } catch (e) {
      debugPrint('Error reading user profile from storage: $e');
    }
  }

  Future<void> clearUserData() async {
    await _storage.delete(key: _storageKey);
    _userModel = null;
    notifyListeners();
  }
}
