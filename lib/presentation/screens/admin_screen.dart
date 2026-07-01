import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:triviax/core/constant/app_constant.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/question_model.dart';
import '../providers/custom_quiz_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customQuizProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          if (state.questions.isNotEmpty)
            IconButton(
              onPressed: () => _showClearAllDialog(),
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: state.questions.isEmpty
          ? _buildEmptyState()
          : _buildQuestionList(state),
      floatingActionButton: state.canAddMoreQuestions
          ? FloatingActionButton.extended(
              onPressed: () => _showQuestionDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No custom questions yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first question',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showQuestionDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Question'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList(CustomQuizState state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${state.questions.length}/${AppConstants.maxCustomQuestions} questions created',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.questions.length,
            itemBuilder: (context, index) {
              final question = state.questions[index];
              return _buildQuestionCard(question, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          question.question,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Answer: ${question.correctAnswer}',
            style: TextStyle(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showQuestionDialog(question: question, index: index);
            } else if (value == 'delete') {
              _showDeleteDialog(index);
            }
          },
        ),
      ),
    );
  }

  void _showQuestionDialog({QuestionModel? question, int? index}) {
    final isEditing = question != null;
    final questionController =
        TextEditingController(text: question?.question ?? '');
    final optionControllers = List.generate(
      AppConstants.optionsPerQuestion,
      (i) => TextEditingController(
        text: i == 0
            ? question?.correctAnswer ?? ''
            : i <= (question?.incorrectAnswers.length ?? 0)
                ? question?.incorrectAnswers[i - 1] ?? ''
                : '',
      ),
    );
    int correctIndex = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(isEditing ? 'Edit Question' : 'Add Question'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Options (tap to set correct answer):',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(AppConstants.optionsPerQuestion, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: i,
                            groupValue: correctIndex,
                            onChanged: (value) {
                              setDialogState(() => correctIndex = value!);
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: optionControllers[i],
                              decoration: InputDecoration(
                                labelText: 'Option ${String.fromCharCode(65 + i)}',
                                border: const OutlineInputBorder(),
                                filled: correctIndex == i,
                                fillColor: AppTheme.successColor.withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final questionText = questionController.text.trim();
                  final options =
                      optionControllers.map((c) => c.text.trim()).toList();

                  if (questionText.isEmpty ||
                      options.any((o) => o.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields'),
                      ),
                    );
                    return;
                  }

                  final correctAnswer = options[correctIndex];
                  final incorrectAnswers = options
                      .where((o) => o != correctAnswer)
                      .toList();

                  final newQuestion = QuestionModel.custom(
                    question: questionText,
                    correctAnswer: correctAnswer,
                    incorrectAnswers: incorrectAnswers,
                  );

                  if (isEditing && index != null) {
                    ref
                        .read(customQuizProvider.notifier)
                        .updateQuestion(index, newQuestion);
                  } else {
                    ref
                        .read(customQuizProvider.notifier)
                        .addQuestion(newQuestion);
                  }

                  Navigator.pop(context);
                },
                child: Text(isEditing ? 'Save' : 'Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customQuizProvider.notifier).deleteQuestion(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Questions?'),
        content:
            const Text('This will delete all custom questions. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customQuizProvider.notifier).clearAllQuestions();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
