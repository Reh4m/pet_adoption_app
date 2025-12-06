import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_adoption_app/src/domain/entities/adoption_request_entity.dart';
import 'package:pet_adoption_app/src/presentation/providers/adoption_request_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/chat_provider.dart';
import 'package:pet_adoption_app/src/presentation/providers/user_provider.dart';
import 'package:pet_adoption_app/src/presentation/utils/toast_notification.dart';
import 'package:pet_adoption_app/src/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';

class RequestActionButtons extends StatelessWidget {
  final AdoptionRequestEntity request;
  final bool isReceived;

  const RequestActionButtons({
    super.key,
    required this.request,
    required this.isReceived,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (request.isAccepted) {
      return _buildAcceptedActions(context, theme);
    }

    if (request.isPending && isReceived) {
      return _buildPendingReceivedActions(context, theme);
    }

    if (request.isPending && !isReceived) {
      return _buildPendingSentActions(context, theme);
    }

    if (request.isRejected || request.isCancelled) {
      return _buildClosedActions(context, theme);
    }

    return const SizedBox();
  }

  Widget _buildAcceptedActions(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Solicitud aceptada - Chat disponible',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Abrir Chat',
                onPressed: () => _openChat(context),
                icon: const Icon(Icons.chat_bubble, size: 20),
              ),
            ),
            if (isReceived) ...[
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Completar',
                  onPressed: () => _completeAdoption(context),
                  variant: ButtonVariant.outline,
                  icon: const Icon(Icons.task_alt, size: 20),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPendingReceivedActions(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Rechazar',
            onPressed: () => _showRejectDialog(context),
            variant: ButtonVariant.outline,
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Aceptar',
            onPressed: () => _showAcceptDialog(context),
            icon: const Icon(Icons.check, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingSentActions(BuildContext context, ThemeData theme) {
    return CustomButton(
      text: 'Cancelar Solicitud',
      onPressed: () => _showCancelDialog(context),
      variant: ButtonVariant.outline,
      width: double.infinity,
      icon: const Icon(Icons.cancel, size: 20),
    );
  }

  Widget _buildClosedActions(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            request.isRejected ? Icons.cancel : Icons.info,
            color: theme.colorScheme.onSurface.withAlpha(150),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              request.isRejected
                  ? 'Solicitud rechazada'
                  : 'Solicitud cancelada',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openChat(BuildContext context) async {
    final chatProvider = context.read<ChatProvider>();

    // Buscar chat existente por ID de solicitud
    final existingChat = chatProvider.findChatByAdoptionRequestId(request.id);

    if (existingChat != null) {
      context.push('/chat/${existingChat.id}', extra: {'chat': existingChat});
    } else {
      // Si no existe, crear el chat
      final userProvider = context.read<UserProvider>();
      final currentUser = userProvider.currentUser;

      if (currentUser == null) return;

      final chat = await chatProvider.createOrGetChat(
        adoptionRequestId: request.id,
        petId: request.petId,
        petName: request.petName,
        petImageUrls: request.petImageUrls,
        requesterId: request.requesterId,
        requesterName: request.requesterName,
        requesterPhotoUrl: request.requesterPhotoUrl,
        ownerId: request.ownerId,
        ownerName: request.ownerName,
        ownerPhotoUrl: null, // Se obtendrá del usuario
      );

      if (chat != null && context.mounted) {
        context.push('/chat/${chat.id}', extra: {'chat': chat});
      }
    }
  }

  void _showAcceptDialog(BuildContext context) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Aceptar Solicitud'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Deseas aceptar la solicitud de ${request.requesterName}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Mensaje adicional (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _acceptRequest(context, notesController.text);
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rechazar Solicitud'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¿Deseas rechazar la solicitud de ${request.requesterName}?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Motivo del rechazo *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (reasonController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    _rejectRequest(context, reasonController.text);
                  }
                },
                child: const Text('Rechazar'),
              ),
            ],
          ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar Solicitud'),
            content: const Text(
              '¿Estás seguro de que quieres cancelar esta solicitud?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelRequest(context);
                },
                child: const Text('Sí, cancelar'),
              ),
            ],
          ),
    );
  }

  Future<void> _acceptRequest(BuildContext context, String notes) async {
    final provider = context.read<AdoptionRequestProvider>();

    // Usar el nuevo método que incluye creación de chat
    final success = await provider.acceptRequestWithChat(
      request.id,
      notes: notes.trim().isNotEmpty ? notes : null,
    );

    if (context.mounted) {
      if (success) {
        ToastNotification.show(
          context,
          title: 'Solicitud aceptada',
          description: 'El chat se ha creado automáticamente.',
          type: ToastNotificationType.success,
        );
      } else {
        ToastNotification.show(
          context,
          title: 'Error',
          description:
              provider.responseError ?? 'No se pudo aceptar la solicitud.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, String reason) async {
    final provider = context.read<AdoptionRequestProvider>();

    final success = await provider.rejectRequestWithChat(
      request.id,
      rejectionReason: reason,
    );

    if (context.mounted) {
      if (success) {
        ToastNotification.show(
          context,
          title: 'Solicitud rechazada',
          description: 'Se ha notificado al solicitante.',
          type: ToastNotificationType.success,
        );
      } else {
        ToastNotification.show(
          context,
          title: 'Error',
          description:
              provider.responseError ?? 'No se pudo rechazar la solicitud.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _cancelRequest(BuildContext context) async {
    final provider = context.read<AdoptionRequestProvider>();

    final success = await provider.cancelRequest(request.id);

    if (context.mounted) {
      if (success) {
        ToastNotification.show(
          context,
          title: 'Solicitud cancelada',
          description: 'Tu solicitud ha sido cancelada.',
          type: ToastNotificationType.success,
        );
      } else {
        ToastNotification.show(
          context,
          title: 'Error',
          description:
              provider.responseError ?? 'No se pudo cancelar la solicitud.',
          type: ToastNotificationType.error,
        );
      }
    }
  }

  Future<void> _completeAdoption(BuildContext context) async {
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Completar Adopción'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '¿Confirmas que la adopción se ha completado exitosamente?',
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Comentarios finales (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Completar'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      final provider = context.read<AdoptionRequestProvider>();

      final success = await provider.completeRequest(
        request.id,
        notes:
            notesController.text.trim().isNotEmpty
                ? notesController.text
                : null,
      );

      if (context.mounted) {
        if (success) {
          ToastNotification.show(
            context,
            title: 'Adopción completada',
            description:
                '¡Felicidades! La adopción se ha completado exitosamente.',
            type: ToastNotificationType.success,
          );
        } else {
          ToastNotification.show(
            context,
            title: 'Error',
            description:
                provider.responseError ?? 'No se pudo completar la adopción.',
            type: ToastNotificationType.error,
          );
        }
      }
    }
  }
}
