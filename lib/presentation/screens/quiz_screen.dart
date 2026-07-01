import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../providers/quiz_provider.dart';
import '../widgets/option_tile.dart';
import '../widgets/hearts_indicator.dart';
import '../widgets/animated_score.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _shuffledOptions = [];
  }

  void _shuffleOptions(QuizState state) {
    if (state.currentQuestion != null && _shuffledOptions.isEmpty) {
      _shuffledOptions = state.currentQuestion!.shuffledOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    ref.listen<QuizState>(quizProvider, (previous, next) {
      if (next.status == QuizStatus.finished) {
        Get.offNamed(AppRoutes.result);
      }
      if (previous?.currentIndex != next.currentIndex) {
        _shuffledOptions = [];
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog(context);
        if (shouldPop && context.mounted) {
          ref.read(quizProvider.notifier).reset();
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Question ${state.currentIndex + 1}/${state.questions.length}',
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldExit = await _showExitDialog(context);
              if (shouldExit) {
                ref.read(quizProvider.notifier).reset();
                Get.back();
              }
            },
          ),
          actions: [
            AnimatedScore(score: state.score),
            const SizedBox(width: 16),
          ],
        ),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(QuizState state) {
    switch (state.status) {
      case QuizStatus.loading:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading questions...'),
            ],
          ),
        );

      case QuizStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Unable to load questions',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (state.difficulty != null) {
                      ref
                          .read(quizProvider.notifier)
                          .startQuiz(state.difficulty!);
                    }
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        );

      case QuizStatus.ready:
      case QuizStatus.answering:
        return _buildQuizContent(state);

      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildQuizContent(QuizState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    _shuffleOptions(state);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Chip(
                label: Text(
                  question.category,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
              HeartsIndicator(lives: state.lives),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (state.currentIndex + 1) / state.questions.length,
            backgroundColor: Colors.grey.shade300,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _shuffledOptions.length,
              itemBuilder: (context, index) {
                final option = _shuffledOptions[index];
                final label = String.fromCharCode(65 + index);

                OptionState optionState = OptionState.normal;

                if (state.showResult) {
                  if (option == question.correctAnswer) {
                    optionState = OptionState.correct;
                  } else if (option == state.selectedAnswer) {
                    optionState = OptionState.incorrect;
                  } else {
                    optionState = OptionState.disabled;
                  }
                }

                return OptionTile(
                  option: option,
                  label: label,
                  state: optionState,
                  onTap: () =>
                      ref.read(quizProvider.notifier).selectAnswer(option),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!state.showResult)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ref.read(quizProvider.notifier).skipQuestion(),
                    child: const Text('Skip'),
                  ),
                ),
              if (state.showResult) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(quizProvider.notifier).nextQuestion(),
                    child: Text(
                      state.isLastQuestion ? 'See Results' : 'Next Question',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content:
                const Text('Your progress will be lost. Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
