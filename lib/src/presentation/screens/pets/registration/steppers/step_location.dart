import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_location_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_text_field.dart';
import 'package:pet_adoption_app/src/presentation/screens/location/location_picker_screen.dart';
import 'package:provider/provider.dart';

class StepLocation extends StatefulWidget {
  const StepLocation({super.key});

  @override
  State<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends State<StepLocation> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  PetLocationEntity? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final provider = context.read<PetRegistrationProvider>();
    _descriptionController.text = provider.petDescription ?? '';

    if (provider.petLocation != null) {
      _selectedLocation = provider.petLocation;
      _addressController.text = provider.petLocation!.address;
      _cityController.text = provider.petLocation!.city;
      _stateController.text = provider.petLocation!.state;
    } else {
      _cityController.text = 'Celaya';
      _stateController.text = 'Guanajuato';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _showLocationPicker() async {
    final result = await context.push<LocationPickerResult>(
      '/location-picker',
      extra: {'showRadiusControl': false},
    );

    if (!mounted || result == null) return;

    setState(() {
      _selectedLocation = result.location;

      _addressController.text = result.location.address;
      _cityController.text = result.location.city;
      _stateController.text = result.location.state;
    });

    _updateData();
  }

  void _updateData() {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = context.read<PetRegistrationProvider>();

      // Crear ubicación final con coordenadas seleccionadas o por defecto
      final location = PetLocationEntity(
        latitude: _selectedLocation?.latitude ?? 20.5264, // Celaya por defecto
        longitude: _selectedLocation?.longitude ?? -100.8147,
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
      );

      provider.updateLocationInfo(
        location: location,
        description: _descriptionController.text.trim(),
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
              'Ubicación y descripción',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Ayuda a las familias a conocer a tu mascota y su ubicación.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              label: 'Descripción de la mascota *',
              hint:
                  'Cuéntanos sobre la personalidad, gustos y características especiales de tu mascota...',
              controller: _descriptionController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                if (value.trim().length < 20) {
                  return 'La descripción debe tener al menos 20 caracteres';
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 20),
            Text(
              'Ubicación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Información general de la zona donde se encuentra tu mascota.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            CustomTextField(
              label: 'Dirección o colonia *',
              hint: 'ej. Centro, Colonia Las Flores, etc.',
              controller: _addressController,
              enabled: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dirección es obligatoria';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Ciudad *',
                    hint: 'Ciudad',
                    controller: _cityController,
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La ciudad es obligatoria';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    label: 'Estado *',
                    hint: 'Estado',
                    controller: _stateController,
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El estado es obligatorio';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPrivacyInfo(theme),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.security, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu privacidad es importante',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Solo se mostrará información general de la zona, no tu dirección exacta.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          CustomButton(
            text:
                _selectedLocation != null
                    ? 'Cambiar ubicación en mapa'
                    : 'Seleccionar en mapa',
            icon: const Icon(Icons.map, size: 20),
            variant: ButtonVariant.outline,
            onPressed: _showLocationPicker,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
