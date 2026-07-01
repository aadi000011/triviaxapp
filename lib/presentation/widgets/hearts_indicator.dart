import 'package:flutter/material.dart';

class HeartsIndicator extends StatelessWidget {
  final int lives;
  final int maxLives;

  const HeartsIndicator({
    super.key,
    required this.lives,
    this.maxLives = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isFilled = index < lives;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.favorite : Icons.favorite_border,
            color: isFilled ? Colors.red : Colors.grey,
            size: 28,
          ),
        );
      }),
    );
  }
}
