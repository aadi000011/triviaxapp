import '../../core/utils/helpers.dart';

class QuestionModel {
  final String id;
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String category;
  final String difficulty;
  final bool isCustom;

  QuestionModel({
    required this.id,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    this.category = 'Custom',
    this.difficulty = 'medium',
    this.isCustom = false,
  });

  List<String> get shuffledOptions {
    final allOptions = [correctAnswer, ...incorrectAnswers];
    return Helpers.shuffleList(allOptions);
  }

  factory QuestionModel.fromApiJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      question: Helpers.decodeHtmlEntities(json['question'] ?? ''),
      correctAnswer: Helpers.decodeHtmlEntities(json['correctAnswer'] ?? ''),
      incorrectAnswers: (json['incorrectAnswers'] as List<dynamic>?)
              ?.map((e) => Helpers.decodeHtmlEntities(e.toString()))
              .toList() ??
          [],
      category: json['category'] ?? 'General',
      difficulty: json['difficulty'] ?? 'medium',
      isCustom: false,
    );
  }

  factory QuestionModel.custom({
    required String question,
    required String correctAnswer,
    required List<String> incorrectAnswers,
  }) {
    return QuestionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question,
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      isCustom: true,
    );
  }

  QuestionModel copyWith({
    String? question,
    String? correctAnswer,
    List<String>? incorrectAnswers,
  }) {
    return QuestionModel(
      id: id,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      category: category,
      difficulty: difficulty,
      isCustom: isCustom,
    );
  }
}
