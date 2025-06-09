import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerInfoCard extends StatelessWidget {
  final String ownerId;

  const OwnerInfoCard({super.key, required this.ownerId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    // TODO: Implementar UserRepository para obtener datos reales del dueño
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dueño actual',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _buildOwnerCard(theme, currentUser),
      ],
    );
  }

  Widget _buildOwnerCard(ThemeData theme, User? currentUser) {
    final isCurrentUser = currentUser?.uid == ownerId;

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
              _buildOwnerAvatar(theme, currentUser),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getOwnerName(currentUser, isCurrentUser),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isCurrentUser)
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
                              'Tú',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getOwnerEmail(currentUser, isCurrentUser),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    // _buildOwnerStats(theme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildOwnerBadges(theme),
        ],
      ),
    );
  }

  Widget _buildOwnerAvatar(ThemeData theme, User? currentUser) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withAlpha(20),
            backgroundImage:
                currentUser?.photoURL != null
                    ? NetworkImage(currentUser!.photoURL!)
                    : null,
            child:
                currentUser?.photoURL == null
                    ? Icon(
                      Icons.person,
                      size: 32,
                      color: theme.colorScheme.primary,
                    )
                    : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.surface, width: 2),
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnerBadges(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_user, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Usuario verificado • Se unió en 2024 • Responde rápido',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getOwnerName(User? currentUser, bool isCurrentUser) {
    if (isCurrentUser) {
      return currentUser?.displayName ?? 'Tu perfil';
    }
    // TODO: Obtener nombre real del dueño desde Firestore
    return 'María González';
  }

  String _getOwnerEmail(User? currentUser, bool isCurrentUser) {
    if (isCurrentUser) {
      return currentUser?.email ?? 'tu-email@ejemplo.com';
    }
    // TODO: Mostrar información pública del dueño
    return 'Miembro desde enero 2024';
  }
}
