import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/user_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/index.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_header.dart';
// import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_stats_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/user_pets_section.dart';
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
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  void _initializeProviders() {
    _userProvider = context.read<UserProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _userProvider.loadUserProfile(widget.userId);
      }
    });
  }

  @override
  void dispose() {
    _userProvider.clearUserProfile();

    super.dispose();
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

          return _buildUserProfile(userProfile, availablePets, adoptedPets);
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
              CustomButton(
                text: 'Reintentar',
                onPressed: () => _userProvider.loadUserProfile(widget.userId),
              ),
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
  ) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        await _userProvider.loadUserProfile(widget.userId);
      },
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              SliverAppBar(
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                title: Text(
                  'Perfil',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              SliverToBoxAdapter(child: ProfileHeader(user: userProfile)),
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverTabBarDelegate(
                  TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface,
                    indicatorColor: theme.colorScheme.primary,
                    dividerColor: Colors.transparent,
                    isScrollable: true,
                    tabAlignment: TabAlignment.center,
                    labelStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: theme.textTheme.bodyMedium,
                    tabs: [
                      const Tab(child: Text('Publicaciones')),
                      const Tab(child: Text('Adopciones')),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: UserPetsSection(
            availablePets: availablePets,
            adoptedPets: adoptedPets,
            isCurrentUser: false,
            onPetTap: (pet) {
              context.push('/pets/${pet.id}', extra: {'pet': pet});
            },
          ),
        ),
      ),
    );
  }
}
