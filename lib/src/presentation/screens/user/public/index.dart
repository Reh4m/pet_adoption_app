import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_header.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_stats_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/user_pets_section.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class PublicUserProfileScreen extends StatefulWidget {
  final String userId;

  const PublicUserProfileScreen({super.key, required this.userId});

  @override
  State<PublicUserProfileScreen> createState() =>
      _PublicUserProfileScreenState();
}

class _PublicUserProfileScreenState extends State<PublicUserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final petProvider = context.read<PetProvider>();

      // Cargar perfil del usuario específico
      userProvider.loadUserProfile(widget.userId);

      // Asegurar que tenemos todas las mascotas cargadas
      if (petProvider.allPets.isEmpty) {
        petProvider.startRealtimeUpdates();
      }
    });
  }

  void _handleContactUser(UserEntity user) {
    // TODO: Implementar navegación al chat
    ToastNotification.show(
      context,
      title: 'Chat próximamente',
      description:
          'Pronto podrás contactar a ${user.displayName} directamente.',
      type: ToastNotificationType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer2<UserProvider, PetProvider>(
        builder: (context, userProvider, petProvider, child) {
          final userProfile = userProvider.userProfile;
          final isLoading = userProvider.userProfileState == UserState.loading;
          final hasError = userProvider.userProfileState == UserState.error;

          if (isLoading && userProfile == null) {
            return _buildLoadingState();
          }

          if (hasError && userProfile == null) {
            return _buildErrorState(theme, userProvider.userProfileError);
          }

          if (userProfile == null) {
            return _buildNotFoundState();
          }

          // Filtrar mascotas del usuario específico
          final userPets =
              petProvider.allPets
                  .where((pet) => pet.ownerId == widget.userId)
                  .toList();

          final adoptedPets =
              userPets.where((pet) => pet.status == PetStatus.adopted).toList();

          final availablePets =
              userPets
                  .where((pet) => pet.status == PetStatus.available)
                  .toList();

          return _buildUserProfile(
            userProfile,
            availablePets,
            adoptedPets,
            petProvider,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando perfil...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String? errorMessage) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error al cargar perfil',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Error desconocido',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Reintentar', onPressed: _loadUserProfile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Usuario no encontrado',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Este perfil no está disponible o fue eliminado.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(text: 'Volver', onPressed: () => context.pop()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(
    UserEntity userProfile,
    List<PetEntity> availablePets,
    List<PetEntity> adoptedPets,
    PetProvider petProvider,
  ) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        final userProvider = context.read<UserProvider>();
        await userProvider.loadUserProfile(widget.userId);
        await petProvider.refreshPets();
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => {},
                  color: theme.colorScheme.onPrimary,
                  icon: Icon(Icons.more_vert),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: ProfileHeader(
                user: userProfile,
                isCurrentUser: false,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProfileStatsCard(
                    petsPosted: userProfile.petsPosted,
                    petsAdopted: userProfile.petsAdopted,
                    isExperienced: userProfile.isExperienced,
                  ),
                  const SizedBox(height: 20),
                  _buildContactSection(theme, userProfile),
                  const SizedBox(height: 20),
                  UserPetsSection(
                    availablePets: availablePets,
                    adoptedPets: adoptedPets,
                    isCurrentUser: false,
                    onPetTap: (pet) => context.push('/pets/${pet.id}'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(ThemeData theme, UserEntity userProfile) {
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
                Icons.connect_without_contact,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Conectar',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Enviar Mensaje',
                  onPressed: () => _handleContactUser(userProfile),
                  icon: const Icon(Icons.message, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Al contactar a ${userProfile.displayName}, se iniciará una conversación privada.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Limpiar el perfil del usuario cuando salimos de la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProvider>().clearUserProfile();
      }
    });
    super.dispose();
  }
}
