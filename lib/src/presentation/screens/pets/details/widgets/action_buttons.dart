import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';

class ActionButtons extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onInterest;
  final VoidCallback onContact;

  const ActionButtons({
    super.key,
    required this.pet,
    required this.onInterest,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(child: _buildButtonsForStatus(theme)),
    );
  }

  Widget _buildButtonsForStatus(ThemeData theme) {
    switch (pet.status) {
      case PetStatus.available:
        return _buildAvailableButtons(theme);
      case PetStatus.pending:
        return _buildPendingButtons(theme);
      case PetStatus.adopted:
        return _buildAdoptedButtons(theme);
    }
  }

  Widget _buildAvailableButtons(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              '${pet.name} está buscando un hogar',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onInterest,
                icon: const Icon(Icons.favorite, size: 20),
                label: const Text('¡Me interesa!'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPendingButtons(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.hourglass_empty,
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Adopción en proceso',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pet.name} está en proceso de adopción',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        CustomButton(
          onPressed: () {},
          text: 'Unirse a la lista de espera',
          variant: ButtonVariant.outline,
          width: double.infinity,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAdoptedButtons(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: LightTheme.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.favorite, color: LightTheme.info, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡${pet.name} encontró un hogar!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: LightTheme.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Esta mascota ya fue adoptada exitosamente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LightTheme.info,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
