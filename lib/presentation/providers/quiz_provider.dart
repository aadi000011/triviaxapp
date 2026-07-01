import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triviax/core/constant/app_constant.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';
import 'providers.dart';

enum QuizStatus { initial, loading, ready, answering, finished, error }

class QuizState {
  final QuizStatus status;
  final List<QuestionModel> questions;
  final int currentIndex;
  final int score;
  final int lives;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final String? selectedAnswer;
  final bool showResult;
  final String? errorMessage;
  final Difficulty? difficulty;

  const QuizState({
    this.status = QuizStatus.initial,
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.lives = AppConstants.initialLives,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedAnswers = 0,
    this.selectedAnswer,
    this.showResult = false,
    this.errorMessage,
    this.difficulty,
  });

  QuizState copyWith({
    QuizStatus? status,
    List<QuestionModel>? questions,
    int? currentIndex,
    int? score,
    int? lives,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedAnswers,
    String? selectedAnswer,
    bool? showResult,
    String? errorMessage,
    Difficulty? difficulty,
  }) {
    return QuizState(
      status: status ?? this.status,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      selectedAnswer: selectedAnswer,
      showResult: showResult ?? this.showResult,
      errorMessage: errorMessage,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  QuestionModel? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  QuizResultModel get result => QuizResultModel(
        totalQuestions: questions.length,
        correctAnswers: correctAnswers,
        wrongAnswers: wrongAnswers,
        skippedAnswers: skippedAnswers,
        score: score,
        livesRemaining: lives,
        completedAll: currentIndex >= questions.length,
      );
}

class QuizNotifier extends StateNotifier<QuizState> {
  final Ref _ref;

  QuizNotifier(this._ref) : super(const QuizState());

  Future<void> startQuiz(Difficulty difficulty) async {
    state = state.copyWith(
      status: QuizStatus.loading,
      difficulty: difficulty,
    );

    try {
      final repository = _ref.read(triviaRepositoryProvider);
      final questions = await repository.getQuestions(difficulty: difficulty);

      state = QuizState(
        status: QuizStatus.ready,
        questions: questions,
        difficulty: difficulty,
      );
    } catch (e) {
      state = state.copyWith(
        status: QuizStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void selectAnswer(String answer) {
    if (state.selectedAnswer != null || state.status == QuizStatus.finished) {
      return;
    }

    final isCorrect = answer == state.currentQuestion?.correctAnswer;

    state = state.copyWith(
      selectedAnswer: answer,
      showResult: true,
      status: QuizStatus.answering,
      score: isCorrect ? state.score + AppConstants.pointsPerCorrectAnswer : state.score,
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
      wrongAnswers: !isCorrect ? state.wrongAnswers + 1 : state.wrongAnswers,
      lives: !isCorrect ? state.lives - 1 : state.lives,
    );

    if (state.lives <= 0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        state = state.copyWith(status: QuizStatus.finished);
      });
    }
  }

  void skipQuestion() {
    if (state.selectedAnswer != null) return;

    state = state.copyWith(
      skippedAnswers: state.skippedAnswers + 1,
    );

    nextQuestion();
  }

  void nextQuestion() {
    if (state.isLastQuestion || state.lives <= 0) {
      state = state.copyWith(status: QuizStatus.finished);
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedAnswer: null,
      showResult: false,
      status: QuizStatus.ready,
    );
  }

  void reset() {
    state = const QuizState();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier(ref);
});
