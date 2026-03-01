import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/select_time_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class SelectTimeProvider extends ChangeNotifier {
  bool isLoading = false;
  List<SelectTimeModel> timeList = [];

  Future<void> fetchSelectTimes() async {
    isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Required for ngrok
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse(ApiService.timeListUrl),
        headers: headers,
      );

      if (kDebugMode) {
        debugPrint("Time List API Status: ${response.statusCode}");
        debugPrint("Time List API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parsed = SelectTimeResponse.fromJson(data);
        timeList = parsed.results;
      } else {
        if (kDebugMode) {
          debugPrint("Failed to fetch: ${response.statusCode}");
          debugPrint("Response body: ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error fetching select times: $e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
