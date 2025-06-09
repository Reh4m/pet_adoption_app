import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/authentication_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_header.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/profile_stats_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/user/profile/widgets/user_pets_section.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class CurrentUserProfileScreen extends StatefulWidget {
  const CurrentUserProfileScreen({super.key});

  @override
  State<CurrentUserProfileScreen> createState() =>
      _CurrentUserProfileScreenState();
}

class _CurrentUserProfileScreenState extends State<CurrentUserProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final petProvider = context.read<PetProvider>();

      // Cargar datos del usuario actual si no están cargados
      if (userProvider.currentUser == null) {
        userProvider.loadCurrentUser();
      }

      // Cargar mascotas del usuario actual
      final currentUser = userProvider.currentUser;
      if (currentUser != null) {
        petProvider.startRealtimeUpdates(); // Para obtener todas las mascotas
      }
    });
  }

  Future<void> _handleChangeProfilePhoto() async {
    final userProvider = context.read<UserProvider>();

    if (!userProvider.canEditProfilePhoto) {
      _showToast(
        'No disponible',
        'Solo usuarios registrados con email pueden cambiar su foto de perfil.',
        ToastNotificationType.info,
      );
      return;
    }

    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cambiar foto de perfil',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.camera_alt,
                        label: 'Cámara',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.photo_library,
                        label: 'Galería',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _uploadProfileImage(File(image.path));
      }
    } catch (e) {
      _showToast(
        'Error',
        'No se pudo cargar la imagen. Inténtalo de nuevo.',
        ToastNotificationType.error,
      );
    }
  }

  Future<void> _uploadProfileImage(File image) async {
    final userProvider = context.read<UserProvider>();
    final success = await userProvider.changeProfilePhoto(image);

    if (!mounted) return;

    if (success) {
      _showToast(
        'Foto actualizada',
        'Tu foto de perfil se ha actualizado correctamente.',
        ToastNotificationType.success,
      );
    } else {
      _showToast(
        'Error',
        userProvider.operationError ?? 'Error al actualizar la foto de perfil.',
        ToastNotificationType.error,
      );
    }
  }

  void _handleEditProfile() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    context.push('/profile/edit', extra: {'user': currentUser});
  }

  void _handleEditUserSettings() {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    context.push('/profile/settings', extra: {'user': currentUser});
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.warning,
            title: 'Cerrar Sesión',
            description: '¿Estás seguro de que quieres cerrar sesión?',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonText: 'Cerrar Sesión',
            primaryButtonIcon: Icons.logout,
            onPrimaryPressed: () async {
              Navigator.pop(context);
              await _signOut();
            },
            isSecondaryButtonEnabled: true,
            secondaryButtonVariant: ButtonVariant.outline,
            onSecondaryPressed: () => Navigator.pop(context),
          ),
    );
  }

  Future<void> _signOut() async {
    final authProvider = context.read<AuthenticationProvider>();
    final userProvider = context.read<UserProvider>();
    final petProvider = context.read<PetProvider>();

    await authProvider.signOut();
    userProvider.clearCurrentUser();
    petProvider.stopRealtimeUpdates();

    if (mounted) {
      context.go('/login');
    }
  }

  void _showToast(
    String title,
    String description,
    ToastNotificationType type,
  ) {
    ToastNotification.show(
      context,
      title: title,
      description: description,
      type: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer2<UserProvider, PetProvider>(
        builder: (context, userProvider, petProvider, child) {
          final currentUser = userProvider.currentUser;
          final isLoading = userProvider.currentUserState == UserState.loading;
          final hasError = userProvider.currentUserState == UserState.error;

          if (isLoading && currentUser == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando perfil...'),
                ],
              ),
            );
          }

          if (hasError && currentUser == null) {
            return Center(
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
                    userProvider.currentUserError ?? 'Error desconocido',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Reintentar',
                    onPressed: () => userProvider.loadCurrentUser(),
                  ),
                ],
              ),
            );
          }

          if (currentUser == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }

          final userPets =
              petProvider.allPets
                  .where((pet) => pet.ownerId == currentUser.id)
                  .toList();

          final adoptedPets =
              userPets.where((pet) => pet.status == PetStatus.adopted).toList();

          final availablePets =
              userPets
                  .where((pet) => pet.status == PetStatus.available)
                  .toList();

          return LoadingOverlay(
            isLoading: userProvider.operationState == UserState.loading,
            message: 'Actualizando perfil...',
            child: RefreshIndicator(
              onRefresh: () async {
                await userProvider.loadCurrentUser();
                await petProvider.refreshPets();
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    actions: [
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onPrimary,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              _handleEditProfile();
                              break;
                            case 'settings':
                              _handleEditUserSettings();
                              break;
                            case 'signout':
                              _handleSignOut();
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 10),
                                    Text('Editar perfil'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 10),
                                    Text('Configuraciones'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'signout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: theme.colorScheme.error,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Cerrar sesión',
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: ProfileHeader(
                        user: currentUser,
                        isCurrentUser: true,
                        onChangePhoto: _handleChangeProfilePhoto,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ProfileStatsCard(
                            petsPosted: currentUser.petsPosted,
                            petsAdopted: currentUser.petsAdopted,
                            isExperienced: currentUser.isExperienced,
                          ),
                          const SizedBox(height: 20),
                          UserPetsSection(
                            availablePets: availablePets,
                            adoptedPets: adoptedPets,
                            isCurrentUser: true,
                            onPetTap: (pet) => context.push('/pets/${pet.id}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
