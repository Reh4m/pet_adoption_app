import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:provider/provider.dart';

class StepMedicalBehavior extends StatefulWidget {
  const StepMedicalBehavior({super.key});

  @override
  State<StepMedicalBehavior> createState() => _StepMedicalBehaviorState();
}

class _StepMedicalBehaviorState extends State<StepMedicalBehavior> {
  bool _vaccinated = false;
  bool _sterilized = false;
  bool _goodWithKids = false;
  bool _goodWithPets = false;
  bool _goodWithStrangers = false;
  final List<String> _medicalConditions = [];

  final List<String> _commonConditions = [
    'Ninguna condición especial',
    'Alergias alimentarias',
    'Problemas de piel',
    'Artritis',
    'Problemas cardíacos',
    'Diabetes',
    'Problemas de visión',
    'Problemas de audición',
    'Medicación regular',
    'Dieta especial',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<PetRegistrationProvider>();
    _vaccinated = provider.isVaccinated;
    _sterilized = provider.isSterilized;
    _goodWithKids = provider.goodWithKids;
    _goodWithPets = provider.goodWithPets;
    _goodWithStrangers = provider.goodWithStrangers;
    _medicalConditions.addAll(provider.medicalConditions);
  }

  void _updateData() {
    final provider = context.read<PetRegistrationProvider>();
    provider.updateMedicalInfo(
      vaccinated: _vaccinated,
      sterilized: _sterilized,
      medicalConditions: _medicalConditions,
      goodWithKids: _goodWithKids,
      goodWithPets: _goodWithPets,
      goodWithStrangers: _goodWithStrangers,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Salud y comportamiento',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Esta información ayuda a encontrar el hogar perfecto.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _buildMedicalSection(theme),
          const SizedBox(height: 20),
          _buildMedicalConditionsSection(theme),
          const SizedBox(height: 20),
          _buildBehaviorSection(theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMedicalSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estado médico',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          theme,
          title: 'Vacunado',
          subtitle: 'Tiene sus vacunas al día',
          value: _vaccinated,
          icon: Icons.vaccines,
          onChanged: (value) {
            setState(() {
              _vaccinated = value;
            });
            _updateData();
          },
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          theme,
          title: 'Esterilizado',
          subtitle: 'Ha sido castrado o esterilizado',
          value: _sterilized,
          icon: Icons.medical_services,
          onChanged: (value) {
            setState(() {
              _sterilized = value;
            });
            _updateData();
          },
        ),
      ],
    );
  }

  Widget _buildMedicalConditionsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condiciones médicas',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Selecciona todas las que apliquen',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          children:
              _commonConditions.map((condition) {
                final isSelected = _medicalConditions.contains(condition);

                return FilterChip(
                  label: Text(condition),
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                  ),
                  selected: isSelected,
                  selectedColor: theme.colorScheme.primary,
                  checkmarkColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide.none,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        if (condition == 'Ninguna condición especial') {
                          _medicalConditions.clear();
                          _medicalConditions.add(condition);
                        } else {
                          _medicalConditions.remove(
                            'Ninguna condición especial',
                          );
                          _medicalConditions.add(condition);
                        }
                      } else {
                        _medicalConditions.remove(condition);
                      }
                    });
                    _updateData();
                  },
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildBehaviorSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comportamiento social',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          theme,
          title: 'Bueno con niños',
          subtitle: 'Se lleva bien con niños pequeños',
          value: _goodWithKids,
          icon: Icons.child_care,
          onChanged: (value) {
            setState(() {
              _goodWithKids = value;
            });
            _updateData();
          },
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          theme,
          title: 'Bueno con otras mascotas',
          subtitle: 'Se lleva bien con otros animales',
          value: _goodWithPets,
          icon: Icons.pets,
          onChanged: (value) {
            setState(() {
              _goodWithPets = value;
            });
            _updateData();
          },
        ),
        const SizedBox(height: 10),
        _buildSwitchTile(
          theme,
          title: 'Sociable con extraños',
          subtitle: 'Es amigable con personas nuevas',
          value: _goodWithStrangers,
          icon: Icons.people,
          onChanged: (value) {
            setState(() {
              _goodWithStrangers = value;
            });
            _updateData();
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  value
                      ? theme.colorScheme.primary.withAlpha(20)
                      : theme.colorScheme.onSurface.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  value
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withAlpha(150),
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
