import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/light_theme.dart';

class PetCharacteristics extends StatelessWidget {
  final PetEntity pet;

  const PetCharacteristics({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildMedicalSection(theme),
        const SizedBox(height: 20),
        _buildBehaviorSection(theme),
        const SizedBox(height: 20),
        _buildPhysicalSection(theme),
      ],
    );
  }

  Widget _buildMedicalSection(ThemeData theme) {
    return _buildSection(
      theme,
      title: 'Información Médica',
      icon: Icons.medical_services,
      iconColor: LightTheme.info,
      children: [
        _buildCharacteristicRow(
          theme,
          'Vacunado',
          pet.vaccinated,
          Icons.vaccines,
        ),
        _buildCharacteristicRow(
          theme,
          'Esterilizado',
          pet.sterilized,
          Icons.healing,
        ),
        if (pet.medicalConditions.isNotEmpty) _buildMedicalConditions(theme),
      ],
    );
  }

  Widget _buildBehaviorSection(ThemeData theme) {
    return _buildSection(
      theme,
      title: 'Comportamiento Social',
      icon: Icons.psychology,
      iconColor: LightTheme.warning,
      children: [
        _buildCharacteristicRow(
          theme,
          'Bueno con niños',
          pet.goodWithKids,
          Icons.child_care,
        ),
        _buildCharacteristicRow(
          theme,
          'Bueno con otras mascotas',
          pet.goodWithPets,
          Icons.pets,
        ),
        _buildCharacteristicRow(
          theme,
          'Sociable con extraños',
          pet.goodWithStrangers,
          Icons.people,
        ),
      ],
    );
  }

  Widget _buildPhysicalSection(ThemeData theme) {
    return _buildSection(
      theme,
      title: 'Características Físicas',
      icon: Icons.pets,
      iconColor: theme.colorScheme.secondary,
      children: [
        _buildPhysicalDetail(theme, 'Color', pet.color, Icons.palette),
        _buildPhysicalDetail(
          theme,
          'Peso',
          '${pet.weight} kg',
          Icons.monitor_weight,
        ),
        _buildPhysicalDetail(theme, 'Tamaño', pet.sizeString, Icons.straighten),
        _buildPhysicalDetail(
          theme,
          'Categoría',
          pet.category.toUpperCase(),
          Icons.category,
        ),
      ],
    );
  }

  Widget _buildSection(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCharacteristicRow(
    ThemeData theme,
    String label,
    bool value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  value
                      ? LightTheme.success.withAlpha(20)
                      : LightTheme.warning.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.help_outline,
                  size: 16,
                  color: value ? LightTheme.success : LightTheme.warning,
                ),
                const SizedBox(width: 5),
                Text(
                  value ? 'Sí' : 'No confirmado',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: value ? LightTheme.success : LightTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalDetail(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurface),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalConditions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.medical_information, size: 20),
            const SizedBox(width: 10),
            Text(
              'Condiciones médicas:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              pet.medicalConditions.map((condition) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: LightTheme.info.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    condition,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: LightTheme.info,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
