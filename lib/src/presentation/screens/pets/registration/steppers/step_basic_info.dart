import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pet_adoption_app/src/core/data/pet_categories.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_text_field.dart';
import 'package:provider/provider.dart';

class StepBasicInfo extends StatefulWidget {
  const StepBasicInfo({super.key});

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<PetRegistrationProvider>();
    _nameController.text = provider.petName ?? '';
    _breedController.text = provider.petBreed ?? '';
    _selectedCategory = provider.petCategory;

    if (provider.petAgeInMonths != null) {
      _ageController.text = provider.petAgeInMonths.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<PetRegistrationProvider>();
      provider.updateBasicInfo(
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        breed: _breedController.text.trim(),
        ageInMonths: int.parse(_ageController.text),
      );
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
              'Cuéntanos sobre tu mascota',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Información básica para que otros puedan conocer a tu mascota.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Nombre de la mascota *',
              hint: 'ej. Max, Luna, Michi...',
              controller: _nameController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            _buildCategorySelector(theme),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Raza *',
              hint: 'ej. Labrador, Persa, Mestizo...',
              controller: _breedController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La raza es obligatoria';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            _buildAgeField(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de mascota *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              petCategories.map((category) {
                final isSelected =
                    _selectedCategory == category.name.toLowerCase();

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category.name.toLowerCase();
                    });
                    _updateData();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? category.color.withAlpha(20)
                              : theme.cardColor,
                      border:
                          isSelected
                              ? Border.all(color: category.color, width: 2)
                              : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          color:
                              isSelected
                                  ? category.color
                                  : theme.colorScheme.onSurface.withAlpha(150),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          category.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                isSelected
                                    ? category.color
                                    : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgeField(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CustomTextField(
            label: 'Edad *',
            hint: '0',
            controller: _ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La edad es obligatoria';
              }
              final age = int.tryParse(value);
              if (age == null || age <= 0) {
                return 'Edad inválida';
              }
              if (age > 300) {
                return 'Edad muy alta';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
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
              'Meses',
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
}
