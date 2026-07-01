import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../providers/custom_quiz_provider.dart';
import '../widgets/option_tile.dart';
import '../widgets/hearts_indicator.dart';
import '../widgets/animated_score.dart';

class CustomQuizScreen extends ConsumerStatefulWidget {
  const CustomQuizScreen({super.key});

  @override
  ConsumerState<CustomQuizScreen> createState() => _CustomQuizScreenState();
}

class _CustomQuizScreenState extends ConsumerState<CustomQuizScreen> {
  late ConfettiController _confettiController;
  late List<String> _shuffledOptions;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _shuffledOptions = [];
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _shuffleOptions(CustomQuizState state) {
    if (state.currentQuestion != null && _shuffledOptions.isEmpty) {
      _shuffledOptions = state.currentQuestion!.shuffledOptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customQuizProvider);

    ref.listen<CustomQuizState>(customQuizProvider, (previous, next) {
      if (previous?.currentIndex != next.currentIndex) {
        _shuffledOptions = [];
      }
    });

    if (state.isFinished) {
      if (state.result.shouldCelebrate) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confettiController.play();
        });
      }
      return _buildResultScreen(state);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && context.mounted) {
          ref.read(customQuizProvider.notifier).stopPlaying();
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
              final shouldExit = await _showExitDialog();
              if (shouldExit) {
                ref.read(customQuizProvider.notifier).stopPlaying();
                Get.back();
              }
            },
          ),
          actions: [
            AnimatedScore(score: state.score),
            const SizedBox(width: 16),
          ],
        ),
        body: _buildQuizContent(state),
      ),
    );
  }

  Widget _buildQuizContent(CustomQuizState state) {
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
                label: const Text(
                  'Custom Quiz',
                  style: TextStyle(fontSize: 12),
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
                  onTap: () => ref
                      .read(customQuizProvider.notifier)
                      .selectAnswer(option),
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
                        ref.read(customQuizProvider.notifier).skipQuestion(),
                    child: const Text('Skip'),
                  ),
                ),
              if (state.showResult)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(customQuizProvider.notifier).nextQuestion(),
                    child: Text(
                      state.isLastQuestion ? 'See Results' : 'Next Question',
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(CustomQuizState state) {
    final result = state.result;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  _buildResultIcon(result),
                  const SizedBox(height: 24),
                  Text(
                    result.shouldCelebrate
                        ? 'Congratulations!'
                        : 'Quiz Complete!',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getResultMessage(result),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildScoreCard(result),
                  const SizedBox(height: 24),
                  _buildStatsGrid(result),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            ref.read(customQuizProvider.notifier).stopPlaying();
                            Get.offAllNamed(AppRoutes.home);
                          },
                          child: const Text('Home'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(customQuizProvider.notifier).stopPlaying();
                            ref
                                .read(customQuizProvider.notifier)
                                .startPlaying();
                          },
                          child: const Text('Play Again'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultIcon(result) {
    final color = result.shouldCelebrate
        ? AppTheme.successColor
        : result.percentage >= 0.5
            ? Colors.orange
            : AppTheme.errorColor;

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 4),
      ),
      child: Center(
        child: Text(
          result.grade,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCard(result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Final Score',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: result.score),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                );
              },
            ),
            Text(
              'points',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(result) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.check_circle,
          color: AppTheme.successColor,
          label: 'Correct',
          value: '${result.correctAnswers}',
        ),
        _buildStatItem(
          icon: Icons.cancel,
          color: AppTheme.errorColor,
          label: 'Wrong',
          value: '${result.wrongAnswers}',
        ),
        _buildStatItem(
          icon: Icons.skip_next,
          color: Colors.orange,
          label: 'Skipped',
          value: '${result.skippedAnswers}',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getResultMessage(result) {
    if (result.percentage >= 0.9) {
      return 'Outstanding! You\'re a trivia master!';
    } else if (result.percentage >= 0.7) {
      return 'Great job! You really know your stuff!';
    } else if (result.percentage >= 0.5) {
      return 'Good effort! Keep practicing!';
    } else {
      return 'Don\'t give up! Try again!';
    }
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Quiz?'),
            content: const Text(
                'Your progress will be lost. Are you sure you want to exit?'),
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
