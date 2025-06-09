import 'package:flutter/material.dart';

class ProfileStatsCard extends StatelessWidget {
  final int petsPosted;
  final int petsAdopted;
  final bool isExperienced;

  const ProfileStatsCard({
    super.key,
    required this.petsPosted,
    required this.petsAdopted,
    required this.isExperienced,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Aportaciones',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.pets,
                  label: 'Mascotas publicadas',
                  value: petsPosted.toString(),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatItem(
                  theme,
                  icon: Icons.favorite,
                  label: 'Mascotas adoptadas',
                  value: petsAdopted.toString(),
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildExperienceLevel(theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 5),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceLevel(ThemeData theme) {
    String experienceText;
    IconData experienceIcon;
    Color experienceColor;

    if (petsPosted == 0 && petsAdopted == 0) {
      experienceText = 'Nuevo en la comunidad';
      experienceIcon = Icons.waving_hand;
      experienceColor = theme.colorScheme.outline;
    } else if (petsPosted >= 5 || petsAdopted >= 3) {
      experienceText = 'Usuario experimentado';
      experienceIcon = Icons.stars;
      experienceColor = Colors.amber;
    } else if (petsPosted >= 2 || petsAdopted >= 1) {
      experienceText = 'Usuario activo';
      experienceIcon = Icons.trending_up;
      experienceColor = Colors.green;
    } else {
      experienceText = 'Comenzando la aventura';
      experienceIcon = Icons.rocket_launch;
      experienceColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: experienceColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(experienceIcon, color: experienceColor, size: 20),
          const SizedBox(width: 10),
          Text(
            experienceText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: experienceColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
