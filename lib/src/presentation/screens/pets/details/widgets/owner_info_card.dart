import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class OwnerInfoCard extends StatefulWidget {
  final String ownerId;

  const OwnerInfoCard({super.key, required this.ownerId});

  @override
  State<OwnerInfoCard> createState() => _OwnerInfoCardState();
}

class _OwnerInfoCardState extends State<OwnerInfoCard> {
  UserEntity? _ownerData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOwnerData();
  }

  Future<void> _loadOwnerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = context.read<UserProvider>();

      // Si es el usuario actual, usar los datos que ya tenemos
      final currentUser = userProvider.currentUser;
      if (currentUser != null && currentUser.id == widget.ownerId) {
        if (!mounted) return;
        setState(() {
          _ownerData = currentUser;
          _isLoading = false;
        });
        return;
      }

      // Cargar datos del usuario específico
      await userProvider.loadUserProfile(widget.ownerId);
      final ownerProfile = userProvider.userProfile;

      if (!mounted) return;
      if (ownerProfile != null) {
        setState(() {
          _ownerData = ownerProfile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Usuario no encontrado';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error al cargar datos del usuario';
        _isLoading = false;
      });
    }
  }

  void _navigateToOwnerProfile() {
    if (_ownerData != null) {
      context.push('/user/${widget.ownerId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser?.uid == widget.ownerId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isCurrentUser ? 'Tu información' : 'Dueño actual',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isCurrentUser && _ownerData != null)
              TextButton.icon(
                onPressed: _navigateToOwnerProfile,
                icon: const Icon(Icons.person, size: 16),
                label: const Text('Ver perfil'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _buildOwnerCard(theme, isCurrentUser),
      ],
    );
  }

  Widget _buildOwnerCard(ThemeData theme, bool isCurrentUser) {
    if (_isLoading) {
      return _buildLoadingCard(theme);
    }

    if (_errorMessage != null) {
      return _buildErrorCard(theme);
    }

    if (_ownerData == null ||
        _ownerData!.displayName.isEmpty ||
        _ownerData!.email.isEmpty) {
      return _buildNotFoundCard(theme);
    }

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
              _buildOwnerAvatar(theme),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _ownerData!.displayName,
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
                      _getOwnerSubtitle(isCurrentUser),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                    if (_ownerData!.hasBio) ...[
                      const SizedBox(height: 8),
                      Text(
                        _ownerData!.bio!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildOwnerStats(theme),
          const SizedBox(height: 15),
          _buildOwnerBadges(theme),
          if (!isCurrentUser) ...[
            const SizedBox(height: 15),
            _buildContactButton(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Error al cargar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _errorMessage ?? 'Error desconocido',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadOwnerData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.person_off, size: 40, color: theme.colorScheme.outline),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario no disponible',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'La información del dueño no está disponible.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerAvatar(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withAlpha(20),
            backgroundImage:
                _ownerData!.hasPhoto
                    ? NetworkImage(_ownerData!.photoUrl!)
                    : null,
            child:
                !_ownerData!.hasPhoto
                    ? Text(
                      _ownerData!.initials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),
        ),
        if (_ownerData!.isVerified)
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

  Widget _buildOwnerStats(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            theme,
            icon: Icons.pets,
            label: 'Publicadas',
            value: _ownerData!.petsPosted.toString(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            theme,
            icon: Icons.favorite,
            label: 'Adoptadas',
            value: _ownerData!.petsAdopted.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerBadges(ThemeData theme) {
    final joinDate = _getJoinDate();
    final experienceText = _getExperienceText();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$experienceText • $joinDate • Responde rápido',
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

  Widget _buildContactButton(ThemeData theme) {
    return CustomButton(
      text: 'Contactar',
      onPressed: _navigateToOwnerProfile,
      variant: ButtonVariant.outline,
      width: double.infinity,
      icon: const Icon(Icons.message, size: 20),
    );
  }

  String _getOwnerSubtitle(bool isCurrentUser) {
    if (isCurrentUser) {
      return _ownerData!.email;
    }

    final joinDate = _getJoinDate();
    return 'Miembro desde $joinDate';
  }

  String _getJoinDate() {
    final createdAt = _ownerData!.createdAt;
    final months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];

    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  String _getExperienceText() {
    final petsPosted = _ownerData!.petsPosted;
    final petsAdopted = _ownerData!.petsAdopted;

    if (petsPosted == 0 && petsAdopted == 0) {
      return 'Nuevo en la comunidad';
    } else if (petsPosted >= 5 || petsAdopted >= 3) {
      return 'Usuario experimentado';
    } else if (petsPosted >= 2 || petsAdopted >= 1) {
      return 'Usuario activo';
    } else {
      return 'Comenzando la aventura';
    }
  }
}
