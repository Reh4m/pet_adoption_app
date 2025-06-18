import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/domain/entities/pet/pet_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_alert_dialog.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_text_field.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/loading_overlay.dart';
import 'package:provider/provider.dart';

class AdoptionRequestScreen extends StatefulWidget {
  final PetEntity pet;

  const AdoptionRequestScreen({super.key, required this.pet});

  @override
  State<AdoptionRequestScreen> createState() => _AdoptionRequestScreenState();
}

class _AdoptionRequestScreenState extends State<AdoptionRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _hasExistingRequest = false;
  bool _isCheckingExistingRequest = true;

  @override
  void initState() {
    super.initState();
    _checkExistingRequest();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _checkExistingRequest() async {
    final userProvider = context.read<UserProvider>();
    final adoptionProvider = context.read<AdoptionRequestProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) return;

    final hasExisting = await adoptionProvider.hasExistingRequest(
      widget.pet.id,
      currentUser.id,
    );

    if (mounted) {
      setState(() {
        _hasExistingRequest = hasExisting;
        _isCheckingExistingRequest = false;
      });
    }
  }

  Future<void> _handleSubmitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    final adoptionProvider = context.read<AdoptionRequestProvider>();
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      _showToast(
        'Error',
        'Debes iniciar sesión para enviar una solicitud.',
        ToastNotificationType.error,
      );
      return;
    }

    final request = AdoptionRequestEntity(
      id: '',
      petId: widget.pet.id,
      petName: widget.pet.name,
      petImageUrls: widget.pet.imageUrls,
      requesterId: currentUser.id,
      requesterName: currentUser.displayName,
      requesterPhotoUrl: currentUser.photoUrl,
      ownerId: widget.pet.ownerId,
      ownerName: '',
      status: AdoptionRequestStatus.pending,
      message: _messageController.text.trim(),
      createdAt: DateTime.now(),
    );

    final requestId = await adoptionProvider.createAdoptionRequest(request);

    if (!mounted) return;

    if (requestId != null) {
      _showSuccessDialog();
    } else {
      _showToast(
        'Error',
        adoptionProvider.createError ?? 'Error al enviar la solicitud.',
        ToastNotificationType.error,
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomAlertDialog(
            status: AlertDialogStatus.success,
            title: '¡Solicitud Enviada!',
            description:
                'Tu solicitud de adopción para ${widget.pet.name} ha sido enviada. El dueño recibirá una notificación y podrá contactarte pronto.',
            primaryButtonText: 'Continuar',
            primaryButtonVariant: ButtonVariant.primary,
            primaryButtonIcon: Icons.arrow_forward,
            onPrimaryPressed: () {
              Navigator.pop(context);
              context.pop();
            },
          ),
    );
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

    if (_isCheckingExistingRequest) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          title: const Text('Cargando...'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando solicitudes existentes...'),
            ],
          ),
        ),
      );
    }

    if (_hasExistingRequest) {
      return _buildExistingRequestScreen(theme);
    }

    return Consumer<AdoptionRequestProvider>(
      builder: (context, provider, child) {
        return LoadingOverlay(
          isLoading: provider.createState == AdoptionRequestState.loading,
          message: 'Enviando solicitud...',
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              title: Text(
                'Solicitar Adopción',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildPetCard(theme),
                    const SizedBox(height: 20),
                    _buildRequestForm(theme),
                    const SizedBox(height: 20),
                    _buildSubmitButton(theme, provider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExistingRequestScreen(ThemeData theme) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        title: Text(
          'Solicitud existente',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Solicitud Pendiente',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ya tienes una solicitud pendiente para ${widget.pet.name}. '
              'El dueño la revisará pronto y te contactará.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Ver Mis Solicitudes',
              onPressed: () => context.push('/adoption/sent'),
              width: double.infinity,
              icon: const Icon(Icons.list, size: 20),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: 'Volver',
              variant: ButtonVariant.outline,
              onPressed: () => context.pop(),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                widget.pet.imageUrls.isNotEmpty
                    ? Image.network(
                      widget.pet.imageUrls.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildPetPlaceholder(theme),
                    )
                    : _buildPetPlaceholder(theme),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pet.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${widget.pet.breed} • ${widget.pet.ageString}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${widget.pet.location.city}, ${widget.pet.location.state}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetPlaceholder(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.pets, size: 40, color: theme.colorScheme.primary),
    );
  }

  Widget _buildRequestForm(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuéntanos por qué quieres adoptar a ${widget.pet.name}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Comparte un poco sobre ti, tu experiencia con mascotas y por qué serías un buen hogar para ${widget.pet.name}.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        CustomTextField(
          label: 'Mensaje para el dueño *',
          hint:
              'Ej. Hola, me encantaría adoptar a ${widget.pet.name}. Tengo experiencia con ${widget.pet.category} y...',
          controller: _messageController,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El mensaje es obligatorio';
            }
            if (value.trim().length < 20) {
              return 'El mensaje debe tener al menos 20 caracteres';
            }
            if (value.trim().length > 500) {
              return 'El mensaje no puede exceder 500 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 5),
        Text(
          '${_messageController.text.length}/500 caracteres',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, AdoptionRequestProvider provider) {
    return Column(
      children: [
        CustomButton(
          text: 'Enviar Solicitud',
          onPressed:
              provider.createState == AdoptionRequestState.loading
                  ? null
                  : _handleSubmitRequest,
          isLoading: provider.createState == AdoptionRequestState.loading,
          width: double.infinity,
          icon: const Icon(Icons.send, size: 20),
          iconPosition: ButtonIconPosition.right,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'El dueño recibirá tu solicitud y podrá contactarte si está interesado.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
