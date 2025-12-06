import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/pet_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/action_buttons.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/owner_info_card.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/pet_characteristics.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/pet_description.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/pet_images_gallery.dart';
import 'package:pet_adoption_app/src/presentation/screens/pets/details/widgets/pet_info_selection.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:provider/provider.dart';

class PetDetailsScreen extends StatefulWidget {
  final String petId;

  const PetDetailsScreen({super.key, required this.petId});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAppBarExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadPetDetails();
    _setupScrollListener();
  }

  void _loadPetDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PetProvider>().getPetById(widget.petId);
    });
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isExpanded = _scrollController.offset < 200;
      if (isExpanded != _isAppBarExpanded) {
        setState(() {
          _isAppBarExpanded = isExpanded;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleInterest(PetEntity pet) {
    // TODO: Implementar sistema de solicitudes
    ToastNotification.show(
      context,
      title: '¡Interés registrado!',
      description:
          'Próximamente podrás enviar una solicitud de adopción para ${pet.name}.',
      type: ToastNotificationType.success,
    );
  }

  void _handleContact(PetEntity pet) async {
    final userProvider = context.read<UserProvider>();
    final chatProvider = context.read<ChatProvider>();
    final adoptionProvider = context.read<AdoptionRequestProvider>();

    final currentUser = userProvider.currentUser;
    if (currentUser == null) {
      ToastNotification.show(
        context,
        title: 'Inicia sesión',
        description: 'Debes iniciar sesión para contactar al dueño.',
        type: ToastNotificationType.warning,
      );
      return;
    }

    if (currentUser.id == pet.ownerId) {
      ToastNotification.show(
        context,
        title: 'Es tu mascota',
        description: 'No puedes contactarte contigo mismo.',
        type: ToastNotificationType.info,
      );
      return;
    }

    // Buscar solicitud de adopción existente
    final hasExisting = await adoptionProvider.hasExistingRequest(
      pet.id,
      currentUser.id,
    );

    if (!hasExisting) {
      // No hay solicitud, redirigir para crear una
      ToastNotification.show(
        // ignore: use_build_context_synchronously
        context,
        title: 'Solicitud requerida',
        description: 'Primero debes enviar una solicitud de adopción.',
        type: ToastNotificationType.info,
      );
      // ignore: use_build_context_synchronously
      context.push('/adoption/request/${pet.id}', extra: {'pet': pet});
      return;
    }

    final existingRequest = adoptionProvider.sentRequests.firstWhere(
      (request) => request.petId == pet.id && request.isPending,
    );

    if (!existingRequest.isAccepted) {
      ToastNotification.show(
        // ignore: use_build_context_synchronously
        context,
        title: 'Solicitud pendiente',
        description:
            'Espera a que el dueño acepte tu solicitud para iniciar el chat.',
        type: ToastNotificationType.info,
      );
      return;
    }

    final owner = userProvider.userProfile!;

    final chat = await chatProvider.createOrGetChat(
      adoptionRequestId: existingRequest.id,
      petId: pet.id,
      petName: pet.name,
      petImageUrls: pet.imageUrls,
      requesterId: currentUser.id,
      requesterName: currentUser.displayName,
      requesterPhotoUrl: currentUser.photoUrl,
      ownerId: owner.id,
      ownerName: owner.displayName,
      ownerPhotoUrl: owner.photoUrl,
    );

    if (chat != null && mounted) {
      context.push('/chat/${chat.id}', extra: {'chat': chat});
    } else {
      ToastNotification.show(
        // ignore: use_build_context_synchronously
        context,
        title: 'Error',
        description:
            chatProvider.operationError ?? 'No se pudo iniciar el chat.',
        type: ToastNotificationType.error,
      );
    }
  }

  void _handleFavorite(PetEntity pet) {
    // TODO: Implementar favoritos
    ToastNotification.show(
      context,
      title: 'Favoritos',
      description: 'Sistema de favoritos próximamente.',
      type: ToastNotificationType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer<PetProvider>(
        builder: (context, provider, child) {
          if (provider.state == PetState.loading) {
            return _buildLoadingState();
          }

          if (provider.state == PetState.error) {
            return _buildErrorState(theme, provider.errorMessage);
          }

          final pet = provider.selectedPet;

          if (pet == null) {
            return _buildNotFoundState();
          }

          return _buildPetDetails(pet);
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
            Text('Cargando información de la mascota...'),
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
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                'Error al cargar la mascota',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Error desconocido',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadPetDetails,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
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
              Icon(Icons.pets, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Mascota no encontrada',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Es posible que esta mascota ya no esté disponible.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetDetails(PetEntity pet) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
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
                  onPressed: () => _handleFavorite(pet),
                  icon: Icon(
                    Icons.favorite_border,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: PetImageGallery(imageUrls: pet.imageUrls),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PetInfoSection(pet: pet),
                  const SizedBox(height: 20),
                  PetCharacteristics(pet: pet),
                  const SizedBox(height: 20),
                  PetDescription(pet: pet),
                  const SizedBox(height: 20),
                  OwnerInfoCard(ownerId: pet.ownerId),
                  const SizedBox(height: 200),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: ActionButtons(
        pet: pet,
        onInterest: () => _handleInterest(pet),
        onContact: () => _handleContact(pet),
      ),
    );
  }
}
