import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/user_pet_card.dart';

class UserPetsSection extends StatefulWidget {
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
  State<UserPetsSection> createState() => _UserPetsSectionState();
}

class _UserPetsSectionState extends State<UserPetsSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPets = widget.availablePets.length + widget.adoptedPets.length;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                widget.isCurrentUser ? 'Mis Mascotas' : 'Sus Mascotas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (totalPets > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalPets ${totalPets == 1 ? 'mascota' : 'mascotas'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (totalPets == 0)
            _buildEmptyState(theme)
          else ...[
            const SizedBox(height: 10),
            TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface,
              indicatorColor: theme.colorScheme.primary,
              dividerColor: Colors.transparent,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_outline, size: 16),
                      const SizedBox(width: 10),
                      Text('En adopción (${widget.availablePets.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home, size: 16),
                      const SizedBox(width: 8),
                      Text('Adoptadas (${widget.adoptedPets.length})'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPetsList(widget.availablePets, 'disponibles'),
                  _buildPetsList(widget.adoptedPets, 'adoptadas'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.pets, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            widget.isCurrentUser
                ? 'Aún no tienes mascotas registradas'
                : 'Este usuario no ha registrado mascotas',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isCurrentUser
                ? 'Sé el primero en ayudar a una mascota a encontrar un hogar'
                : 'Cuando registre mascotas, aparecerán aquí',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(List<PetEntity> pets, String type) {
    if (pets.isEmpty) {
      return _buildEmptyPetsState(type);
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        return UserPetCard(
          pet: pets[index],
          onTap: () => widget.onPetTap(pets[index]),
        );
      },
    );
  }

  Widget _buildEmptyPetsState(String type) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'disponibles'
                  ? Icons.favorite_outline
                  : Icons.home_outlined,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              type == 'disponibles'
                  ? 'Sin mascotas en adopción'
                  : 'Sin mascotas adoptadas',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              type == 'disponibles'
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
