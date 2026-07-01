import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum OptionState { normal, correct, incorrect, disabled }

class OptionTile extends StatelessWidget {
  final String option;
  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.option,
    required this.label,
    this.state = OptionState.normal,
    this.onTap,
  });

  Color _getBackgroundColor(BuildContext context) {
    switch (state) {
      case OptionState.correct:
        return AppTheme.successColor;
      case OptionState.incorrect:
        return AppTheme.errorColor;
      case OptionState.disabled:
        return Theme.of(context).disabledColor.withOpacity(0.1);
      case OptionState.normal:
        return Theme.of(context).cardColor;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (state) {
      case OptionState.correct:
      case OptionState.incorrect:
        return Colors.white;
      case OptionState.disabled:
        return Theme.of(context).disabledColor;
      case OptionState.normal:
        return Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    }
  }

  IconData? _getIcon() {
    switch (state) {
      case OptionState.correct:
        return Icons.check_circle;
      case OptionState.incorrect:
        return Icons.cancel;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        elevation: state == OptionState.normal ? 2 : 0,
        child: InkWell(
          onTap: state == OptionState.normal ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: state == OptionState.normal
                    ? Theme.of(context).dividerColor
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: state == OptionState.normal
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: state == OptionState.normal
                            ? AppTheme.primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 16,
                      color: _getTextColor(context),
                      fontWeight: state != OptionState.normal
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (_getIcon() != null)
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
