import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/color_palette.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';

class ActionButtons extends StatelessWidget {
  final PetEntity pet;

  const ActionButtons({super.key, required this.pet});

  void _handleAdoptionRequest(BuildContext context) {
    context.push('/adoption/request/${pet.id}', extra: {'pet': pet});
  }

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
      child: SafeArea(child: _buildButtonsForStatus(context, theme)),
    );
  }

  Widget _buildButtonsForStatus(BuildContext context, ThemeData theme) {
    switch (pet.status) {
      case PetStatus.available:
        return _buildAvailableButtons(context, theme);
      case PetStatus.pending:
        return _buildPendingButtons(context, theme);
      case PetStatus.adopted:
        return _buildAdoptedButtons(theme);
    }
  }

  Widget _buildAvailableButtons(BuildContext context, ThemeData theme) {
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
              child: CustomButton(
                text: '¡Quiero adoptarlo!',
                onPressed: () => _handleAdoptionRequest(context),
                icon: const Icon(Icons.favorite, size: 20),
                height: 56,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPendingButtons(BuildContext context, ThemeData theme) {
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
          onPressed: () => _handleAdoptionRequest(context),
          text: 'Unirse a la lista de espera',
          variant: ButtonVariant.outline,
          width: double.infinity,
          icon: const Icon(Icons.schedule, size: 20),
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
            color: ColorPalette.info.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: ColorPalette.info, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡${pet.name} encontró un hogar!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: ColorPalette.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Esta mascota ya fue adoptada exitosamente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorPalette.info,
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
