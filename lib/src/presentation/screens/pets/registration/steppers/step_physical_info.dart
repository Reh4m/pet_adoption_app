import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';

class StepPhysicalInfo extends StatefulWidget {
  const StepPhysicalInfo({super.key});

  @override
  State<StepPhysicalInfo> createState() => _StepPhysicalInfoState();
}

class _StepPhysicalInfoState extends State<StepPhysicalInfo> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _colorController = TextEditingController();

  PetSize? _selectedSize;
  PetGender? _selectedGender;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<PetRegistrationProvider>();
    _selectedSize = provider.petSize;
    _selectedGender = provider.petGender;
    _colorController.text = provider.petColor ?? '';

    if (provider.petWeight != null) {
      _weightController.text = provider.petWeight.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSize != null && _selectedGender != null) {
        final provider = context.read<PetRegistrationProvider>();
        provider.updatePhysicalInfo(
          size: _selectedSize!,
          weight: double.parse(_weightController.text),
          color: _colorController.text.trim(),
          gender: _selectedGender!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      onChanged: _updateData,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Características físicas',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Ayuda a las familias a conocer mejor a tu mascota.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildSizeSelector(theme),
            const SizedBox(height: 20),
            _buildWeightField(theme),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Color *',
              hint: 'ej. Dorado, Negro, Blanco y café...',
              controller: _colorController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El color es obligatorio';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            _buildGenderSelector(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tamaño *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildSizeOption(
              theme,
              PetSize.small,
              'Pequeño',
              'Hasta 10kg',
              Icons.pets,
            ),
            const SizedBox(width: 10),
            _buildSizeOption(
              theme,
              PetSize.medium,
              'Mediano',
              '10-25kg',
              Icons.pets,
            ),
            const SizedBox(width: 10),
            _buildSizeOption(
              theme,
              PetSize.large,
              'Grande',
              'Más de 25kg',
              Icons.pets,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeOption(
    ThemeData theme,
    PetSize size,
    String label,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedSize == size;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSize = size;
          });
          _updateData();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.primary.withAlpha(20)
                    : theme.colorScheme.surface,
            border:
                isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withAlpha(150),
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeightField(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            label: 'Peso aproximado *',
            hint: '0.0',
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El peso es obligatorio';
              }
              final weight = double.tryParse(value);
              if (weight == null || weight <= 0) {
                return 'Peso inválido';
              }
              if (weight > 200) {
                return 'Peso muy alto';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 28),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary),
            ),
            child: Text(
              'Kg',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Género *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildGenderOption(
              theme,
              PetGender.male,
              'Macho',
              Icons.male,
              ThemeConstants.maleColor,
            ),
            const SizedBox(width: 10),
            _buildGenderOption(
              theme,
              PetGender.female,
              'Hembra',
              Icons.female,
              ThemeConstants.femaleColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(
    ThemeData theme,
    PetGender gender,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedGender == gender;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
          _updateData();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(20) : theme.colorScheme.surface,
            border: isSelected ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? color
                        : theme.colorScheme.onSurface.withAlpha(150),
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? color : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
