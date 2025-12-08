import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/config/themes/color_palette.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_registration_provider.dart';
import 'package:provider/provider.dart';

class StepPreview extends StatelessWidget {
  const StepPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PetRegistrationProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Vista previa',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Así es como las familias verán a tu mascota.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _buildPreviewCard(theme, provider),
              const SizedBox(height: 20),
              _buildAdditionalInfo(theme, provider),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewCard(ThemeData theme, PetRegistrationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(provider),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.petName ?? 'Sin nombre',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${provider.petBreed} • ${_getAgeString(provider.petAgeInMonths)}',
                            style: theme.textTheme.bodyLarge?.copyWith(),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      provider.petGender == PetGender.female
                          ? Icons.female
                          : Icons.male,
                      color:
                          provider.petGender == PetGender.female
                              ? ThemeConstants.femaleColor
                              : ThemeConstants.maleColor,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.petLocation?.city}, ${provider.petLocation?.state}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(theme, provider.petSize?.name ?? 'Sin tamaño'),
                    _buildTag(theme, '${provider.petWeight ?? 0}kg'),
                    _buildTag(theme, provider.petColor ?? 'Sin color'),
                    if (provider.isVaccinated)
                      _buildTag(theme, 'Vacunado', isPositive: true),
                    if (provider.isSterilized)
                      _buildTag(theme, 'Esterilizado', isPositive: true),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Descripción',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  provider.petDescription ?? 'Sin descripción',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(PetRegistrationProvider provider) {
    if (provider.selectedImages.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pets, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Sin imágenes',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 250,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.file(
              provider.selectedImages.first,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          if (provider.selectedImages.length > 1)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(150),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${provider.selectedImages.length - 1} más',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(ThemeData theme, String text, {bool isPositive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            isPositive
                ? ColorPalette.success.withAlpha(20)
                : theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isPositive ? ColorPalette.success : theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(
    ThemeData theme,
    PetRegistrationProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comportamiento',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildBehaviorItem(
            theme,
            'Bueno con niños',
            provider.goodWithKids,
            Icons.child_care,
          ),
          _buildBehaviorItem(
            theme,
            'Bueno con mascotas',
            provider.goodWithPets,
            Icons.pets,
          ),
          _buildBehaviorItem(
            theme,
            'Sociable con extraños',
            provider.goodWithStrangers,
            Icons.people,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorItem(
    ThemeData theme,
    String label,
    bool value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: value ? ColorPalette.success : ColorPalette.warning,
          ),
        ],
      ),
    );
  }

  String _getAgeString(int? ageInMonths) {
    if (ageInMonths == null) return 'Edad desconocida';

    if (ageInMonths < 12) {
      return '$ageInMonths ${ageInMonths == 1 ? 'mes' : 'meses'}';
    }

    final years = ageInMonths ~/ 12;
    final months = ageInMonths % 12;

    if (months == 0) {
      return '$years ${years == 1 ? 'año' : 'años'}';
    }

    return '$years ${years == 1 ? 'año' : 'años'} y $months ${months == 1 ? 'mes' : 'meses'}';
  }
}
