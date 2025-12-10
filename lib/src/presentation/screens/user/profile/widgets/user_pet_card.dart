import 'package:flutter/material.dart';
import 'package:pet_adoption_app/src/core/constants/theme_constants.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';

class UserPetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;

  const UserPetCard({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(theme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPetInfo(theme),
                    const Spacer(),
                    _buildStatusBadge(theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child:
            pet.imageUrls.isNotEmpty
                ? Image.network(
                  pet.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => _buildPlaceholder(theme),
                )
                : _buildPlaceholder(theme),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.primary.withAlpha(20),
      child: Center(
        child: Icon(Icons.pets, size: 40, color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildPetInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                pet.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              pet.gender == PetGender.female ? Icons.female : Icons.male,
              size: 16,
              color:
                  pet.gender == PetGender.female
                      ? ThemeConstants.femaleColor
                      : ThemeConstants.maleColor,
            ),
          ],
        ),
        // const SizedBox(height: 4),
        // Text(
        //   '${pet.breed} • ${pet.ageString}',
        //   style: theme.textTheme.bodySmall?.copyWith(
        //     color: theme.colorScheme.onSurface.withAlpha(150),
        //   ),
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (pet.status) {
      case PetStatus.available:
        statusColor = Colors.green;
        statusText = 'Disponible';
        statusIcon = Icons.favorite_outline;
        break;
      case PetStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        statusIcon = Icons.hourglass_empty;
        break;
      case PetStatus.adopted:
        statusColor = Colors.blue;
        statusText = 'Adoptado';
        statusIcon = Icons.home;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
