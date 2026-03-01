import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/delete_xp_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class DeleteXpProvider extends ChangeNotifier {
  bool isLoading = false;
  DeleteXpModel? deleteXpData;
  String? errorMessage;

  Future<bool> deleteXp(String quizId) async {
    isLoading = true;
    errorMessage = null;
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

      final response = await http.post(
        Uri.parse(ApiService.deleteXpUrl),
        headers: headers,
        body: json.encode({'quiz_id': quizId}),
      );

      if (kDebugMode) {
        debugPrint("Delete XP API Status: ${response.statusCode}");
        debugPrint("Delete XP API Response: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        deleteXpData = DeleteXpModel.fromJson(data);
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to delete XP: ${response.statusCode}";
        if (kDebugMode) {
          debugPrint("Response body: ${response.body}");
        }
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error deleting XP: $e";
      if (kDebugMode) {
        debugPrint("Error deleting XP: $e");
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearDeleteXp() {
    deleteXpData = null;
    errorMessage = null;
    notifyListeners();
  }
}
