import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:triviax/core/constant/app_constant.dart';
import '../models/question_model.dart';

class TriviaApiService {
  Future<List<QuestionModel>> fetchQuestions({
    required Difficulty difficulty,
    int limit = AppConstants.questionsPerQuiz,
  }) async {
    final url = Uri.parse(
      '${AppConstants.triviaApiBaseUrl}/questions?limit=$limit&difficulty=${difficulty.apiValue}',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => QuestionModel.fromApiJson(json)).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
