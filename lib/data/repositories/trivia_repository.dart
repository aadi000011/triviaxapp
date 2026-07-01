import 'package:triviax/core/constant/app_constant.dart';
import '../models/question_model.dart';
import '../services/trivia_api_service.dart';

class TriviaRepository {
  final TriviaApiService _apiService;

  TriviaRepository({TriviaApiService? apiService})
      : _apiService = apiService ?? TriviaApiService();

  Future<List<QuestionModel>> getQuestions({
    required Difficulty difficulty,
    int limit = AppConstants.questionsPerQuiz,
  }) async {
    return _apiService.fetchQuestions(
      difficulty: difficulty,
      limit: limit,
    );
  }
}
