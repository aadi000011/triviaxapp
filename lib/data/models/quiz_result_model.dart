class QuizResultModel {
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final int score;
  final int livesRemaining;
  final bool completedAll;

  QuizResultModel({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.skippedAnswers,
    required this.score,
    required this.livesRemaining,
    required this.completedAll,
  });

  double get percentage => totalQuestions > 0 
      ? correctAnswers / totalQuestions 
      : 0;

  bool get shouldCelebrate => percentage >= 0.7;

  String get grade {
    if (percentage >= 0.9) return 'A+';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    if (percentage >= 0.5) return 'D';
    return 'F';
  }
}
