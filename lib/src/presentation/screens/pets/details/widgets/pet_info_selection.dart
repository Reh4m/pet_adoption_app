import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/color_palette.dart';

class PetInfoSection extends StatelessWidget {
  final PetEntity pet;

  const PetInfoSection({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${pet.breed} • ${pet.ageString}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            _buildStatusBadge(theme),
          ],
        ),
        const SizedBox(height: 20),
        _buildLocationInfo(theme),
        const SizedBox(height: 20),
        _buildQuickInfo(theme),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (pet.status) {
      case PetStatus.available:
        statusColor = ColorPalette.success;
        statusText = 'Disponible';
        statusIcon = Icons.check_circle;
        break;
      case PetStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.hourglass_empty;
        break;
      case PetStatus.adopted:
        statusColor = Colors.blue;
        statusText = 'Adoptado';
        statusIcon = Icons.favorite;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 5),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pet.location.city}, ${pet.location.state}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(pet.location.address, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '~2.5 km', // TODO: Calcular distancia real
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(ThemeData theme) {
    return Row(
      children: [
        _buildInfoChip(
          theme,
          icon: pet.gender == PetGender.female ? Icons.female : Icons.male,
          label: pet.genderString,
          color:
              pet.gender == PetGender.female
                  ? ThemeConstants.femaleColor
                  : ThemeConstants.maleColor,
        ),
        const SizedBox(width: 10),
        _buildInfoChip(
          theme,
          icon: Icons.straighten,
          label: pet.sizeString,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(width: 10),
        _buildInfoChip(
          theme,
          icon: Icons.monitor_weight,
          label: '${pet.weight}kg',
          color: theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
