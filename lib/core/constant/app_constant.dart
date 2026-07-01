class AppConstants {
  static const String triviaApiBaseUrl = 'https://the-trivia-api.com/api';
  
  static const int questionsPerQuiz = 10;
  static const int initialLives = 3;
  static const int pointsPerCorrectAnswer = 10;
  static const int maxCustomQuestions = 10;
  static const int optionsPerQuestion = 4;
  
  static const double celebrationThreshold = 0.7; // 70% to celebrate
}

enum Difficulty { easy, medium, hard }

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  String get apiValue => name;
}
