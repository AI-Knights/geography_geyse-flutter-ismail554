import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/quiz_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class QuizProvider extends ChangeNotifier {
  bool isLoading = false;
  QuizModel? quizData;
  String? errorMessage;

  Future<void> fetchQuiz(String moduleId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await SecureStorageHelper.getToken();
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'ngrok-skip-browser-warning': 'true', // Required for ngrok
      };

      // Add auth token if available
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse(ApiService.quizStartUrl),
        headers: headers,
        body: json.encode({'module_id': moduleId}),
      );

      if (kDebugMode) {
        debugPrint("Quiz API Status: ${response.statusCode}");
        debugPrint("Quiz API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        quizData = QuizModel.fromJson(data);
        errorMessage = null;
      } else {
        errorMessage = "There is an error. Try agian ${response.statusCode}";
        if (kDebugMode) {
          debugPrint("Response body: ${response.body}");
        }
      }
    } catch (e) {
      // errorMessage = "Error fetching quiz: $e";
      errorMessage = "There is an error. Try agian";
      if (kDebugMode) {
        debugPrint("Error fetching quiz: $e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch synoptic quiz using synoptic API endpoint
  Future<void> fetchSynopticQuiz() async {
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
        Uri.parse(ApiService.synopticQuizStartUrl),
        headers: headers,
        body: json.encode({}), // Synoptic quiz doesn't need module_id
      );

      if (kDebugMode) {
        debugPrint("Synoptic Quiz API Status: ${response.statusCode}");
        debugPrint("Synoptic Quiz API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        quizData = QuizModel.fromJson(data);
        errorMessage = null;
      } else {
        errorMessage = "Failed to fetch synoptic quiz: ${response.statusCode}";
        if (kDebugMode) {
          debugPrint("Response body: ${response.body}");
        }
      }
    } catch (e) {
      errorMessage = "Error fetching synoptic quiz: $e";
      if (kDebugMode) {
        debugPrint("Error fetching synoptic quiz: $e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearQuiz() {
    quizData = null;
    errorMessage = null;
    notifyListeners();
  }
}
