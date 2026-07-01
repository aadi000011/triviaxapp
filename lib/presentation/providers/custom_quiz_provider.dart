import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triviax/core/constant/app_constant.dart';
import '../../data/models/question_model.dart';
import '../../data/models/quiz_result_model.dart';

class CustomQuizState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final int score;
  final int lives;
  final int correctAnswers;
  final int wrongAnswers;
  final int skippedAnswers;
  final String? selectedAnswer;
  final bool showResult;
  final bool isPlaying;
  final bool isFinished;

  const CustomQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.score = 0,
    this.lives = AppConstants.initialLives,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.skippedAnswers = 0,
    this.selectedAnswer,
    this.showResult = false,
    this.isPlaying = false,
    this.isFinished = false,
  });

  CustomQuizState copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    int? score,
    int? lives,
    int? correctAnswers,
    int? wrongAnswers,
    int? skippedAnswers,
    String? selectedAnswer,
    bool? showResult,
    bool? isPlaying,
    bool? isFinished,
  }) {
    return CustomQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      lives: lives ?? this.lives,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      skippedAnswers: skippedAnswers ?? this.skippedAnswers,
      selectedAnswer: selectedAnswer,
      showResult: showResult ?? this.showResult,
      isPlaying: isPlaying ?? this.isPlaying,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  QuestionModel? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  bool get canAddMoreQuestions => questions.length < AppConstants.maxCustomQuestions;

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

class CustomQuizNotifier extends StateNotifier<CustomQuizState> {
  CustomQuizNotifier() : super(const CustomQuizState());

  void addQuestion(QuestionModel question) {
    if (!state.canAddMoreQuestions) return;

    state = state.copyWith(
      questions: [...state.questions, question],
    );
  }

  void updateQuestion(int index, QuestionModel question) {
    if (index < 0 || index >= state.questions.length) return;

    final updatedQuestions = List<QuestionModel>.from(state.questions);
    updatedQuestions[index] = question;

    state = state.copyWith(questions: updatedQuestions);
  }

  void deleteQuestion(int index) {
    if (index < 0 || index >= state.questions.length) return;

    final updatedQuestions = List<QuestionModel>.from(state.questions);
    updatedQuestions.removeAt(index);

    state = state.copyWith(questions: updatedQuestions);
  }

  void startPlaying() {
    if (state.questions.isEmpty) return;

    state = CustomQuizState(
      questions: state.questions,
      isPlaying: true,
    );
  }

  void selectAnswer(String answer) {
    if (state.selectedAnswer != null || state.isFinished) return;

    final isCorrect = answer == state.currentQuestion?.correctAnswer;

    state = state.copyWith(
      selectedAnswer: answer,
      showResult: true,
      score: isCorrect ? state.score + AppConstants.pointsPerCorrectAnswer : state.score,
      correctAnswers: isCorrect ? state.correctAnswers + 1 : state.correctAnswers,
      wrongAnswers: !isCorrect ? state.wrongAnswers + 1 : state.wrongAnswers,
      lives: !isCorrect ? state.lives - 1 : state.lives,
    );

    if (state.lives <= 0) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        state = state.copyWith(isFinished: true);
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
      state = state.copyWith(isFinished: true);
      return;
    }

    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      selectedAnswer: null,
      showResult: false,
    );
  }

  void stopPlaying() {
    state = state.copyWith(
      isPlaying: false,
      isFinished: false,
      currentIndex: 0,
      score: 0,
      lives: AppConstants.initialLives,
      correctAnswers: 0,
      wrongAnswers: 0,
      skippedAnswers: 0,
      selectedAnswer: null,
      showResult: false,
    );
  }

  void clearAllQuestions() {
    state = const CustomQuizState();
  }
}

final customQuizProvider =
    StateNotifierProvider<CustomQuizNotifier, CustomQuizState>((ref) {
  return CustomQuizNotifier();
});
