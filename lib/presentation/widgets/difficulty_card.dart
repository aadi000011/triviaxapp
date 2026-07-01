import 'package:flutter/material.dart';
import 'package:triviax/core/constant/app_constant.dart';
import '../../core/theme/app_theme.dart';

class DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final VoidCallback onTap;

  const DifficultyCard({
    super.key,
    required this.difficulty,
    required this.onTap,
  });

  Color get _cardColor {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green.shade400;
      case Difficulty.medium:
        return Colors.orange.shade400;
      case Difficulty.hard:
        return Colors.red.shade400;
    }
  }

  IconData get _icon {
    switch (difficulty) {
      case Difficulty.easy:
        return Icons.sentiment_satisfied_alt;
      case Difficulty.medium:
        return Icons.sentiment_neutral;
      case Difficulty.hard:
        return Icons.sentiment_very_dissatisfied;
    }
  }

  String get _description {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Perfect for beginners';
      case Difficulty.medium:
        return 'For the curious minds';
      case Difficulty.hard:
        return 'Only for the brave';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: _cardColor.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                _cardColor,
                _cardColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icon,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                difficulty.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
