import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geography_geyser/models/quiz_finish_model.dart';
import 'package:geography_geyser/secure_storage/secure_storage_helper.dart';
import 'package:geography_geyser/services/api_service.dart';
import 'package:http/http.dart' as http;

class QuizFinishProvider extends ChangeNotifier {
  bool isLoading = false;
  QuizFinishModel? quizFinishData;
  String? errorMessage;
  int? attemptedQuestions; // Store attempted questions count

  Future<bool> finishQuiz(
    String quizId,
    int correctAnswers,
    int attempted,
  ) async {
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
        Uri.parse(ApiService.quizFinishUrl),
        headers: headers,
        body: json.encode({
          'quiz_id': quizId,
          'correct': correctAnswers,
          'attempted': attempted,
        }),
      );

      if (kDebugMode) {
        debugPrint("Quiz Finish API Status: ${response.statusCode}");
        debugPrint("Quiz Finish API Response: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        quizFinishData = QuizFinishModel.fromJson(data);
        attemptedQuestions = attempted; // Store attempted count
        errorMessage = null;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Failed to finish quiz: ${response.statusCode}";
        if (kDebugMode) {
          debugPrint("Response body: ${response.body}");
        }
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Error finishing quiz: $e";
      if (kDebugMode) {
        debugPrint("Error finishing quiz: $e");
      }
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearQuizFinish() {
    quizFinishData = null;
    errorMessage = null;
    attemptedQuestions = null;
    notifyListeners();
  }
}
