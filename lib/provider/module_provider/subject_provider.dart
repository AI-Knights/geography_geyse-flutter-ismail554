import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart'; // <-- for compute
import 'package:geography_geyser/models/module_model.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:http/http.dart' as http;

class SubjectProvider extends ChangeNotifier {
  List<ModuleModel> _subjects = [];
  List<ModuleModel> get subjects => _subjects;

  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Check if cached data is still valid
  bool get _hasValidCache {
    if (_subjects.isEmpty) return false;
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  Future<void> fetchSubjects({bool forceRefresh = false}) async {
    // Return early if already loading
    if (_isLoading) return;

    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _hasValidCache) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    // Only notify once at the start
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();

      // ✅ Fix: Create mutable map properly
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final url = Uri.parse(ApiService.moduleListUrl);

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      debugPrint("Status: ${response.statusCode}");

      List<ModuleModel> newSubjects = [];
      String? newErrorMessage;

      if (response.statusCode == 200) {
        // 🔥 Heavy parsing moved to background
        newSubjects = await compute(parseModules, response.body);

        if (newSubjects.isEmpty) {
          newErrorMessage = "No modules available at this moment.";
        } else {
          newErrorMessage = null;
        }
      } else if (response.statusCode == 401) {
        newErrorMessage = "Authentication failed. Please login again.";
      } else if (response.statusCode >= 500) {
        newErrorMessage = "Server error. Please try again later.";
      } else {
        newErrorMessage = "Server Error: ${response.statusCode}";
      }

      // ✅ Only update and notify if data actually changed
      final hasChanged =
          !_listEquals(_subjects, newSubjects) ||
          _errorMessage != newErrorMessage;

      if (hasChanged) {
        _subjects = newSubjects;
        _errorMessage = newErrorMessage;
        _lastFetchTime = DateTime.now();
        notifyListeners();
      } else {
        _lastFetchTime = DateTime.now();
      }
    } on SocketException {
      if (_subjects.isEmpty ||
          _errorMessage !=
              "No Internet! Please check your network and try again.") {
        _subjects = [];
        _errorMessage = "No Internet! Please check your network and try again.";
        notifyListeners();
      }
    } on TimeoutException {
      if (_subjects.isEmpty ||
          _errorMessage != "Server not responding. Try again!") {
        _subjects = [];
        _errorMessage = "Server not responding. Try again!";
        notifyListeners();
      }
    } catch (e) {
      if (_subjects.isEmpty ||
          _errorMessage != "Something went wrong: ${e.toString()}") {
        _subjects = [];
        _errorMessage = "Something went wrong: ${e.toString()}";
        notifyListeners();
      }
    } finally {
      final wasLoading = _isLoading;
      _isLoading = false;
      // Only notify if loading state changed and we haven't already notified
      if (wasLoading) {
        notifyListeners();
      }
    }
  }

  /// Helper to compare lists efficiently
  bool _listEquals(List<ModuleModel> a, List<ModuleModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].moduleName != b[i].moduleName) {
        return false;
      }
    }
    return true;
  }

  Future<void> refreshSubjects() async {
    await fetchSubjects(forceRefresh: true);
  }
}

// TOP-LEVEL FUNCTION (Compute needs this)
List<ModuleModel> parseModules(String responseBody) {
  final data = json.decode(responseBody);

  final results = data["results"] as List;

  return results.map((e) => ModuleModel.fromJson(e)).toList();
}
