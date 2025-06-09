import 'package:flutter/material.dart';

class RegistrationStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double progress;
  final String stepTitle;

  const RegistrationStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildStepIndicators(theme),
    );
  }

  Widget _buildStepIndicators(ThemeData theme) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isCompleted = index < currentStep;
        final isCurrent = index == currentStep;

        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isCompleted || isCurrent
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.secondary.withAlpha(20),
                ),
                child: Center(
                  child:
                      isCompleted
                          ? Icon(
                            Icons.check,
                            size: 14,
                            color: theme.colorScheme.onPrimary,
                          )
                          : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isCurrent || isCompleted
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.secondary,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _getStepLabel(index),
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      isCompleted || isCurrent
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withAlpha(150),
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }

  String _getStepLabel(int index) {
    switch (index) {
      case 0:
        return 'Básica';
      case 1:
        return 'Física';
      case 2:
        return 'Salud';
      case 3:
        return 'Fotos';
      case 4:
        return 'Lugar';
      case 5:
        return 'Vista';
      default:
        return 'Paso ${index + 1}';
    }
  }
}
