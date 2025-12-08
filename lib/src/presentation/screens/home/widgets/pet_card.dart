import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';

class PetCard extends StatelessWidget {
  final PetEntity pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        context.push('/pets/${pet.id}');
      },
      borderRadius: BorderRadius.circular(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(pet.imageUrls[0]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: InkWell(
                onTap: () => {},
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite_border,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 20),
                            const SizedBox(width: 5),
                            Text(
                              pet.location.city,
                              style: theme.textTheme.bodyMedium?.copyWith(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      pet.gender == PetGender.female
                          ? Icons.female
                          : Icons.male,
                      color:
                          pet.gender == PetGender.female
                              ? ThemeConstants.femaleColor
                              : ThemeConstants.maleColor,
                      size: 50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
