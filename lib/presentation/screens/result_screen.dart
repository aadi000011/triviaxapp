import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../providers/quiz_provider.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);
    final result = state.result;

    if (result.shouldCelebrate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          ref.read(quizProvider.notifier).reset();
          Get.offAllNamed(AppRoutes.home);
        }
      },
      child: Scaffold(
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
                    _buildScoreCard(context, result),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, result),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(quizProvider.notifier).reset();
                              Get.offAllNamed(AppRoutes.home);
                            },
                            child: const Text('Home'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final difficulty = state.difficulty;
                              ref.read(quizProvider.notifier).reset();
                              if (difficulty != null) {
                                ref
                                    .read(quizProvider.notifier)
                                    .startQuiz(difficulty);
                                Get.offNamed(AppRoutes.quiz);
                              }
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

  Widget _buildScoreCard(BuildContext context, result) {
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

  Widget _buildStatsGrid(BuildContext context, result) {
    return Row(
      children: [
        _buildStatItem(
          context,
          icon: Icons.check_circle,
          color: AppTheme.successColor,
          label: 'Correct',
          value: '${result.correctAnswers}',
        ),
        _buildStatItem(
          context,
          icon: Icons.cancel,
          color: AppTheme.errorColor,
          label: 'Wrong',
          value: '${result.wrongAnswers}',
        ),
        _buildStatItem(
          context,
          icon: Icons.skip_next,
          color: Colors.orange,
          label: 'Skipped',
          value: '${result.skippedAnswers}',
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
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
}
