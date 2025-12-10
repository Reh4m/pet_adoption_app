import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/user_pet_card.dart';

class UserPetsSection extends StatelessWidget {
  final List<PetEntity> availablePets;
  final List<PetEntity> adoptedPets;
  final bool isCurrentUser;
  final Function(PetEntity) onPetTap;

  const UserPetsSection({
    super.key,
    required this.availablePets,
    required this.adoptedPets,
    required this.isCurrentUser,
    required this.onPetTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBarView(
      children: [
        _buildPetsList(theme, pets: availablePets, listType: 'disponibles'),
        _buildPetsList(theme, pets: adoptedPets, listType: 'adoptadas'),
      ],
    );
  }

  Widget _buildPetsList(
    ThemeData theme, {
    required List<PetEntity> pets,
    required String listType,
  }) {
    if (pets.isEmpty) {
      return _buildEmptyPetsState(theme, listType);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return UserPetCard(
          pet: pets[index],
          onTap: () => onPetTap(pets[index]),
        );
      },
    );
  }

  Widget _buildEmptyPetsState(ThemeData theme, String listType) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              listType == 'disponibles'
                  ? Icons.favorite_outline
                  : Icons.home_outlined,
              size: 48,
              color: theme.colorScheme.onSurface,
            ),
            const SizedBox(height: 12),
            Text(
              listType == 'disponibles'
                  ? 'Sin mascotas en adopción'
                  : 'Sin mascotas adoptadas',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              listType == 'disponibles'
                  ? 'Las mascotas disponibles para adopción aparecerán aquí'
                  : 'Las mascotas que han encontrado hogar aparecerán aquí',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
